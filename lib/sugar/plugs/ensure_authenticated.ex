defmodule Sugar.Plugs.EnsureAuthenticated do
  import Plug.Conn
  import Module, only: [concat: 2]

  @behaviour Plug

  ## Actual plug functionality

  def init(opts) do
    handler =
      opts |> Keyword.get(:handler, {__MODULE__, :verify})
    redirect_to =
      opts |> Keyword.get(:redirect_to, "/login")
    return_to =
      opts |> Keyword.get(:return_to, nil)
    only =
      opts |> Keyword.get(:only, [])
    except =
      opts |> Keyword.get(:except, [])
    model =
      opts |> Keyword.get(:model, basename |> concat(Models) |> concat(User))
    repo =
      opts |> Keyword.get(:repo, basename |> concat(Repos) |> concat(Main))

    # sanity checks
    unless is_list(only) and is_list(except), do: raise ArgumentError

    # main pieces
    opts = %{handler: handler, model: model, repo: repo}

    # sanitize
    cond do
      length(only) > 0 ->
        opts |> Map.merge(%{only: only})
      length(except) > 0 ->
        opts |> Map.merge(%{except: except})
      true ->
        opts
    end
  end

  def call(conn, %{handler: {module, function}} = opts) do
    apply module, function, [conn, opts]
  end
  def call(conn, %{handler: module} = opts) do
    apply module, :verify, [conn, opts]
  end

  ## Built-in default handler

  def verify(conn, %{only: actions} = opts) do
    if conn.private.action in actions do
      conn |> verify(opts)
    else
      conn
    end
  end
  def verify(conn, %{except: actions} = opts) do
    if conn.private.action in actions do
      conn
    else
      conn |> verify(opts)
    end
  end
  def verify(conn, %{repo: repo, model: model} = opts) do
    conn = conn |> fetch_session
    user = conn |> get_session("user_id") |> get_user({repo, model})

    conn |> ensure(user, opts)
  end

  ## Helper functions

  defp basename do
    {result, _} = Mix.Project.config[:app]
    |> String.Chars.to_string
    |> Mix.Utils.camelize
    |> Code.eval_string

    result
  end

  defp get_user(nil, _opts), do: nil
  defp get_user(id, {repo, model}), do: repo.get(model, id)

  defp ensure(conn, nil, opts), do: redirect(conn, destination(conn, opts))
  defp ensure(conn, user, _), do: assign(conn, :current_user, user)

  defp destination(conn, %{redirect_to: redirect_to, return_to: return_to}) do
    redirect_to <> return_to_params(conn, return_to)
  end

  defp return_to_params(_conn, {_name, nil}), do: ""
  defp return_to_params(conn, {name, :origin}) do
    return_to_params(conn, {name, conn.request_path})
  end
  defp return_to_params(_conn, {name, value}) do
    "?" <> URI.encode_query([{name, value}])
  end
  defp return_to_params(conn, value) do
    return_to_params(conn, {"return_to", value})
  end

  # Ported from Sugar.Controller.Helpers
  defp redirect(conn, location, opts \\ []) do
    opts = [status: 302] |> Keyword.merge(opts)
    conn
    |> maybe_put_resp_header("location", location)
    |> maybe_send_resp(opts[:status], "")
  end

  defp maybe_put_resp_header(%Plug.Conn{state: :sent} = conn, _, _) do
    conn
  end
  defp maybe_put_resp_header(conn, key, value) do
    conn |> put_resp_header(key, value)
  end

  defp maybe_send_resp(%Plug.Conn{state: :sent} = conn, _, _) do
    conn
  end
  defp maybe_send_resp(conn, status, body) do
    conn |> send_resp(status, body)
  end
end

defmodule Plugs.HotCodeReload do
  import Plug.Connection

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    case reload(Mix.env) do
      :ok -> 
        location = "/" <> Enum.join conn.path_info, "/"
        conn
          |> put_resp_header("Location", location) 
          |> send_resp_if_not_sent(302, "")
      _   -> conn
    end
  end

  defp reload(:dev) do 
    Mix.Tasks.Compile.Elixir.run([])
  end
  defp reload(_), do: :noreload

  defp send_resp_if_not_sent(Plug.Conn[state: :sent] = conn, _, _) do
    conn
  end
  defp send_resp_if_not_sent(conn, status, body) do
    conn |> send_resp(status, body)
  end
end
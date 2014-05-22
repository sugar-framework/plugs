defmodule Sugar.Plugs.Exceptions do
  @moduledoc """
  Catches runtime exceptions for displaying an error screen instead of an empty
  response in dev environments.
  """
  @behaviour Plug.Wrapper
  import Plug.Conn

  @doc """
  Inits options on compile

  ## Arguments

  * `opts` - `Keyword`

  ## Returns

  `Keyword`
  """
  def init(opts), do: opts

  @doc """
  Wraps a connection for catching exceptions

  ## Arguments

  * `conn` - `Plug.Conn`
  * `opts` - `Keyword`
  * `fun` - `Function`

  ## Returns

  `Plug.Conn`
  """
  def wrap(conn, opts, fun) do
    try do
      fun.(conn)
    catch
      kind, e ->
        env = System.get_env
        assigns = [
          kind: get_kind(e, kind),
          value: e,
          elixir_build_info: System.build_info,
          env: Map.keys(env) |> Enum.map(fn(key) ->
            [ key: key,
              value: Map.get(env, key) ]
          end),
          stacktrace: System.stacktrace |> Enum.map(fn({mod, fun, arr, meta}) ->
            [ module: atom_to_binary(mod) |> String.replace("Elixir.", ""),
              function: atom_to_binary(fun),
              arrity: arr,
              file: meta[:file],
              line: meta[:line],
              source: get_file_contents(meta[:file]) ]
          end),
          conn: conn
        ]
        eex_opts = [file: __ENV__.file, line: __ENV__.line, engine: EEx.SmartEngine]

        message = log_request(conn) <> log_cause(kind, e) <> log_stacktrace(System.stacktrace)
        message = List.from_char_data!(message)
        :error_logger.error_msg(message)

        %{ conn | state: :set}
          |> put_resp_header("content-type", "text/html; charset=utf-8")
          |> send_resp(500, opts[:dev_template] |> EEx.eval_string([assigns: assigns], eex_opts))
    end
  end

  defp get_kind(e, kind) when is_atom(e) do
    kind
  end
  defp get_kind(e, _kind) when is_record(e) do
    atom_to_binary(e.__record__(:name))
      |> String.replace("Elixir.", "")
  end

  defp get_file_contents(nil), do: "no source available"
  defp get_file_contents(file) do
    if File.exists?(file) do
      File.read!(file)
    else
      case Path.wildcard("deps/*/#{file}") do
        [] -> "no source available for '#{file}'"
        matches ->
          matches |> hd |> File.read!
      end
    end
  end

  defp log_request(conn) do
    "  Request: #{conn.method} /#{conn.path_info |> Enum.join("/")}\n"
  end

  defp log_cause(:error, value) when is_atom(value) do
    "  Cause: (Error) #{inspect value}\n"
  end
  defp log_cause(:error, value) when is_record(value) do
    "  Cause: (#{inspect value.__record__(:name)}) #{value.message}\n"
  end
  defp log_cause(:error, value) do
    "  Cause: (#{inspect value.__struct__(:name)}) #{value.message}\n"
  end

  defp log_cause(kind, value) do
    "  Cause: (#{kind}) #{inspect(value)}\n"
  end

  defp log_stacktrace(stacktrace) do
    Enum.reduce stacktrace, "  Stacktrace:\n", fn(trace, acc) ->
      acc <> "    " <> Exception.format_stacktrace_entry(trace) <> "\n"
    end
  end
end

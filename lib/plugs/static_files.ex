defmodule Plugs.StaticFiles do
  use Plug.Builder
  import Plug.Connection

  def init(opts), do: opts

  def call(conn, opts) do
    url = String.split opts[:url], "/", trim: true
    path = Path.expand opts[:path]

    if match_request? conn, url do
      cond do
        invalid_path? conn.path_info ->
          conn |> send_resp(400, "")
        true -> 
          send_file_if_exists conn, path, url
      end
    else
      conn
    end
  end

  defp invalid_path?([h|_]) when h in [".", "..", ""], do: true
  defp invalid_path?([h|t]) do
    case :binary.match(h, ["/", "\\", ":"]) do
      { _, _ } -> true
      :nomatch -> invalid_path?(t)
    end
  end
  defp invalid_path?([]), do: false

  defp match_request?(conn, url) do
    Enum.take(conn.path_info, Enum.count(url)) === url
  end

  defp send_file_if_exists(conn, path, url) do
    requested = Enum.join strip_path!(conn, url), "/"
    file = Path.expand path <> "/" <> requested
    if File.regular? file do
      conn 
        |> put_resp_content_type(MIME.Types.path(file)) 
        |> put_resp_header("cache-control", "public, max-age=31536000")
        |> send_file(200, file)
    else
      conn
    end
  end

  defp strip_path!(conn, path) do
    Enum.drop conn.path_info, Enum.count(path)
  end
end
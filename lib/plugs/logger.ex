defmodule Plugs.Logger do
  require Lager

  @behaviour Plug.Wrapper

  def init(opts), do: opts

  def wrap(conn, _opts, fun) do
    conn = fun.(conn)
    Lager.info "#{conn.method} #{conn.status} /#{Enum.join conn.path_info, "/"}"
    conn
  end
end
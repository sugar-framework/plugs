defmodule Sugar.Plugs.HotCodeReload do

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    reload(Mix.env)
    conn
  end

  defp reload(:dev) do
    Mix.Task.reenable "compile.elixir"
    Mix.Task.reenable "compile.sugar"
    Mix.Task.run "compile.elixir"
    Mix.Task.run "compile.sugar"
  end
  defp reload(_), do: :noreload

end

defmodule Plugs.StaticFiles do
  def call(conn, []) do
    {:ok, conn}
  end
end
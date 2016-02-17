# Plugs

## `Sugar.Plugs.HotCodeReload`

Used to add hot code reloading to a project, preventing the need to stop, recompile, and start your application to see your changes.

Use:

```elixir
defmodule MyRouter do
  use Plug.Router

  plug Sugar.Plugs.HotCodeReload

  plug :match
  plug :dispatch

  # Rest of router definition
  ...
end

# Plugs

## `Plug.StaticFiles`

Use:
```elixir
quote do
  use Plug.Router

  plug Plugs.StaticFiles, url: "/static", path: "priv/static"

  plug :match
  plug :dispatch

  # Rest of router definition
  ...
end
```
# Plugs

## `Plug.StaticFiles`

Used for serving static files.

Options:

- `url` - for defining the url prefix for static files. 
- `path` - location of static files in project, relative to project directory root.

Use:

```elixir
defmodule MyRouter do
  use Plug.Router

  plug Plugs.StaticFiles, url: "/static", path: "priv/static"

  plug :match
  plug :dispatch

  # Rest of router definition
  ...
end
```

## `Plug.Logger`

Used to log requests.

Use:

```elixir
defmodule MyRouter do
  use Plug.Router

  plug Plugs.Logger

  plug :match
  plug :dispatch

  # Rest of router definition
  ...
end
```

## `Plug.HotCodeReload`

Used to add hot code reloading to a project, preventing the need to stop, recompile, and start your application to see your changes.

Use:

```elixir
defmodule MyRouter do
  use Plug.Router

  plug Plugs.HotCodeReload

  plug :match
  plug :dispatch

  # Rest of router definition
  ...
end
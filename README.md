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
```

## `Sugar.Plugs.EnsureAuthenticated`

Used to ensure that a user is currently logged on before proceeding through a Plug pipeline.  This is designed first and foremost for [Sugar](http://sugar-framework.github.io), but it can hypothetically work with any plug-based app (emphasis on "hypothetically").

### Setup

In your `router.ex`:

```elixir
defmodule MyApp.Router do
  use Sugar.Router

  plug :put_secret_key_base
  plug Plug.Session,
    store: :cookie,
    key: "_my_app_session",
    encryption_salt: "encryption salt",
    signing_salt: "signing salt",
    key_length: 64

  def put_secret_key_base(conn, _) do
    base = "some 64 character random string"
    put_in conn.secret_key_base, base
  end

  # ...

end
```

### Use

Add this to a controller you want authentication on:

```elixir
defmodule MyApp.Controllers.Foo do
  use Sugar.Controller

  plug Sugar.Plugs.EnsureAuthenticated

  # ...

end
```

If your controller has some actions that don't need authentication, then you can use `plug Sugar.Plugs.EnsureAuthenticated, except: [:foo, :bar]`.  Likewise, if your controller's actions mostly don't require authentication, you can use `plug Sugar.Plugs.EnsureAuthenticated, only: [:baz, :bat]`.  Only specify one or the other (`:only` *should* take precedence in the event that both are used).

### Configuration

`Sugar.Plugs.EnsureAuthenticated` defaults to expect the following:

* You have an Ecto repo at `MyApp.Repos.Main`
* You have a User model at `MyApp.Models.User`
* Users should be directed to your app's `/login` route if they're not currently logged in

The first two can be overridden by calling the plug as `plug Sugar.Plugs.EnsureAuthenticated, repo: My.Custom.Repo, model: My.Custom.Model` (should be self-explanatory).  The third can't be changed quite yet (TODO: add that configuration option), at least not without implementing a custom handler (see below).

#### Custom Handler

By default, `Sugar.Plugs.EnsureAuthenticated` uses a built-in handler to check for authentication.  This handler is pretty minimal in terms of what it does:

* Checks to see if the controller action being run actually requires authentication (by checking `conn.private.action` for an action name); if not, then continues without doing anything else.
* Checks to see if there's a "user_id" session key (if not, then redirects to "/login")
* Fetches a `%MyApp.Models.User{}` (or the struct for whatever model you've configured) from `MyApp.Repos.Main` (or whatever repo you've configured); if it can't find a user, then redirects to "/login"
* Assigns the found user to the connection's `:current_user` (for use by other plugs, namely [Canary](https://github.com/cpjk/canary)), then continues on the pipeline

If you need to implement custom functionality (for example, if you're not using Sugar-compatible controllers, or if you're not using Ecto models), you can call `plug Sugar.Plugs.EnsureAuthenticated, handler: {MyApp.Auth.Handler, :verify}` (where `MyApp.Auth.Handler` is a module and `:verify` is the name of a function in that module; you could also do `handler: MyApp.Auth.Handler`, in which case the `:verify` function will be called).

In order to work, the handler must accept both a `%Plug.Conn{}` (i.e. a `conn` variable, like in a typical plug) and a `Map` containing the options passed to `EnsureAuthenticated`.  From here, you can implement whatever checks you need to perform.

### To Do

* Allow more things to be customized without having to implement a custom handler
* Move default values from hard-coded to `config.exs`-based configuration

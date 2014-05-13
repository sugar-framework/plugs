defmodule Plugs.Mixfile do
  use Mix.Project

  def project do
    [ app: :plugs,
      version: "0.0.2-dev",
      elixir: ">= 0.13.0",
      name: "Plugs",
      deps: deps(Mix.env),
      package: package,
      description: description,
      docs: [readme: true, main: "README"] ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:exlager],
      mod: { Sugar.App, [] } ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps(:prod) do
    [ { :cowboy, "~> 0.9", github: "extend/cowboy" },
      { :plug, "0.4.3" } ]
  end

  defp deps(:docs) do
    deps(:prod) ++
      [ { :ex_doc, github: "elixir-lang/ex_doc" } ]
  end

  defp deps(_) do
    deps(:prod)
  end

  defp description do
    """
    A collection of Plug middleware for web applications
    """
  end

  defp package do
    %{contributors: ["Shane Logsdon"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sugar-framework/plugs"}
  end
end

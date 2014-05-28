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
    [ applications: [],
      mod: { Sugar.App, [] } ]
  end

  defp deps(:prod) do
    [ { :cowboy, "~> 0.9", github: "extend/cowboy" },
      { :plug, "0.4.3" },
      { :jsex, "~> 2.0.0"} ]
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
      links: %{"GitHub" => "https://github.com/sugar-framework/plugs"}}
  end
end

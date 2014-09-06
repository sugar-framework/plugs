defmodule Plugs.Mixfile do
  use Mix.Project

  def project do
    [ app: :plugs,
      version: "0.0.2-dev",
      elixir: "~> 1.0.0-rc1",
      name: "Plugs",
      deps: deps(Mix.env),
      package: package,
      description: description,
      docs: [readme: true, main: "README"],
      test_coverage: [tool: ExCoveralls] ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:plug] ]
  end

  defp deps(:prod) do
    [ { :cowboy, "~> 1.0.0" },
      { :plug, "~> 0.7.0" },
      { :jsex, "~> 2.0.0"} ]
  end

  defp deps(:docs) do
    deps(:prod) ++
      [ { :ex_doc, "~> 0.6.0"  } ]
  end

  defp deps(_) do
    deps(:prod) ++
      [ { :excoveralls, github: "parroty/excoveralls" } ]
  end

  defp description do
    """
    A collection of Plug middleware for web applications
    """
  end

  defp package do
    %{contributors: ["Shane Logsdon"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sugar-framework/plugs",
               "Docs" => "http://sugar-framework.github.io/docs/api/plugs/"}}
  end
end

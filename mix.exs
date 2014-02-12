defmodule Plugs.Mixfile do
  use Mix.Project

  def project do
    [ app: :plugs,
      version: "0.0.1",
      elixir: "~> 0.12.4-dev",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [:exlager],
      mod: { Sugar.App, [] }
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      { :plug, github: "elixir-lang/plug" },
      { :mime, github: "dynamo/mime" },
      { :exlager, github: "khia/exlager" }
    ]
  end
end

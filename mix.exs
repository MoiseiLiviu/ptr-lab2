defmodule Untitled.MixProject do
  use Mix.Project

  def project do
    [
      app: :streamprocessor,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
#      mod: {StreamProc, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:eventsource_ex, "~> 1.1.0"},
      {:jason, "~> 1.4"}
    ]
  end
end

defmodule ExCrowdin.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_crowdin,
      version: "0.2.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support", "config/text.exs"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:jason, "~> 1.1"},
      {:httpoison, "~> 1.0"},
      {:mox, "~> 0.5", only: :test},
      {:ex_doc, "~> 0.18", only: :dev},
      {:ecto, ">= 3.0.0"}
    ]
  end

  defp description do
    """
    A Crowdin client for Elixir.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Vu Minh Tan"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/thekirinlab/ex_crowdin"}
    ]
  end
end

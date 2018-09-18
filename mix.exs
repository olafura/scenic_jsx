defmodule ScenicJsx.MixProject do
  use Mix.Project

  def project do
    [
      app: :scenic_jsx,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.4"},

      # deps to use AFTER it is released publicly
      {:scenic, "~> 0.7.0"},
      {:scenic_driver_glfw, "~> 0.7.0"},
      {:nimble_parsec, "~> 0.2"},
      {:uuid, "~> 1.1"},
    ]
  end
end

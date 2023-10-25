defmodule LivebookUtils.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source_url "https://github.com/brooklin_jazz/livebook_utils"

  def project do
    [
      app: :livebook_utils,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
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
      {:ex_doc, "~> 0.30.9"}
    ]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      source_url: @source_url,
      logo: "assets/images/logo.png",
      extras: [
        "README.md"
      ]
    ]
  end

  # Hex package configuration
  defp package do
    %{
      maintainers: ["Brooklin Myers"],
      licenses: ["MIT"],
      description:
        "A collection of Livebook utility modules and mix tasks for managing livebook projects",
      links: %{
        "GitHub" => @source_url
      },
      source_url: @source_url
    }
  end
end

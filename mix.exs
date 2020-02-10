defmodule Gutenex.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gutenex,
      name: "Gutenex",
      description: "PDF Generation in Elixir",
      version: "0.2.1",
      source_url: "https://github.com/manuel-rubio/gutenex",
      elixir: "~> 1.0",
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:imagineer, "~> 0.3"},
      {:ex_doc, "~> 0.19", only: :dev},
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{github: "https://github.com/manuel-rubio/gutenex"},
      contributors: ["Chris Maddox", "Gary Morrison", "Manuel Rubio"]
    ]
  end
end

defmodule Exsyslog.Mixfile do
  use Mix.Project

  def project do
    [app: :exsyslog,
     version: "0.0.2",
     elixir: "~> 0.13.2",
     deps: deps]
  end

  # Configuration for the OTP application
  def application do
    [applications: [],
     mod: {ExSyslog, []}]
  end

  # Dependencies can be hex.pm packages:
  defp deps do
    [ 
      {:exprintf, "~>0.1.0"},
      {:exactor, "~>0.3.3"},
    ]
  end
end

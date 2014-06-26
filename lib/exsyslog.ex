defmodule ExSyslog do
  use Application

  def start(_type, _args) do
    ExSyslog.Supervisor.start_link
  end
end

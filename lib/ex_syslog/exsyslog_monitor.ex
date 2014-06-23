defmodule ExSyslog.Monitor do

  use ExActor.GenServer, export: :exsyslog_monitor

  definit do
    :gen_event.add_sup_handler :error_logger, ExSyslog.EventHandler, []
    initial_state []
  end
  
end

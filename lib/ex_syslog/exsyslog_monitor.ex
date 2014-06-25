defmodule ExSyslog.Monitor do

  use ExActor.GenServer

  definit do
    :gen_event.add_sup_handler :error_logger, ExSyslog.EventHandler, []
    initial_state []
  end

  def handle_info({:gen_event_EXIT, ExSyslog.EventHandler, reason} = msg, state) do
    :io.format('~p~n', [msg])
    {:stop, reason, state}
  end

  def terminate(_reason, _state), do: :ok
  def code_change(_, state, _), do: {:ok, state}
  
end

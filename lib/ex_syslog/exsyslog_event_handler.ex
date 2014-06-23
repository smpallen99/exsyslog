defmodule ExSyslog.EventHandler do
  import ExPrintf
  use GenEvent.Behaviour 

  defmodule State do
    defstruct level: 7
    def new, do: %State{}
    def new(opts), do: struct(new, opts)
  end

    # def start_link do
    #   :gen_event.start_link {:local, :error_logger}
    # end

  def level do
    :gen_event.call(:error_logger, ExSyslog.EventHandler, :level)
  end

  def level(level) do
    :gen_event.call(:error_logger, ExSyslog.EventHandler, {:set_level, level})
  end

  def init([]) do
    IO.puts "Event handler starting..."
    {:ok, State.new} 
  end

  def handle_call({:set_level, level}, state) do
    {:ok, :ok, struct(state, level: level)}
  end

  def handle_call(:level, %State{level: level} = state) do
    {:ok, level, state}
  end

  def handle_event(%ExSyslog.Message{level: level, msg: msg, msgid: msgid, pid: pid}, state) do
    write(level, msgid, msg, pid, state)
    {:ok, state}
  end

  def handle_event({class, _gl, {pid, format, args}}, %State{level: max} = state) do
    case otp_event_level(class, format) do
      :undefined -> 
        # IO.puts "undefined..."
        # IO.puts "event --> class: #{inspect class}, pid: #{inspect pid}, format: #{inspect format}, args: #{inspect args}"
        {:ok, state}
      level when level > max -> 
        # IO.puts "#{level} > #{max}"
        # IO.puts "event --> class: #{inspect class}, pid: #{inspect pid}, format: #{inspect format}, args: #{inspect args}"
        {:ok, state}
      level -> 
        IO.puts "event --> class: #{inspect class}, pid: #{inspect pid}, format: #{inspect format}, args: #{inspect args}"
        {:ok, state}
    end
  end

  def handle_event({:log, msg}, state) do
    IO.puts "--> #{msg}"
    {:ok, state}
  end

  def write(level, _msgid, msg, pid, _state) do
    write(level, :undefined, "#{inspect pid} #{msg}")
  end

  def write(_, :undefined, packet), do: IO.puts packet
  
  def message(type, report) when type in [:std_error, :std_info, :std_warning, :progress_report, :progress] do
    {type, ExSyslog.Util.format(type, "#{inspect report}", [])}
  end

  def message(format, args) do
    {:unknown, ExSyslog.Util.format(format, "#{inspect args}", [])}
  end

  def otp_event_level(_, :crash_report),      do: level_crit
  def otp_event_level(_, :supervisor_report), do: level_warn
  def otp_event_level(_, :supervisor),        do: level_warn
  def otp_event_level(_, :progress_report),   do: level_debug
  def otp_event_level(_, :progress),          do: level_debug
  def otp_event_level(:error, _),             do: level_err
  def otp_event_level(:warning_msg, _),       do: level_warn
  def otp_event_level(:info_msg, _),          do: level_notice
  def otp_event_level(:error_report, _),      do: level_err
  def otp_event_level(:warning_report, _),    do: level_warn
  def otp_event_level(:info_report, _),       do: level_notice
  def otp_event_level(_, _),                  do: level_debug
    

  def level_debug,  do: 7
  def level_info,   do: 6
  def level_notice, do: 5
  def level_warn,   do: 4
  def level_err,    do: 3
  def level_crit,   do: 2
  def level_alert,  do: 1
  def level_emerg,  do: 0
  
end

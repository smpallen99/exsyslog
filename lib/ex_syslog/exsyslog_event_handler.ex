defmodule ExSyslog.EventHandler do
  import ExPrintf
  import ExSyslog.Util, only: [get_env: 2, put_env: 2]

  use GenEvent.Behaviour 
  use Bitwise

  defmodule State do 
    defstruct level: 2, host: :undefined, socket: nil, port: 0, 
              hostname: nil, appid: nil, facility: 0
    def new, do: %State{}
    def new(opts), do: struct(new, opts)
  end

  def level do
    :gen_event.call(:error_logger, ExSyslog.EventHandler, :level)
  end

  def level(level) do
    :gen_event.call(:error_logger, ExSyslog.EventHandler, {:set_level, level})
  end

  def status() do
    :gen_event.call(:error_logger, ExSyslog.EventHandler, :status)
  end

  def init([]) do
    {:ok, socket} = :gen_udp.open(0)
    {:ok, :ok, state} = handle_call(:load_config, State.new(socket: socket))
    {:ok, state} 
  end

  def handle_call({:set_level, level}, state) do
    put_env :level, level
    {:ok, :ok, struct(state, level: level)}
  end

  def handle_call(:level, %State{level: level} = state) do
    {:ok, level, state}
  end
  def handle_call(:status, state) do
    {:ok, state, state}
  end

  def handle_call(:load_config, state) do
    host = case :inet.getaddr(get_env(:host, :undefined), :inet) do
      {:ok, address} -> address
      {:error, _} -> :undefined
    end
    [hostname | _] = String.split("#{:net_adm.localhost()}", ".")
    opts = [
      host: host, 
      port: get_env(:port, 514),
      hostname: hostname,
      os_pid: :os.getpid(),
      appid: get_env(:appid, "exsyslog"),
      facility: ExSyslog.Util.facility(get_env(:facility, :local2)),
      level: ExSyslog.Util.level(get_env(:level, :info)),
    ] 
    {:ok, :ok, struct(state, opts)}
  end

  def handle_event(%ExSyslog.Message{level: level, msg: msg, msgid: msgid, pid: pid}, state) do
    write(level, msgid, msg, pid, state)
    {:ok, state}
  end

  def handle_event({class, _gl, {pid, format, args}}, %State{level: max} = state) do
    case otp_event_level(class, format) do
      :undefined -> 
        {:ok, state}
      level when level > max -> 
        {:ok, state}
      level -> 
        {msgid, msg} = message(format, args)
        write(level, msgid, msg, pid, state)
        #IO.puts "event --> class: #{inspect class}, pid: #{inspect pid}, format: #{inspect format}, args: #{inspect args}"
        {:ok, state}
    end
  end

  def handle_event({:log, msg}, state) do
    IO.puts "--> #{msg}"
    {:ok, state}
  end

  def write(level, :undefined, msg, pid, state) do
    write(level, '-----------', msg, pid, state)
  end

  def write(level, msgid, msg, pid, state) when is_list(msg) or is_binary(msg) do
    %State{facility: facil, appid: app, hostname: hostname, host: host, port: port, socket: socket} = state
    pre = :io_lib.format('<~B>~s ~s~p: ~s - ', [facil ||| level,
      ExSyslog.Util.iso8601_timestamp, app, pid, msgid])
    send_msg(socket, host, port, [pre, msg, '\n'])
  end

  def write(_, :undefined, packet), do: IO.puts packet
  
  def send_msg(_, :undefined, _, packet) do
    :io.format('~s', [packet])
  end

  def send_msg(socket, host, port, packet) do
    :gen_udp.send(socket, host, port, packet)
  end

  def message(type, report) when type in [:std_error, :std_info, :std_warning, :progress_report, :progress] do
    {type, ExSyslog.Util.format('~2048.0p', [report])}
  end

  def message(:crash_report, report) do
    msg = if :erts_debug.flat_size(report) > get_env(:max_term_size, 8192) do
      max_string = get_env(:max_message_size, 16000)
      ['*Truncated* - ', :trunc_io.print(report, max_string)]
    else
      :proc_lib.format(report)
    end
    {:crash_report, msg}
  end
  def message(:supervisor_report, report) do
    name = get_value(:supervisor, report)
    error = get_value(:errorcontext, report)
    reason = get_value(:reason, report)
    offender = get_value(:offender, report)
    childpid = get_value(:pid, offender)
    childname = get_value(:name, offender)
    case get_value(:mfa, offender) do
      :undefined ->
          {m,f,_} = get_value(:mfargs, offender)
      {m,f,_} ->
          :ok
    end
    {:supervisor_report, ExSyslog.Util.format('~p ~p (~p) child: ~p [~p] ~p:~p',
            [name, error, reason, childname, childpid, m, f])};
  end

  def message(format, args) when is_list(format) do
    {:msg, ExSyslog.Util.format(format, args)}
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
  
  def get_value(key, props) do
    case :lists.keyfind(key, 1, props) do
      {key, value} ->
        value
      false ->
        :undefined
    end
  end
end

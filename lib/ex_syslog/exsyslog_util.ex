defmodule ExSyslog.Util do
  import ExPrintf
  use Bitwise

  def level(:debug),   do: 7
  def level(:info),    do: 6
  def level(:notice),  do: 5
  def level(:warn),    do: 4
  def level(:warning), do: 4
  def level(:err),     do: 3
  def level(:error),   do: 3
  def level(:crit),    do: 2
  def level(:alert),   do: 1
  def level(:emerg),   do: 0
  def level(:panic),   do: 0
  def level(:none),    do: 0
  
  def level(i) when is_integer(i) when i >= 0 and i <= 7, do: i
  def level(_bad), do: 3

  def format(level, format, data) when is_list(data) do
    level = String.upcase "#{level}"
    sprintf("%s: %s", [level, format])
    |> sprintf(data)
    |> format([])
  end

  def format(format, data) do
    max_term_size = get_env :max_term_size, 8192
    if :erts_debug.flat_size(data) > max_term_size do
      max_string = get_env :max_message_size, 16000
      {truncated, _} = :trunc_io.print(data, max_string)
      ["*Truncated* ", format, " - ", truncated]
    else
      :io_lib.format(format, data)
    end
  end

  def iso8601_timestamp do
    {_,_,micro} = now = :os.timestamp()
    {{_year,month,date},{hour,minute,second}} = :calendar.now_to_datetime(now)
    mstr = elem({"Jan","Feb","Mar","Apr","May","Jun","Jul", "Aug","Sep","Oct","Nov","Dec"}, month)
    sprintf("%s %02d %02d:%02d:%02d", [mstr, date, hour, minute, second])
  end

  def get_env(key, default), do: Application.get_env(:exsyslog, key, default)
  def put_env(key, value), do: Application.put_env(:exsyslog, key, value)

  def facility(:kern),      do:  (0 <<< 3) # % kernel messages
  def facility(:user),      do:  (1 <<< 3) # % random user-level messages
  def facility(:mail),      do:  (2 <<< 3) # % mail system
  def facility(:daemon),    do:  (3 <<< 3) # % system daemons
  def facility(:auth),      do:  (4 <<< 3) # % security/authorization messages
  def facility(:syslog),    do:  (5 <<< 3) # % messages generated internally by syslogd
  def facility(:lpr),       do:  (6 <<< 3) # % line printer subsystem
  def facility(:news),      do:  (7 <<< 3) # % network news subsystem
  def facility(:uucp),      do:  (8 <<< 3) # % UUCP subsystem
  def facility(:cron),      do:  (9 <<< 3) # % clock daemon
  def facility(:authpriv),  do:  (10 <<< 3)# % security/authorization messages (private)
  def facility(:ftp),       do:  (11 <<< 3) # % ftp daemon

  def facility(:local0),    do:  (16 <<< 3)
  def facility(:local1),    do:  (17 <<< 3)
  def facility(:local2),    do:  (18 <<< 3)
  def facility(:local3),    do:  (19 <<< 3)
  def facility(:local4),    do:  (20 <<< 3)
  def facility(:local5),    do:  (21 <<< 3)
  def facility(:local6),    do:  (22 <<< 3)
  def facility(:local7),    do:  (23 <<< 3)
end

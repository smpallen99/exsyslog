defmodule ExSyslog.Logger do

  import ExPrintf

  @info_level  ExSyslog.Util.level(:info)

  def set_level(level_atom) do
    level = ExSyslog.Util.level(level_atom)      
    Application.put_env :exsyslog, :level, level
    #:gen_event.call(:error_logger, :exsyslog_event_handler, {:set_level, level})
  end

  def log(level_atom, string), do: log(level_atom, string, [])

  def log(level_atom, category, format, data) when is_atom(category) do
    category = String.upcase "#{category}"
    log level_atom, sprintf("<<%s>> -- %s", [category, format]), data
  end  

  def log(level_atom, category, string) when is_atom(category) do
    log(level_atom, category, string, [])
  end

  def log(level_atom, format, data) do
    level = ExSyslog.Util.level(level_atom)      
    case Application.get_env :exsyslog, :level do
      nil when level <= @info_level ->  
        send_message(level_atom, format, data)
      threshold when level <= threshold ->  
        send_message(level_atom, format, data)
      _ -> 
        :ok
    end 
  end

  def send_message(level, format, data) do
    :gen_event.notify(:error_logger, format(level, format, data))
    #IO.puts format(level, format, data)
  end

  def format(level, format, data) when is_list(data) do
    [ level: level, msg: ExSyslog.Util.format(level, format, data), pid: self ]
    |> ExSyslog.Message.new
  end
  
end

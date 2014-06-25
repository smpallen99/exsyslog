defmodule ExSyslog.Logger do

  import ExPrintf
  import ExSyslog.Util, only: [get_env: 2]

  @info_level  ExSyslog.Util.level(:info)

  def level(level_atom) do
    level = ExSyslog.Util.level(level_atom)      
    #Application.put_env :exsyslog, :level, level
    ExSyslog.EventHandler.level level
  end

  def level() do
    get_env(:level, :undefined)
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
  end

  def format(level, format, data) when is_list(data) do
    [ level: ExSyslog.Util.level(level), msg: ExSyslog.Util.format(level, format, data), pid: self ]
    |> ExSyslog.Message.new
  end
  
end

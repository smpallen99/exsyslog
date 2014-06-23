defmodule ExSyslog.Util do
  import ExPrintf

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
  
  def level(i) when is_integer(i) when i >= 0 and i <= 7, do: i
  def level(_bad), do: 3

  def format(level, format, data) when is_list(data) do
    level = String.upcase "#{level}"
    sprintf("%s: %s", [level, format])
    |> sprintf(data)
  end
end

defmodule ExsyslogTest do
  use ExUnit.Case
  alias ExSyslog.Logger, as: ExLog

  defmodule MyStruct do
    defstruct one: 1
  end

  test "logs inspected structs" do
    str = inspect(%MyStruct{})
    ExLog.log :none, str
  end
end

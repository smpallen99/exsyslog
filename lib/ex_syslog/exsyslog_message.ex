defmodule ExSyslog.Message do
  defstruct level: 0, msg: "", msgid: :erlang.get(:nonce), pid: nil

  def new, do: %ExSyslog.Message{}
  def new(opts), do: struct(new, opts)
end

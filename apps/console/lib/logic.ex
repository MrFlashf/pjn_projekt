defmodule Console.Logic do

  def execute(command) do
    {resp, _} = System.cmd("bash", ["../test.sh", command])
    handle_response(resp)
  end

  def handle_response(response) do

  end

  def kill(system_pid) do
    System.cmd("kill", [system_pid])
  end
end

defmodule Console.Logic do
  alias Console.ProgramsServer

  def execute({command, arguments}) do
    System.cmd(command, arguments)

    pid =
      :os.cmd(:"ps -ao %cpu,pid,args | grep 'opera' | sort --reverse | head -1 | awk '{ print $2 }'")
      |> to_string()
      |> String.replace("\n", "")

    ProgramsServer.add_program(command, pid)
    :ok
  end

  def kill_by_name(name) do
    case ProgramsServer.get_program_pid(name) do
      {:ok, pid} ->
        :ok = kill(pid)
      {:error, :not_found} ->
        {:error, :not_found}
    end
  end


  def kill(system_pid) do
    return = System.cmd("kill", [system_pid])
    IO.inspect return
    :ok
  end
end

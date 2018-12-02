defmodule Console.Logic do
  alias Console.ProgramsServer


  def execute({"kill", program_name}) do
    :ok = kill_by_name(program_name)
  end

  def execute({command, arguments}) do
    spawn(System, :cmd, [command, arguments])

    pid = get_pid(command)

    ProgramsServer.add_program(command, pid)
    :ok
  end

  def kill_by_name(name) do
    case ProgramsServer.get_program_pid(name) do
      {:ok, pid} ->
        :ok = kill(pid)
        ProgramsServer.delete_pid_from_state(pid)
      {:error, :not_found} ->
        {:error, :not_found}
    end
  end


  def kill(system_pid) do
    System.cmd("kill", [system_pid])
    :ok
  end

  defp get_pid(command) do
    pid =
      :os.cmd(:"ps -ao %cpu,pid,args | grep #{command} | sort --reverse | head -1 | awk '{ print $2 }'")
      |> to_string()
      |> String.replace("\n", "")

    new_pid =
      case pid do
        "" ->
          :os.cmd(:"ps -aux | grep #{command} | head -1 | awk '{ print $2 }'")
          |> to_string()
          |> String.replace("\n", "")
        _correct_pid ->
          pid
      end

    new_pid
  end
end

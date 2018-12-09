defmodule Console.Logic do
  alias Console.ProgramsServer

  def execute({"kill", program_name}) do
    :ok = kill_by_name(program_name)
  end

  def execute({command, arguments, program}) do
    spawn(System, :cmd, [command, arguments])

    pid = get_pid_for_platform(program)

    program_lowercased = String.downcase(program)

    ProgramsServer.add_program(program_lowercased, pid)
    {:ok, program_lowercased}
  end

  def execute({command, arguments}) do
    spawn(System, :cmd, [command, arguments])

    pid = get_pid_for_platform(command)

    command_lowercased = String.downcase(command)

    ProgramsServer.add_program(command_lowercased, pid)
    {:ok, command_lowercased}
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

  defp get_pid(command, :linux) do
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

  defp get_pid(command, :mac) do
    IO.inspect command
    _pid =
      :os.cmd(:"python lswin.py | grep #{command} | head -1| awk '{print $1}'")
      |> to_string()
      |> String.replace("\n", "")
    # IO.puts "PID: #{pid}"
  end

  defp get_pid_for_platform(command) do
    case :os.type do
      {_, :linux} ->
        get_pid(command, :linux)
      {_, :darwin} ->
        get_pid(command, :mac)
    end
  end
end

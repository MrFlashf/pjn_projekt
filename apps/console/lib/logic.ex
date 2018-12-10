defmodule Console.Logic do
  alias Console.ProgramsServer

  def execute({"kill", program_or_thing}) do
    case kill_by_name(program_or_thing) do
      :ok ->
        {:ok, :kill, program_or_thing}
      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  def execute({command, arguments, program, what}) do
    {_, status} = System.cmd(command, arguments)

    case status do
      0 ->
        pid = get_pid_for_platform(program)

        program_lowercased = String.downcase(program)

        ProgramsServer.add_program(program_lowercased, what, pid)
        {:ok, program_lowercased}
      _err_code ->
        # look for file
        # try_to_find_file(what)
        {:error, :cant_open}
    end
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

  # defp try_to_find_file({command, arguments, program, what}) do
  #   {path, _} = System.cmd("find", [".", "-name", "#{what}*"])
  #   parsed_path =
  #     path
  #     |> String.replace("\n", "")

  #   case parsed_path do
  #     "" ->
  #       {:error, :cant_open}
  #     _ ->


  #       execute(command, arguments, program, )
  #   end
  # end

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
      |> IO.inspect
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

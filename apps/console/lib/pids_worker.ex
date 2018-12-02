defmodule Console.PidsWorker do
  use GenServer

  alias Console.ProgramsServer

  @name __MODULE__
  @time 2000

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  def handle_info(:start, state) do
    check_for_pids()
    Process.send_after(self(), :start, @time)
    {:noreply, state}
  end

  def check_for_pids() do
    pids = ProgramsServer.get_pids()

    Enum.each(pids, fn pid ->
      ret =
        :os.cmd(:"ps -aux | grep #{pid} | head -1 | awk '{ print $2 }'")
        |> to_string()
        |> String.replace("\n", "")

      if ret != pid do
        ProgramsServer.delete_pid_from_state(pid)
      end
    end)
  end

  def init(_) do
    Process.send_after(self(), :start, @time)
    {:ok, []}
  end
end

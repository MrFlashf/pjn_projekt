defmodule Console.ProgramsServer do
  use GenServer

  @name __MODULE__

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: @name)
  end
  def add_program(name, system_pid) do
    tuple = {name, system_pid}

    GenServer.cast(__MODULE__, {:add_program, tuple})
  end

  def get_program_pid(program_name) do
    GenServer.call(@name, {:get_pid, program_name})
  end

  def is_program_open?(name) do
    GenServer.call(@name, {:is_open, name})
  end

  @spec get_state() :: any()
  def get_state() do
    _programs = GenServer.call(@name, :get)
  end

  @spec get_pids() :: any()
  def get_pids() do
    _pids = GenServer.call(@name, :get_pids)
  end

  def delete_pid_from_state(pid) do
    GenServer.cast(@name, {:delete_pid, pid})
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:get_pids, _from, state) do
    pids =
      state
      |> Enum.map(fn {_program, pid} -> pid end)

    {:reply, pids, state}
  end

  def handle_call({:is_open, name}, _from, state) do
    message =
      case Map.get(state, name) do
        nil ->
          false
        _program_data ->
          true
      end

    {:reply, message, state}
  end

  def handle_call({:get_pid, program_name}, _from, state) do
    program_data = Map.get(state, program_name)
    IO.inspect state
    message =
      case program_data do
        nil ->
          {:error, :not_found}
        _program_data ->
          {:ok, state[program_name]}
      end

    {:reply, message, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @doc """
    program_data is a tuple containing {program_name, program_pid}
  """
  def handle_cast({:add_program, {program_name, program_pid}}, state) do
    new_state =
      case Map.get(state, program_name) do
        nil ->
          Map.put(state, program_name, program_pid)
        _ ->
          state
      end

    {:noreply, new_state}
  end

  def handle_cast({:delete_pid, pid}, state) do
    new_state =
      state
      |> Enum.reject(fn {_program, pr_pid} -> pr_pid == pid end)
      |> Enum.into(%{})

    {:noreply, new_state}
  end
end

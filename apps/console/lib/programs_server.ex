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

  def get_state() do
    _programs = GenServer.call(__MODULE__, :get)
  end

  def init(_) do
    {:ok, %{}}
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

end

defmodule ConsoleController do
  alias Console.Parser
  alias Console.Logic

  @spec do_something(binary()) :: :ok
  def do_something(user_input) do
    command = Parser.parse(user_input)
    Logic.execute(command)
  end
end

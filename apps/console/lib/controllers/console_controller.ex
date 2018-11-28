defmodule Console.Constrollers.ConsoleController do
  alias Console.Parser
  alias Console.Logic

  def do_something(user_input) do
    command = Parser.parse(user_input)
    Logic.execute(command)
  end
end

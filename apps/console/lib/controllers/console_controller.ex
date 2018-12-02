defmodule Console.Controllers.ConsoleController do
  alias Console.Parser
  alias Console.Logic

  def do_something(user_input) do
    command = Parser.parse(user_input)
    IO.inspect command
    Logic.execute(command)
  end
end

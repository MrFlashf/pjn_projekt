defmodule Console.Constrollers.ConsoleController do
  alias Console.Parser
  alias Console.Logic

  def input(string) do
    command = Parser.parse(string)
    Logic.execute(command)

  end
end

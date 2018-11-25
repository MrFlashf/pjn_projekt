defmodule Console.Constrollers.ConsoleController do
  alias Console.Parser

  def input(string) do
    command = Parser.parse(string)

  end
end

defmodule ConsoleControllerTest do
  use ExUnit.Case
  doctest ConsoleController

  test "greets the world" do
    assert ConsoleController.hello() == :world
  end
end

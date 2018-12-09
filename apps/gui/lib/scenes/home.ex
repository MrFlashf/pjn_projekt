defmodule Gui.Scene.Home do
  use Scenic.Scene

  import Scenic.Components

  alias Scenic.Graph
  # alias Console.Controllers.ConsoleController
  alias Console.ProgramsServer
  alias Console.Parser
  alias Console.Logic

  import Scenic.Primitives

  @graph Graph.build(font: :roboto, font_size: 24)
  |> text("Open programs:", t: {500, 50})
  |> text_field("", id: :text, width: 500, hint: "Type here...", t: {200, 160})
  |> button("Execute", id: :btn_primary, theme: :primary, t: {200, 200})

  def init(_, _) do
    push_graph(@graph)
    {:ok, %{graph: @graph, text: "", programs: []}}
  end

  def filter_event({:value_changed, :text, new_text} = event, _, state) do
    {:continue, event, %{state | text: new_text}}
  end

  def filter_event({:click, :btn_primary} = event, _, state) do
    {:ok, program} = make_action(state.text)

    height = state.programs |> length() |>  Kernel.*(100)

    programs = ProgramsServer.get_programs()

    # new_graph = Enum.reduce(programs, state.graph, fn program, graph ->
    #   graph
    #   |> button("X", id: "close_#{program}", theme: :danger, width: 20, t: {500, height})
    #   |> text(program, t: {550, height})
    # end)

    # new_graph =
    #   state.graph
    #   |> button("X", id: "close_#{program}", theme: :danger, width: 20, t: {500, height})
    #   |> text(program, t: {550, height})
    state.graph
    |> add_programs_to_graph(programs, 1)
    |> push_graph()

    {:continue, event, state}
  end

  def filter_event(event, _, state) do
    IO.inspect event
    {:continue, event, state}
  end

  defp make_action(text) do
    command = Parser.parse(text)
    Logic.execute(command)
  end

  defp add_programs_to_graph(graph, [] = _programs, index) do
    graph
  end
  defp add_programs_to_graph(graph, [head | tail] = _programs, index) do
    height = 100 * index
    graph
    |> button("X", id: "close_#{head}", theme: :danger, width: 20, t: {500, height-20})
    |> text(head, t: {550, height})
    |> add_programs_to_graph(tail, index + 1)
  end
end

defmodule Gui.Scene.Home do
  use Scenic.Scene

  import Scenic.Components

  alias Scenic.Graph
  alias Console.ProgramsServer
  alias Console.Parser
  alias Console.Logic

  import Scenic.Primitives

  @graph Graph.build(font: :roboto, theme: :light)
  |> line({{498, 0}, {498, 800}}, stroke: {4, :black})
  |> group(fn g ->
    g
    |> text("Waiting for commands...", id: :response_text, t: {120, 100}, fill: :black)
    |> text_field("", width: 300, id: :text, t: {25, 500}, font_size: 10)
    |> button("Execute", id: :btn_primary, theme: :primary, width: 100, t: {200, 540})
  end)
  |> group(
    fn g ->
      g
      |> text("Open programs:", fill: :black, t: {180, 0})
    end,
    t: {502,20}
  )

  def init(_, _) do
    push_graph(@graph)
    watch_programs(@graph)
    {:ok, %{graph: @graph, text: "", programs: []}}
  end

  def filter_event({:value_changed, :text, new_text} = event, _, state) do
    {:continue, event, %{state | text: new_text}}
  end

  def filter_event({:click, :btn_primary} = event, _, state) do
    new_graph =
      case make_action(state.text) do
        {:error, :dont_understand} ->
          new_graph =
            state.graph
            |> Graph.modify(:response_text, &text(&1, "Sorry, did not understand"))

            push_graph(new_graph)

          new_graph

        {:error, :not_found} ->
          new_graph =
            state.graph
            |> Graph.modify(:response_text, &text(&1, "Program you want to close doesn't exist", t: {50, 100}))

            push_graph(new_graph)

          new_graph

        {:error, :cant_open} ->
          new_graph =
            state.graph
            |> Graph.modify(:response_text, &text(&1, "Sorry, couldn't find file you requested", t: {50, 100}))

            push_graph(new_graph)

          new_graph

        {:ok, program} ->
          new_graph =
            state.graph
            |> Graph.modify(:response_text, &text(&1, "OK, using #{program}"))

          programs = ProgramsServer.get_programs_with_arg()

          new_graph
          |> add_programs_to_graph(programs, 1)
          |> push_graph()

          new_graph

        {:ok, :kill, program} ->
          new_graph =
            state.graph
            |> Graph.modify(:response_text, &text(&1, "OK, closed #{program}"))

          programs = ProgramsServer.get_programs_with_arg()

          new_graph
          |> add_programs_to_graph(programs, 1)
          |> push_graph()

          new_graph
      end

    {:continue, event, %{state | graph: new_graph}}
  end

  def filter_event({:click, "close_" <> what} = event, _, state) do
    Logic.execute({"kill", what}) |> IO.inspect

    new_graph =
      state.graph
      |> Graph.modify(:response_text, &text(&1, "Closing #{what}"))

    programs = ProgramsServer.get_programs_with_arg()

    new_graph
    |> add_programs_to_graph(programs, 1)
    |> push_graph()

    {:continue, event, %{state | graph: new_graph}}
  end

  def filter_event(event, _, state) do
    IO.inspect event
    {:continue, event, state}
  end

  defp make_action(text) do
    case Parser.parse(text) do
      {:error, :dont_understand} ->
        {:error, :dont_understand}
      command ->
        Logic.execute(command)
    end
  end

  defp add_programs_to_graph(graph, [] = _programs, _index) do
    graph
  end
  defp add_programs_to_graph(graph, [head | tail] = _programs, index) do
    {program, what} = head
    height = 100 * index
    graph
    |> button("X", id: "close_#{program}", theme: :danger, width: 30, t: {520, height-20})
    |> text("#{program} - #{what}", t: {570, height}, fill: :black)
    |> add_programs_to_graph(tail, index + 1)
  end

  defp watch_programs(graph) do
    programs = ProgramsServer.get_programs_with_arg()

    add_programs_to_graph(graph, programs, 1)
    |> push_graph()

    Process.send_after(self(), :watch, 500)
  end

  def handle_info(:watch, state) do
    watch_programs(state.graph)
    {:noreply, state}
  end
end

defmodule Gui.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives
  # import Scenic.Components

  @note """
    What can I do for you?
  """

  @graph Graph.build(font: :roboto, font_size: 24)
  |> text(@note, translate: {230, 60})

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(_, _) do
    push_graph( @graph )
    {:ok, @graph}
  end
end

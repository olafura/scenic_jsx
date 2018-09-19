defmodule TestComponent do
  use Scenic.Component
  require ScenicJsx
  import ScenicJsx

  alias Scenic.ViewPort
  alias Scenic.Graph

  import Scenic.Primitives, only: [{:text, 3}]

  def verify(text) when is_bitstring(text), do: {:ok, text}
  def verify(_), do: :invalid_data

  def init(text, opts) do
    styles = opts[:styles] || %{}

    # Get the viewport width
    {:ok, %ViewPort.Status{size: {width, _}}} =
      opts[:viewport]
      |> ViewPort.info()

    graph = ~z(
        <text>#{text}</text>
      )
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end
end

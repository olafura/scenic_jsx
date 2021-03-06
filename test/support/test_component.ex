defmodule TestComponent do
  use Scenic.Component
  require ScenicJsx
  import ScenicJsx

  import Scenic.Primitives, only: [{:text, 3}]

  def verify(text) when is_bitstring(text), do: {:ok, text}
  def verify(_), do: :invalid_data

  def init(text, opts) do
    graph =
      ~z(
        <text>#{text}</text>
      )
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end
end

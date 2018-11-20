defmodule TestComponent do
  use Scenic.Component
  use ScenicJsx

  import Scenic.Primitives, only: [{:text, 3}]

  def verify(text) when is_bitstring(text), do: {:ok, text}
  def verify(_), do: :invalid_data

  def init(text, opts) do
    graph =
      ~x(
        <text>#{text}</text>
      )
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end
end

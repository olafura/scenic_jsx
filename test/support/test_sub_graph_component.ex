defmodule TestSubGraphComponent do
  use Scenic.Component
  require ScenicJsx
  import ScenicJsx

  import Scenic.Primitives, only: [{:text, 3}]

  def verify(sub_graph_list) when is_list(sub_graph_list), do: {:ok, sub_graph_list}
  def verify(_), do: :invalid_data

  def init(sub_graphs, opts) do
    graph =
      ~z(
        <>
         <text/>
         #{ScenicJsx.map_sub_graph(sub_graphs)}
        </>
      )
      |> push_graph()

    {:ok, %{graph: graph, viewport: opts[:viewport]}}
  end
end

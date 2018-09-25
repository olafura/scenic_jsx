defmodule ScenicJsxTest do
  use ExUnit.Case
  require ScenicJsx
  import ScenicJsx

  import Scenic.Primitives

  doctest ScenicJsx

  test "test simple jsx" do
    assert {:ok, _} =
             ~z(<foo something=#{{1, 1}}><bar2 something="a"/><a>2</a></foo>)raw
             |> parse_jsx()
  end

  test "test basic scenic graph" do
    assert %Scenic.Graph{} = ~z(
      <>
        <text id=#{:temperature} text_align=#{:center} font_size=#{160}>Testing</text>
      </>
    )
  end

  test "test basic scenic graph with group" do
    assert %Scenic.Graph{} = ~z(
      <>
        <text/>
        <>
          <text id=#{:temperature} text_align=#{:center} font_size=#{160}>
            Testing
          </text>
        </>
        <text/>
      </>
    )
  end

  test "test basic scenic graph with elixir data" do
    string = "Testing"
    assert %Scenic.Graph{} = ~z(
      <>
        <text id=#{:temperature} text_align=#{:center} font_size=#{160}>#{string}</text>
      </>
    )
  end

  test "test basic scenic graph module" do
    assert %Scenic.Graph{} = ~z(
      <TestComponent>Testing</TestComponent>
    )
  end

  test "test basic scenic sub graph module" do
    assert %Scenic.Graph{} = ~z(
      <TestSubGraphComponent>
        <text>Passed in</text>
      </TestSubGraphComponent>
    )
  end

  test "test map_sub_graph" do
    sub_graphs = [
      fn graph -> graph |> text("Passed in", []) end
    ]

    assert %Scenic.Graph{} = ~z(
      <>
        <text/>
        #{ScenicJsx.map_sub_graph(sub_graphs)}
      </>
    )
  end

  test "test basic scenic graph with build options" do
    assert %Scenic.Graph{} = ~z(
      <font_size=#{20} translate=#{{0, 10}}>
        <text id=#{:temperature} text_align=#{:center} font_size=#{160}>Testing</text>
      </>
    )
  end
end

defmodule ScenicJsxTest do
  use ExUnit.Case
  use ScenicJsx

  import Scenic.Primitives
  import Scenic.Components

  doctest ScenicJsx

  test "test simple jsx" do
    assert {:ok, _} =
             ~x(<foo something=#{{1, 1}}><bar2 something="a"/><a>2</a></foo>)raw
             |> parse_exx()
  end

  test "test basic scenic graph" do
    assert %Scenic.Graph{} = ~x(
      <>
        <text id=#{:temperature} text_align=#{:center} font_size=#{160}>Testing</text>
      </>
    )
  end

  test "test basic scenic graph with group" do
    assert %Scenic.Graph{} = ~x(
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
    assert %Scenic.Graph{} = ~x(
      <>
        <text id=#{:temperature} text_align=#{:center} font_size=#{160}>#{string}</text>
      </>
    )
  end

  test "test basic scenic graph module" do
    assert %Scenic.Graph{} = ~x(
      <TestComponent>Testing</TestComponent>
    )
  end

  test "test basic scenic sub graph module" do
    assert %Scenic.Graph{} = ~x(
      <TestSubGraphComponent>
        <text>Passed in</text>
      </TestSubGraphComponent>
    )
  end

  test "test map_sub_graph" do
    sub_graphs = [
      fn graph -> graph |> text("Passed in", []) end
    ]

    assert %Scenic.Graph{} = ~x(
      <>
        <text/>
        #{ScenicJsx.map_sub_graph(sub_graphs)}
      </>
    )
  end

  test "test basic scenic graph with build options" do
    assert %Scenic.Graph{} = ~x(
      <font_size=#{20} translate=#{{0, 10}}>
        <text id=#{:temperature} text_align=#{:center} font_size=#{160}>Testing</text>
      </>
    )
  end

  test "test basic scenic graph with group options" do
    assert %Scenic.Graph{} = ~x(
      <>
        <font_size=#{20} translate=#{{0, 10}}>
          <text translate=#{{15, 60}} id=#{:event}>Event received</text>
          <text id=#{:temperature} text_align=#{:center} font_size=#{160}>Testing</text>
        </>
      </>
    )
  end

  test "test advanced scenic graph with group options" do
    assert %Scenic.Graph{} = ~x(
      <font=#{:roboto} font_size=#{24} theme=#{:dark}>
        <translate=#{{0, 20}}>
         <text translate=#{{15, 20}}>Various components</text>
         <text>Event received</text>
         <text_field width=#{240} hint="Type here" translate=#{{200, 160}}>A</text_field>
         <text_field hint=#{"Type here"}>A</text_field>
         <button id=#{:btn_crash} theme=#{:danger} t=#{{370, 0}}>Crash</button>
         <t=#{{15, 74}}>
           <translate=#{{0, 10}}>
             <button id=#{:btn_primary} theme=#{:primary}>Primary</button>
             <button id=#{:btn_success} t=#{{90, 0}} theme=#{:success}>Success</button>
             <button id=#{:btn_info} t=#{{180, 0}} theme=#{:info}>Info</button>
             <button id=#{:btn_light} t=#{{270, 0}} theme=#{:light}>Light</button>
             <button id=#{:btn_warning} t=#{{360, 0}} theme=#{:warning}>Warning</button>
             <button id=#{:btn_dark} t=#{{0, 40}} theme=#{:dark}>Dark</button>
             <button id=#{:btn_text} t=#{{90, 40}} theme=#{:text}>Text</button>
             <button id=#{:btn_danger} theme=#{:danger} t=#{{180, 40}}>Danger</button>
             <button id=#{:btn_secondary} width=#{100} t=#{{270, 40}} theme=#{:secondary}>
               Secondary
             </button>
           </>
           <slider id=#{:num_slider} t=#{{0, 95}}>#{{{0, 100}, 0}}</slider>
             <checkbox id=#{:check_box} t=#{{200, 140}}>#{{"Check Box", true}}</checkbox>
             <text_field id=#{:text} width=#{240} translate=#{{200, 160}}>A</text_field>
             <text_field id=#{:password} width=#{240} translate=#{{200, 200}}>A</text_field>
             <dropdown id=#{:dropdown} translate=#{{0, 202}}>
               #{
                {
                  [{"Choice 1", :choice_1}, {"Choice 2", :choice_2}, {"Choice 3", :choice_3}],
                  :choice_1
                }
               }
             </dropdown>
         </>
       </>
     </>
    )
  end
end

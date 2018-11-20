defmodule ScenicJsxTest do
  use ExUnit.Case
  use ScenicJsx

  import Scenic.Primitives
  import Scenic.Components

  doctest ScenicJsx

  test "test simple jsx" do
    assert {:ok,
            [
              {:element, ["foo", {:attribute, ["something", {1, 1}]}],
               [
                 {:element, ["bar2", {:attribute, ["something", "a"]}], []},
                 {:element, ["a"], ["2"]}
               ]}
            ]} =
             ~x(<foo something=#{{1, 1}}><bar2 something="a"/><a>2</a></foo>)raw
             |> parse_exx()
  end

  test "test basic scenic graph" do
    assert %Scenic.Graph{
      add_to: 0,
      ids: %{_root_: [0], temperature: [1]},
      next_uid: 2,
      primitives: %{
        0 => %{
      __struct__: Scenic.Primitive,
      data: [1],
      module: Scenic.Primitive.Group,
      parent_uid: -1
    },
        1 => %{
          __struct__: Scenic.Primitive,
          data: "Testing",
          id: :temperature,
          module: Scenic.Primitive.Text,
          parent_uid: 0,
          styles: %{font_size: 160, text_align: :center}
        }
      }
    } = ~x(
      <>
        <text id=#{:temperature} text_align=#{:center} font_size=#{160}>Testing</text>
      </>
    )
  end

  test "test basic scenic graph with group" do
    assert %Scenic.Graph{
             add_to: 0,
             ids: %{_root_: [0], temperature: [3]},
             next_uid: 5,
             primitives: %{
               0 => %{
                 __struct__: Scenic.Primitive,
                 data: [1, 2, 4],
                 module: Scenic.Primitive.Group,
                 parent_uid: -1
               },
               1 => %{
                 __struct__: Scenic.Primitive,
                 data: "",
                 module: Scenic.Primitive.Text,
                 parent_uid: 0
               },
               2 => %{
                 __struct__: Scenic.Primitive,
                 data: [3],
                 module: Scenic.Primitive.Group,
                 parent_uid: 0
               },
               3 => %{
                 __struct__: Scenic.Primitive,
                 data: "Testing",
                 id: :temperature,
                 module: Scenic.Primitive.Text,
                 parent_uid: 2,
                 styles: %{font_size: 160, text_align: :center}
               },
               4 => %{
                 __struct__: Scenic.Primitive,
                 data: "",
                 module: Scenic.Primitive.Text,
                 parent_uid: 0
               }
             }
           } = ~x(
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
    assert %Scenic.Graph{
             add_to: 0,
             ids: %{_root_: [0], temperature: [1]},
             next_uid: 2,
             primitives: %{
               0 => %{
                 __struct__: Scenic.Primitive,
                 data: [1],
                 module: Scenic.Primitive.Group,
                 parent_uid: -1
               },
               1 => %{
                 __struct__: Scenic.Primitive,
                 data: "Testing",
                 id: :temperature,
                 module: Scenic.Primitive.Text,
                 parent_uid: 0,
                 styles: %{font_size: 160, text_align: :center}
               }
             }
           } = ~x(
      <>
        <text id=#{:temperature} text_align=#{:center} font_size=#{160}>#{string}</text>
      </>
    )
  end

  test "test basic scenic graph module" do
    assert %Scenic.Graph{
             add_to: 0,
             ids: %{_root_: [0]},
             next_uid: 2,
             primitives: %{
               0 => %{
                 __struct__: Scenic.Primitive,
                 data: [1],
                 module: Scenic.Primitive.Group,
                 parent_uid: -1
               },
               1 => %{
                 __struct__: Scenic.Primitive,
                 data: {TestComponent, "Testing"},
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 0
               }
             }
           } = ~x(
      <TestComponent>Testing</TestComponent>
    )
  end

  test "test basic scenic sub graph module" do
    assert %Scenic.Graph{
             add_to: 0,
             ids: %{_root_: [0]},
             next_uid: 2,
             primitives: %{
               0 => %{
                 __struct__: Scenic.Primitive,
                 data: [1],
                 module: Scenic.Primitive.Group,
                 parent_uid: -1
               },
               1 => %{
                 __struct__: Scenic.Primitive,
                 data: {TestSubGraphComponent, _}
               }
             }
           } = ~x(
      <TestSubGraphComponent>
        <text>Passed in</text>
      </TestSubGraphComponent>
    )
  end

  test "test map_sub_graph" do
    sub_graphs = [
      fn graph -> graph |> text("Passed in", []) end
    ]

    assert %Scenic.Graph{
             add_to: 0,
             ids: %{_root_: [0]},
             next_uid: 4,
             primitives: %{
               0 => %{
                 __struct__: Scenic.Primitive,
                 data: [1, 2],
                 module: Scenic.Primitive.Group,
                 parent_uid: -1
               },
               1 => %{
                 __struct__: Scenic.Primitive,
                 data: "",
                 module: Scenic.Primitive.Text,
                 parent_uid: 0
               },
               2 => %{
                 __struct__: Scenic.Primitive,
                 data: [3],
                 module: Scenic.Primitive.Group,
                 parent_uid: 0
               },
               3 => %{
                 __struct__: Scenic.Primitive,
                 data: "Passed in",
                 module: Scenic.Primitive.Text,
                 parent_uid: 2
               }
             }
           } = ~x(
      <>
        <text/>
        #{ScenicJsx.map_sub_graph(sub_graphs)}
      </>
    )
  end

  test "test basic scenic graph with build options" do
    assert %Scenic.Graph{
             add_to: 0,
             ids: %{_root_: [0], temperature: [1]},
             next_uid: 2,
             primitives: %{
               0 => %{
                 __struct__: Scenic.Primitive,
                 data: [1],
                 module: Scenic.Primitive.Group,
                 parent_uid: -1,
                 styles: %{font_size: 20},
                 transforms: %{translate: {0, 10}}
               },
               1 => %{
                 __struct__: Scenic.Primitive,
                 data: "Testing",
                 id: :temperature,
                 module: Scenic.Primitive.Text,
                 parent_uid: 0,
                 styles: %{font_size: 160, text_align: :center}
               }
             }
           } = ~x(
      <font_size=#{20} translate=#{{0, 10}}>
        <text id=#{:temperature} text_align=#{:center} font_size=#{160}>Testing</text>
      </>
    )
  end

  test "test basic scenic graph with group options" do
    assert %Scenic.Graph{
             add_to: 0,
             ids: %{_root_: [0], event: [2], temperature: [3]},
             next_uid: 4,
             primitives: %{
               0 => %{
                 __struct__: Scenic.Primitive,
                 data: [1],
                 module: Scenic.Primitive.Group,
                 parent_uid: -1
               },
               1 => %{
                 __struct__: Scenic.Primitive,
                 data: [2, 3],
                 module: Scenic.Primitive.Group,
                 parent_uid: 0,
                 styles: %{font_size: 20},
                 transforms: %{translate: {0, 10}}
               },
               2 => %{
                 __struct__: Scenic.Primitive,
                 data: "Event received",
                 id: :event,
                 module: Scenic.Primitive.Text,
                 parent_uid: 1,
                 transforms: %{translate: {15, 60}}
               },
               3 => %{
                 __struct__: Scenic.Primitive,
                 data: "Testing",
                 id: :temperature,
                 module: Scenic.Primitive.Text,
                 parent_uid: 1,
                 styles: %{font_size: 160, text_align: :center}
               }
             }
           } = ~x(
      <>
        <font_size=#{20} translate=#{{0, 10}}>
          <text translate=#{{15, 60}} id=#{:event}>Event received</text>
          <text id=#{:temperature} text_align=#{:center} font_size=#{160}>Testing</text>
        </>
      </>
    )debug
  end

  test "test advanced scenic graph with group options" do
    assert %Scenic.Graph{
             add_to: 0,
             ids: %{
               _root_: [0],
               btn_crash: [6],
               btn_danger: [16],
               btn_dark: [14],
               btn_info: '\v',
               btn_light: '\f',
               btn_primary: '\t',
               btn_secondary: [17],
               btn_success: '\n',
               btn_text: [15],
               btn_warning: '\r',
               check_box: [19],
               dropdown: [22],
               num_slider: [18],
               password: [21],
               text: [20]
             },
             next_uid: 23,
             primitives: %{
               0 => %{
                 __struct__: Scenic.Primitive,
                 data: [1],
                 module: Scenic.Primitive.Group,
                 parent_uid: -1,
                 styles: %{font: :roboto, font_size: 24, theme: :dark}
               },
               1 => %{
                 __struct__: Scenic.Primitive,
                 data: [2, 3, 4, 5, 6, 7],
                 module: Scenic.Primitive.Group,
                 parent_uid: 0,
                 transforms: %{translate: {0, 20}}
               },
               2 => %{
                 __struct__: Scenic.Primitive,
                 data: "Various components",
                 module: Scenic.Primitive.Text,
                 parent_uid: 1,
                 transforms: %{translate: {15, 20}}
               },
               3 => %{
                 __struct__: Scenic.Primitive,
                 data: "Event received",
                 module: Scenic.Primitive.Text,
                 parent_uid: 1
               },
               4 => %{
                 __struct__: Scenic.Primitive,
                 data: {Scenic.Component.Input.TextField, "A"},
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 1,
                 styles: %{hint: "Type here", width: 240},
                 transforms: %{translate: {200, 160}}
               },
               5 => %{
                 __struct__: Scenic.Primitive,
                 data: {Scenic.Component.Input.TextField, "A"},
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 1,
                 styles: %{hint: "Type here"}
               },
               6 => %Scenic.Primitive{
                 data: {Scenic.Component.Button, "Crash"},
                 id: :btn_crash,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 1,
                 styles: %{t: {370, 0}, theme: :danger},
                 transforms: %{translate: {370, 0}}
               },
               7 => %{
                 __struct__: Scenic.Primitive,
                 data: [8, 18, 19, 20, 21, 22],
                 module: Scenic.Primitive.Group,
                 parent_uid: 1,
                 styles: %{t: {15, 74}},
                 transforms: %{translate: {15, 74}}
               },
               8 => %{
                 __struct__: Scenic.Primitive,
                 data: [9, 10, 11, 12, 13, 14, 15, 16, 17],
                 module: Scenic.Primitive.Group,
                 parent_uid: 7,
                 transforms: %{translate: {0, 10}}
               },
               9 => %{
                 __struct__: Scenic.Primitive,
                 data: {Scenic.Component.Button, "Primary"},
                 id: :btn_primary,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 8,
                 styles: %{theme: :primary}
               },
               10 => %Scenic.Primitive{
                 data: {Scenic.Component.Button, "Success"},
                 id: :btn_success,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 8,
                 styles: %{t: {90, 0}, theme: :success},
                 transforms: %{translate: {90, 0}}
               },
               11 => %Scenic.Primitive{
                 data: {Scenic.Component.Button, "Info"},
                 id: :btn_info,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 8,
                 styles: %{t: {180, 0}, theme: :info},
                 transforms: %{translate: {180, 0}}
               },
               12 => %Scenic.Primitive{
                 data: {Scenic.Component.Button, "Light"},
                 id: :btn_light,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 8,
                 styles: %{t: {270, 0}, theme: :light},
                 transforms: %{translate: {270, 0}}
               },
               13 => %Scenic.Primitive{
                 data: {Scenic.Component.Button, "Warning"},
                 id: :btn_warning,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 8,
                 styles: %{t: {360, 0}, theme: :warning},
                 transforms: %{translate: {360, 0}}
               },
               14 => %Scenic.Primitive{
                 data: {Scenic.Component.Button, "Dark"},
                 id: :btn_dark,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 8,
                 styles: %{t: {0, 40}, theme: :dark},
                 transforms: %{translate: {0, 40}}
               },
               15 => %Scenic.Primitive{
                 data: {Scenic.Component.Button, "Text"},
                 id: :btn_text,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 8,
                 styles: %{t: {90, 40}, theme: :text},
                 transforms: %{translate: {90, 40}}
               },
               16 => %Scenic.Primitive{
                 data: {Scenic.Component.Button, "Danger"},
                 id: :btn_danger,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 8,
                 styles: %{t: {180, 40}, theme: :danger},
                 transforms: %{translate: {180, 40}}
               },
               17 => %Scenic.Primitive{
                 data: {Scenic.Component.Button, "Secondary\n             "},
                 id: :btn_secondary,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 8,
                 styles: %{t: {270, 40}, theme: :secondary, width: 100},
                 transforms: %{translate: {270, 40}}
               },
               18 => %Scenic.Primitive{
                 data: {Scenic.Component.Input.Slider, {{0, 100}, 0}},
                 id: :num_slider,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 7,
                 styles: %{t: {0, 95}},
                 transforms: %{translate: {0, 95}}
               },
               19 => %Scenic.Primitive{
                 data: {Scenic.Component.Input.Checkbox, {"Check Box", true}},
                 id: :check_box,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 7,
                 styles: %{t: {200, 140}},
                 transforms: %{translate: {200, 140}}
               },
               20 => %Scenic.Primitive{
                 data: {Scenic.Component.Input.TextField, "A"},
                 id: :text,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 7,
                 styles: %{width: 240},
                 transforms: %{translate: {200, 160}}
               },
               21 => %Scenic.Primitive{
                 data: {Scenic.Component.Input.TextField, "A"},
                 id: :password,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 7,
                 styles: %{width: 240},
                 transforms: %{translate: {200, 200}}
               },
               22 => %{
                 __struct__: Scenic.Primitive,
                 data:
                   {Scenic.Component.Input.Dropdown,
                    {[
                       {"Choice 1", :choice_1},
                       {"Choice 2", :choice_2},
                       {"Choice 3", :choice_3}
                     ], :choice_1}},
                 id: :dropdown,
                 module: Scenic.Primitive.SceneRef,
                 parent_uid: 7,
                 transforms: %{translate: {0, 202}}
               }
             }
           } =
             ~x(
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

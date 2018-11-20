defmodule ScenicJsx.Transform do
  @moduledoc """
  Documentation for ScenicJsx.
  """

  def create_graph(jsx_ast, options) do
    {quoted_main_graph, quoted_sub_graphs} = element_to_quoted(jsx_ast, {[], []}, options)
    new_quoted_sub_graph = new_sub_graphs(quoted_sub_graphs, options)
    new_quoted_main_graph = new_graph_piped(quoted_main_graph, options)

    quote do
      unquote(new_quoted_sub_graph)
      unquote(new_quoted_main_graph)
    end
  end

  def new_sub_graphs(sub_graphs, options) do
    sub_graphs
    |> Enum.map(fn {atom, graph} ->
      {:=, [], [{atom, [], nil}, new_group_function(List.wrap(graph))]}
    end)
    |> block(options)
  end

  def block([], _options) do
    nil
  end

  def block(quoted, _options) do
    {:__block__, [], quoted}
  end

  # 1
  # 2
  # 1
  # 5
  # 1
  # 4
  # 8
  # 1
  # 9
  # 8
  # 1
  # 9

  # 1
  # 2
  # 1
  # 5
  # 1
  # 6
  # 1
  # 5
  # 1
  # 9

  # 1
  # 2
  # 1
  # 8
  # 1
  # 6
  # 1
  # 8
  # 1
  # 9
  # 8
  # 1


  # def element_to_quoted(elements, {main_graph, sub_graph}, options) when is_list(elements) do
  #   IO.puts(1)
  #   Enum.reduce(elements, {main_graph, sub_graph}, &element_to_quoted(&1, &2, options))
  # end

  # def element_to_quoted({:element, [], children}, {[], []}, %{start: true} = options) do
  #   IO.puts(2)
  #   options = Map.delete(options, :start)
  #   element_to_quoted(children, {[start_graph()], []}, options)
  # end

  # def element_to_quoted({:element, [{:attribute, _} | _] = attributes, children}, {[], []}, %{start: true} = options) do
  #   IO.puts(3)
  #   options = Map.delete(options, :start)
  #   quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted(&1, &2, options)) |> Enum.reverse()
  #   element_to_quoted(children, {[start_graph(quoted_attributes)], []}, options)
  # end

  # def element_to_quoted({:element, _, _children} = element, {[], []}, options) do
  #   IO.puts(4)
  #   element_to_quoted(element, {[start_graph()], []}, options)
  # end

  # def element_to_quoted({:element, [{:attribute, _} | _] = attributes, children}, {main_graph, sub_graph}, options) do
  #   IO.puts(5)
  #   quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted(&1, &2, options)) |> Enum.reverse()

  #   {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []}, options)

  #   new_graph = new_group(List.delete_at(quoted_children, -1), quoted_attributes)

  #   {[new_graph | List.wrap(main_graph)], sub_graph ++ quote_children_sub_graph}
  # end

  # def element_to_quoted({:element, [], children}, {main_graph, sub_graph}, options) do
  #   IO.puts(6)
  #   {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []}, options)

  #   new_graph = new_group(List.delete_at(quoted_children, -1))

  #   {[new_graph | List.wrap(main_graph)], sub_graph ++ quote_children_sub_graph}
  # end

  # def element_to_quoted(
  #       {:element, [<<x0::integer, _rest::binary>> = module_name | attributes], children},
  #       {main_graph, sub_graph},
  #       %{caller: caller} = options
  #     )
  #     when x0 >= ?A and x0 <= ?Z do
  #   IO.puts(7)
  #   {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []}, options)

  #   {new_quoted_children, new_sub_graph} = process_children(quoted_children, module_name)
  #   atom_module_name = String.to_atom("Elixir." <> module_name)
  #   aliases = Map.new(caller.aliases)
  #   the_alias = Map.get(aliases, atom_module_name, false)

  #   quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted(&1, &2, options)) |> Enum.reverse()

  #   new_graph =
  #     {{:., [], [{:__aliases__, [alias: the_alias], [atom_module_name]}, :add_to_graph]},
  #      [], [new_quoted_children, quoted_attributes]}

  #   {[new_graph | List.wrap(main_graph)], sub_graph ++ quote_children_sub_graph ++ new_sub_graph}
  # end

  # def element_to_quoted(
  #       {:element, [function_name | attributes], children},
  #       {main_graph, sub_graph},
  #       options
  #     ) when is_binary(function_name) do
  #   IO.puts(8)
  #   {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []}, options)

  #   {new_quoted_children, new_sub_graph} = process_children(quoted_children, function_name)

  #   quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted(&1, &2, options)) |> Enum.reverse()
  #   new_graph =
  #     case new_quoted_children do
  #       [] ->
  #         {String.to_atom(function_name), [], [quoted_attributes]}
  #       [other] ->
  #         {String.to_atom(function_name), [], [other, quoted_attributes]}
  #       other ->
  #         {String.to_atom(function_name), [], [other, quoted_attributes]}
  #     end

  #   {[new_graph | List.wrap(main_graph)], sub_graph ++ quote_children_sub_graph ++ new_sub_graph}
  # end

  # # This is for text or other element
  # def element_to_quoted(other, {[], []}, _options) do
  #   IO.puts(9)
  #   {other, []}
  # end

  # def element_to_quoted(other, {main_graph, sub_graph}, _options) do
  #   IO.puts(10)
  #   {[other | List.wrap(main_graph)], sub_graph}
  # end

  def element_to_quoted(elements, {main_graph, sub_graph}, options) when is_list(elements) do
    IO.puts(1)
    IO.inspect([elements, main_graph, sub_graph])
    Enum.reduce(elements, {main_graph, sub_graph}, &element_to_quoted(&1, &2, options))
  end

  def element_to_quoted(%Exx.Fragment{attributes: attributes, children: children}, {[], []}, %{start: true} = options) when map_size(attributes) === 0 do
    IO.puts(2)
    options = Map.delete(options, :start)
    element_to_quoted(children, {[start_graph()], []}, options)
  end

  def element_to_quoted(%Exx.Fragment{attributes: attributes, children: children}, {[], []}, %{start: true} = options) do
    IO.puts(3)
    options = Map.delete(options, :start)
    quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted(&1, &2, options)) |> Enum.reverse()
    element_to_quoted(children, {[start_graph(quoted_attributes)], []}, options)
  end

  def element_to_quoted(%{attributes: attributes} = fragment, {[], []}, options) when map_size(attributes) === 0 do
    IO.puts(4)
    element_to_quoted(fragment, {[start_graph()], []}, options)
  end

  # {:element,
  #  ["text", {:attribute, ["translate", {15, 60}]}, {:attribute, ["id", :event]}],
  #  ["Event received"]}

  def element_to_quoted(%Exx.Fragment{attributes: attributes, children: children}, {main_graph, sub_graph}, options) when map_size(attributes) === 0 do
    IO.puts(6)
    {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []}, options)

    new_graph = new_group(List.delete_at(quoted_children, -1))

    {[new_graph | List.wrap(main_graph)], sub_graph ++ quote_children_sub_graph}
  end

  def element_to_quoted(%{attributes: attributes, children: children}, {main_graph, sub_graph}, options) do
    IO.puts(5)
    quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted(&1, &2, options)) |> Enum.reverse()

    {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []}, options)

    new_graph = new_group(List.delete_at(quoted_children, -1), quoted_attributes)

    {[new_graph | List.wrap(main_graph)], sub_graph ++ quote_children_sub_graph}
  end

  def element_to_quoted(%Exx.Element{attributes: attributes, children: children, type: :module, name: module_name}, {main_graph, sub_graph}, %{caller: caller} = options) do
    IO.puts(7)
    {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []}, options)

    {new_quoted_children, new_sub_graph} = process_children(quoted_children, module_name)
    atom_module_name = String.to_atom("Elixir." <> module_name)
    aliases = Map.new(caller.aliases)
    the_alias = Map.get(aliases, atom_module_name, false)

    quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted(&1, &2, options)) |> Enum.reverse()

    new_graph =
      {{:., [], [{:__aliases__, [alias: the_alias], [atom_module_name]}, :add_to_graph]},
       [], [new_quoted_children, quoted_attributes]}

    {[new_graph | List.wrap(main_graph)], sub_graph ++ quote_children_sub_graph ++ new_sub_graph}
  end

  def element_to_quoted(%Exx.Element{attributes: attributes, children: children, type: :tag, name: function_name}, {main_graph, sub_graph}, options) do
    IO.puts(8)
    {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []}, options)

    {new_quoted_children, new_sub_graph} = process_children(quoted_children, function_name)

    quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted(&1, &2, options)) |> Enum.reverse()
    new_graph =
      case new_quoted_children do
        [] ->
          {String.to_atom(function_name), [], [quoted_attributes]}
        [other] ->
          {String.to_atom(function_name), [], [other, quoted_attributes]}
        other ->
          {String.to_atom(function_name), [], [other, quoted_attributes]}
      end

    {[new_graph | List.wrap(main_graph)], sub_graph ++ quote_children_sub_graph ++ new_sub_graph}
  end

  # This is for text or other element
  def element_to_quoted(other, {[], []}, _options) do
    IO.puts(9)
    {other, []}
  end

  def element_to_quoted(other, {main_graph, sub_graph}, _options) do
    IO.puts(10)
    {[other | List.wrap(main_graph)], sub_graph}
  end

  def process_children([], "text") do
    {"", []}
  end

  def process_children([], "text_field") do
    {"", []}
  end

  def process_children([], _) do
    {[], []}
  end

  def process_children(list, _) when is_list(list) do
    case List.last(list) do
      {{:., _, [{:__aliases__, _, [:Scenic, :Graph]}, :build]}, _, _} ->
        id = sub_graph_id()
        {[{id, [], nil}], [{id, list}]}
      _ ->
        {list, []}
    end
  end

  def process_children(other, _) do
    {other, []}
  end

  def keyword_list_to_quoted_varible(list) when is_list(list) do
    list
    |> Keyword.keys()
    |> Enum.map(&{&1, [], nil})
  end

  def sub_graph_id() do
    uuid = UUID.uuid4()

    "sub_graph_#{uuid}"
    |> String.replace("-", "_")
    |> String.to_atom()
  end

  def new_group_function(quoted_children) do
    {:fn, [],
      [
        {:->, [],
        [
          [{:graph, [], nil}],
          to_pipe(quoted_children ++ [{:graph, [], nil}])
        ]}
      ]}
  end

  def new_group(quoted_children, options \\ []) do
    {:group, [],[new_group_function(quoted_children), options]}
  end

  def attribute_to_quoted({attribute_name, attribute_value}, acc, _options) do
    [{String.to_atom(attribute_name), attribute_value} | acc]
  end

  def start_graph(options \\ []) do
    quote do
      Scenic.Graph.build(unquote(options))
    end
  end

  def to_pipe([head | []]) do
    head
  end

  def to_pipe([head | tail]) do
    {:|>, [], [to_pipe(tail), head]}
  end

  defp new_graph_piped(quoted_graph, _options) do
    to_pipe(List.wrap(quoted_graph))
  end
end

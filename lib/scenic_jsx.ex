defmodule ScenicJsx do
  @moduledoc """
  Documentation for ScenicJsx.
  """
  import NimbleParsec

  whitespace = ascii_string([?\s, ?\n], max: 100)

  tag =
    ascii_char([?a..?z, ?A..?Z])
    |> reduce({Kernel, :to_string, []})
    |> concat(optional(ascii_string([?a..?z, ?_, ?0..?9, ?A..?Z, not: ?=], min: 1)))
    |> ignore(whitespace)
    |> reduce({Enum, :join, [""]})

  text =
    ignore(whitespace)
    |> utf8_string([not: ?<], min: 1)

  sub =
    string("$")
    |> concat(ascii_string([?0..?9], min: 1))
    |> traverse({:sub_context, []})

  quote_string = string("\"")

  quoted_attribute_text =
    ignore(whitespace)
    |> repeat_until(
      choice([
        ~s(\") |> string() |> replace(?'),
        utf8_char([])
      ]),
      [ascii_char([?"])]
    )
    |> ignore(quote_string)
    |> reduce({List, :to_string, []})
    |> label("quoted_attribute_text")

  attribute =
    ignore(whitespace)
    |> concat(tag)
    |> ignore(string("="))
    |> choice([quoted_attribute_text, sub])
    |> label("attribute")
    |> tag(:attribute)

  opening_tag =
    ignore(whitespace)
    |> ignore(string("<"))
    |> concat(tag)
    |> repeat_until(
      choice([attribute, ascii_char([?>]), string("/>")]),
      [ascii_char([?>]), string("/>")]
    )
    |> ignore(optional(string(">")))
    |> ignore(whitespace)
    |> label("opening_tag")
    |> tag(:element)

  empty_tag =
    ignore(whitespace)
    |> ignore(string("<"))
    |> repeat_until(
      choice([attribute, ascii_char([?>]), string("/>")]),
      [ascii_char([?>]), string("/>")]
    )
    |> ignore(string(">"))
    |> ignore(whitespace)
    |> label("empty_tag")
    |> tag(:element)

  closing_tag =
    ignore(whitespace)
    |> ignore(string("</"))
    |> optional(tag)
    |> ignore(string(">"))
    |> ignore(whitespace)
    |> label("closing_tag")
    |> tag(:closing_tag)

  self_closing =
    ignore(whitespace)
    |> ignore(string("/>"))
    |> ignore(whitespace)

  defparsec(
    :parse_xml,
    parsec(:xml)
  )

  defcombinatorp(
    :xml,
    choice([empty_tag, opening_tag])
    |> repeat_until(choice([parsec(:xml), sub, text]), [string("</"), string("/>")])
    |> choice([closing_tag, self_closing])
    |> reduce({:fix_element, []})
  )

  def parse_jsx(jsx) do
    {bin, context} = list_to_context(jsx)

    with {:ok, results, _, _, _, _} <- parse_xml(String.trim(bin), context: context) do
      {:ok, results}
    end
  end

  def list_to_context(list) when is_list(list) do
    {_, context, acc_list} =
      list
      |> Enum.reduce({1, [], []}, fn
        bin, {index, context, acc_list} when is_binary(bin) ->
          {index, context, [bin | acc_list]}

        other, {index, context, acc_list} ->
          ref = "$#{index}"
          {index + 1, [{ref, other} | context], [ref | acc_list]}
      end)

    {acc_list |> Enum.reverse() |> Enum.join(), Enum.into(context, %{})}
  end

  def list_to_context(bin) when is_binary(bin) do
    {bin, %{}}
  end

  defmacro sigil_z({:<<>>, _meta, pieces}, 'raw') do
    pieces
    |> Enum.map(&clean_litteral/1)
  end

  defmacro sigil_z({:<<>>, _meta, pieces}, 'parse') do
    pieces
    |> Enum.map(&clean_litteral/1)
    |> parse_jsx()
    |> IO.inspect()

    nil
  end

  defmacro sigil_z({:<<>>, _meta, pieces}, 'debug') do
    {:ok, jsx} =
      pieces
      |> Enum.map(&clean_litteral/1)
      |> parse_jsx()

    ast = create_graph(jsx)
    ast |> Macro.to_string() |> Code.format_string!() |> IO.puts()
    ast
  end

  defmacro sigil_z({:<<>>, _meta, pieces}, '') do
    {:ok, jsx} =
      pieces
      |> Enum.map(&clean_litteral/1)
      |> parse_jsx()

    create_graph(jsx)
  end

  def create_graph(jsx_ast) do
    {quoted_main_graph, quoted_sub_graphs} = element_to_quoted(jsx_ast, {[], []})
    new_quoted_sub_graph = new_sub_graphs(quoted_sub_graphs)
    new_quoted_main_graph = new_graph_piped(quoted_main_graph)

    quote do
      unquote(new_quoted_sub_graph)
      unquote(new_quoted_main_graph)
    end
  end

  def new_sub_graphs(sub_graphs) do
    sub_graphs
    |> Enum.map(fn {atom, graph} ->
      {:=, [], [{atom, [], nil}, new_group_function(List.wrap(graph))]}
    end)
    |> block()
  end

  def block([]) do
    nil
  end

  def block(quoted) do
    {:__block__, [], quoted}
  end

  def element_to_quoted(elements, {main_graph, sub_graph}) when is_list(elements) do
    Enum.reduce(elements, {main_graph, sub_graph}, &element_to_quoted/2)
  end

  def element_to_quoted({:element, [], children}, {[], []}) do
    element_to_quoted(children, {[start_graph()], []})
  end

  def element_to_quoted({:element, [{:attribute, _} | _] = attributes, children}, {[], []}) do
    quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted/2) |> Enum.reverse()
    element_to_quoted(children, {[start_graph(quoted_attributes)], []})
  end

  def element_to_quoted({:element, _, _children} = element, {[], []}) do
    element_to_quoted(element, {[start_graph()], []})
  end

  def element_to_quoted({:element, [], children}, {main_graph, sub_graph}) do
    {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []})

    new_graph = new_group(List.delete_at(quoted_children, -1))

    {[new_graph | main_graph], sub_graph ++ quote_children_sub_graph}
  end

  def element_to_quoted(
        {:element, [<<x0::integer, _rest::binary>> = module_name | attributes], children},
        {main_graph, sub_graph}
      )
      when x0 >= ?A and x0 <= ?Z do
    {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []})

    {new_quoted_children, new_sub_graph} = process_children(quoted_children, module_name)

    quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted/2) |> Enum.reverse()

    new_graph =
      {{:., [], [{:__aliases__, [alias: false], [String.to_atom(module_name)]}, :add_to_graph]},
       [], [new_quoted_children, quoted_attributes]}

    {[new_graph | main_graph], sub_graph ++ quote_children_sub_graph ++ new_sub_graph}
  end

  def element_to_quoted(
        {:element, [function_name | attributes], children},
        {main_graph, sub_graph}
      ) do
    {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []})

    {new_quoted_children, new_sub_graph} = process_children(quoted_children, function_name)

    quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted/2) |> Enum.reverse()
    new_graph =
      case new_quoted_children do
        [] ->
          {String.to_atom(function_name), [], [quoted_attributes]}
        other ->
          {String.to_atom(function_name), [], [other, quoted_attributes]}
      end

    {[new_graph | main_graph], sub_graph ++ quote_children_sub_graph ++ new_sub_graph}
  end

  # This is for text or other element
  def element_to_quoted(other, {[], []}) do
    {other, []}
  end

  def element_to_quoted(other, {main_graph, sub_graph}) do
    {[other | main_graph], sub_graph}
  end

  def map_sub_graph(graph, sub_graph_functions) do
    Enum.reduce(sub_graph_functions, graph, fn sf, g -> Scenic.Primitives.group(g, sf, []) end)
  end

  def process_children([], "text") do
    {"", []}
  end

  def process_children([], _) do
    {[], []}
  end

  def process_children(list, _) when is_list(list) do
    new_sub_graph =
      list
      |> Enum.map(fn graph ->
        {sub_graph_id(), graph}
      end)

    {keyword_list_to_quoted_varible(new_sub_graph), new_sub_graph}
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

  def new_group(quoted_children) do
    {:group, [],[new_group_function(quoted_children)]}
  end

  def attribute_to_quoted({:attribute, [attribute_name, attribute_value]}, acc) do
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

  defp new_graph_piped(quoted_graph) do
    # to_pipe(List.wrap(quoted_graph) ++ [start_graph()])
    to_pipe(List.wrap(quoted_graph))
    # |> IO.inspect(label: 3)
  end

  defp fix_element([element | nested]) do
    tag = elem(element, 1) |> List.first()
    {closing_tag, new_nested} = List.pop_at(nested, -1)

    if not (is_nil(closing_tag) or tag === "" or is_tuple(tag) or {:closing_tag, List.wrap(tag)} === closing_tag) do
      with {:closing_tag, cl_tag} <- closing_tag do
        raise "Closing tag doesn't match opening tag open_tag: #{inspect(tag)} closing_tag: #{inspect(cl_tag)}"
      else
        _ ->
          raise "Closing tag doesn't match opening tag open_tag: #{inspect(tag)} closing_tag: #{inspect(closing_tag)}"
      end
    end

    Tuple.append(element, new_nested)
  end

  defp fix_element(other) do
    other
  end

  defp sub_context(_rest, args, context, _line, _offset) do
    ref = args |> Enum.reverse() |> Enum.join()
    {context |> Map.get(ref) |> List.wrap(), context}
  end

  defp clean_litteral(
         {:::, _, [{{:., _, [Kernel, :to_string]}, _, [litteral]}, {:binary, _, nil}]}
       ) do
    litteral
  end

  defp clean_litteral(other) do
    other
  end
end

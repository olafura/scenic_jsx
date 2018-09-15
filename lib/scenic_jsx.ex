defmodule ScenicJsx do
  @moduledoc """
  Documentation for ScenicJsx.
  """
  require SweetXml
  import NimbleParsec

  tag =
    ascii_string([?a..?z], max: 1)
    |> concat(optional(ascii_string([?a..?z, ?_, ?0..?9], min: 1)))
    |> reduce({Enum, :join, [""]})

  text = ascii_string([not: ?<], min: 1)

  sub =
    string("$")
    |> concat(ascii_string([?0..?9], min: 1))
    |> traverse({:sub_context, []})

  quote_string = string("\"")

  quoted_attribute_text =
    ignore(quote_string)
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
    ignore(string(" "))
    |> concat(tag)
    |> ignore(string("="))
    |> choice([quoted_attribute_text, sub])
    |> label("attribute")
    |> tag(:attribute)

  opening_tag =
    ignore(string("<"))
    |> concat(tag)
    |> repeat_until(
      choice([attribute, ascii_char([?>]), string("/>")]),
      [ascii_char([?>]), string("/>")]
    )
    |> ignore(optional(string(">")))
    |> label("opening_tag")
    |> tag(:element)

  closing_tag =
    ignore(string("</"))
    |> concat(tag)
    |> ignore(string(">"))
    |> label("closing_tag")

  defparsec(
    :parse_xml,
    parsec(:xml)
  )

  def parse_jsx(jsx) do
    {bin, context} = list_to_context(jsx)

    with {:ok, results, _, _, _, _} <- parse_xml__0(bin, [], [], context, {1, 0}, 0) do
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

  defcombinatorp(
    :xml,
    opening_tag
    |> repeat_until(choice([parsec(:xml), text]), [string("</"), string("/>")])
    |> choice([closing_tag, ignore(string("/>"))])
    |> reduce({:fix_element, []})
  )

  defmacro sigil_z({:<<>>, _meta, pieces}, 'raw') do
    pieces
    |> Enum.map(&clean_litteral/1)
  end

  defmacro sigil_z({:<<>>, _meta, pieces}, '') do
    {:ok, jsx} =
      pieces
      |> Enum.map(&clean_litteral/1)
      |> parse_jsx()

    create_graph(jsx)
  end

  def create_graph(jsx_ast) do
    {quoted_main_graph, quote_sub_graph} = element_to_quoted(jsx_ast, {[], []})
    new_quoted_main_graph = to_pipe(quoted_main_graph ++ [start_graph])
  end

  def element_to_quoted(elements, {main_graph, sub_graph}) when is_list(elements) do
    Enum.reduce(elements, {main_graph, sub_graph}, &element_to_quoted/2)
  end

  def element_to_quoted({:element, [""], children}, {[], []}) do
    element_to_quoted(children, {[], []})
  end

  def element_to_quoted({:element, [""], children}, {main_graph, sub_graph}) do
    {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []})

    new_graph =
      {:group, [],
       [
         {:fn, [],
          [
            {:->, [],
             [
               [{:graph, [], nil}],
               to_pipe(quoted_children ++ [{:graph, [], nil}])
             ]}
          ]}
       ]}

    {[new_graph | main_graph], sub_graph}
  end

  def element_to_quoted(
        {:element, [function_name | attributes], children},
        {main_graph, sub_graph}
      ) do
    {quoted_children, quote_children_sub_graph} = element_to_quoted(children, {[], []})

    new_quoted_children =
      case quoted_children do
        [] ->
          ""

        other ->
          other
      end

    quoted_attributes = Enum.reduce(attributes, [], &attribute_to_quoted/2) |> Enum.reverse()
    new_graph = {String.to_atom(function_name), [], [new_quoted_children, quoted_attributes]}
    {[new_graph | main_graph], sub_graph}
  end

  # This is for text or other element
  def element_to_quoted(other, {[], []}) do
    {other, []}
  end

  def attribute_to_quoted({:attribute, [attribute_name, attribute_value]}, acc) do
    [{String.to_atom(attribute_name), attribute_value} | acc]
  end

  def start_graph() do
    quote do
      Scenic.Graph.build()
    end
  end

  def to_pipe([head | []]) do
    head
  end

  def to_pipe([head | tail]) do
    {:|>, [], [to_pipe(tail), head]}
  end

  defp fix_element([element | nested]) do
    tag = elem(element, 1) |> List.first()
    {closing_tag, new_nested} = List.pop_at(nested, -1)

    if not (is_nil(closing_tag) or tag === "" or tag === closing_tag) do
      raise "Closing tag doesn't match opening tag"
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

defmodule ScenicJsxTest do
  use ExUnit.Case
  require ScenicJsx
  import ScenicJsx

  doctest ScenicJsx

  test "test simple jsx" do
    assert {:ok, _} =
             ~z[<foo something=#{{1, 1}}><bar2 something="a"/><a>2</a></foo>]
             |> ScenicJsx.parse_jsx()
  end
end

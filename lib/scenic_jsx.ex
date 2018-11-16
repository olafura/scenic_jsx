defmodule ScenicJsx do
  @moduledoc """
  Documentation for ScenicJsx.
  """
  import Exx, only: [do_sigil_x: 4]

  def process_exx(eex, caller) do
    ScenicJsx.Transform.create_graph(eex, %{caller: caller, start: true})
  end

  defmacro __using__(_opts) do
    quote do
       import Exx, except: [sigil_x: 2]
       require ScenicJsx
       import ScenicJsx
     end
  end

  defmacro sigil_x(params, options) do
    caller = __CALLER__
    # IO.inspect(caller.module, label: :caller)
    # IO.inspect(__MODULE__)
    module = __MODULE__
    do_sigil_x(params, options, caller, module)
  end
end

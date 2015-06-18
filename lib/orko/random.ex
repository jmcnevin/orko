defmodule Random do
  def init do
    :random.seed(:erlang.now)
  end

  def pick_element(list) do
    Enum.at(list, :random.uniform(length(list)) - 1)
  end
end

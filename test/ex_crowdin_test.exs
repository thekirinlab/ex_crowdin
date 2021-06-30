defmodule ExCrowdinTest do
  use ExUnit.Case
  doctest ExCrowdin

  test "greets the world" do
    assert ExCrowdin.hello() == :world
  end
end

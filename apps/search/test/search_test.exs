defmodule SearchTest do
  use ExUnit.Case
  doctest Search

  test "greets the world" do
    assert Search.hello() == :world
  end
end

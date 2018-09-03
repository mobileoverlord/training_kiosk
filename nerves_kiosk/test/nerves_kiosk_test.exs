defmodule NervesKioskTest do
  use ExUnit.Case
  doctest NervesKiosk

  test "greets the world" do
    assert NervesKiosk.hello() == :world
  end
end

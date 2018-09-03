defmodule NervesKiosk do
  @moduledoc """
  Documentation for NervesKiosk.
  """

  @doc """
  Hello world.

  ## Examples

      iex> NervesKiosk.hello
      :world

  """

  require Logger

  def hello do
    Logger.debug("Hello")
    :world
  end
end

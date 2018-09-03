defmodule PhxKioskWeb.HomeChannel do
  use PhxKioskWeb, :channel

  require Logger

  @from_range 1..100
  @to_range 15..255

  def join("home:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("brightness", %{"value" => value} = payload, socket) do
    Logger.debug("Brightness: #{inspect value}")
    broadcast socket, "brightness", payload

    map_range(@from_range, @to_range, value)
    |> PhxKiosk.Backlight.set_brightness()
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (home:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    brightness = 
      map_range(@to_range, @from_range, PhxKiosk.Backlight.brightness())
    push(socket, "brightness", %{value: brightness})
    {:noreply, socket}
  end

  defp map_range(a1 .. a2, b1 .. b2, s) do
    b1 + (s - a1) * (b2 - b1) / (a2 - a1)
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end

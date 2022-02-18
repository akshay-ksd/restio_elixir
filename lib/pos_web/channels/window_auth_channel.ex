defmodule PosWeb.WindowAuthChannel do
  use PosWeb, :channel

  intercept ["widows_auth","login_complete"]

  def join("windows_app:" <> _qrid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("widows_auth", %{"data" => data}, socket) do

      broadcast!(socket, "widows_auth", %{"data" => data})

      {:noreply, socket}
  end

  def handle_in("login_complete", %{"data" => data}, socket) do

      broadcast!(socket, "login_complete", %{"data" => data})

      {:noreply, socket}
  end

  def handle_out("widows_auth", payload, socket) do
      push(socket, "widows_auth", payload)
      {:noreply, socket}
  end

  def handle_out("login_complete", payload, socket) do
    push(socket, "login_complete", payload)
    {:noreply, socket}
  end
end

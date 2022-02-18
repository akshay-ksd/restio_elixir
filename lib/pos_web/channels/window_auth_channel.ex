defmodule PosWeb.WindowAuthChannel do
  use PosWeb, :channel
  alias Pos.Staff

  intercept ["widows_auth"]

  def join("windows_app:" <> _qrid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("widows_auth", %{"data" => data}, socket) do
      utoken = data["utoken"]
      rtoken = data["rtoken"]
      active_token = data["active_token"]

      staff_data = Staff.staffAuth(utoken, rtoken, active_token)

      auth_data = %{"staff_data" => staff_data, "data" => data}
      broadcast!(socket, "widows_auth", %{"auth_data" => auth_data})

      {:noreply, socket}
  end

  def handle_out("widows_auth", payload, socket) do
      push(socket, "widows_auth", payload)
      {:noreply, socket}
  end
end

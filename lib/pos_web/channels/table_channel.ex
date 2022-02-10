defmodule PosWeb.TableChannel do
  use PosWeb, :channel
  alias Pos.Restaurent

  intercept ["addTable"]

  def join("table:" <> _restaurentid, _params, socket) do
    {:ok, %{"status" => true}, socket}
  end

  def handle_in("addTable", %{"data" => data}, socket) do
    token = data["token"]
    tableCount = data["count"]

    Restaurent.updateTableCount(token, tableCount)

    broadcast!(socket, "addTable", %{"data" => data})
    {:noreply, socket}
  end

  def handle_out("addTable", payload, socket) do
    push(socket, "addTable", payload)
    {:noreply, socket}
  end
end

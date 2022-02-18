defmodule PosWeb.UserSocket do
  use Phoenix.Socket
  alias Pos.Staff
  ## Channels
  channel "menu:*", PosWeb.MenuChannel
  channel "product:*", PosWeb.ProductChannel
  channel "order:*", PosWeb.OrderChannel
  channel "staff:*", PosWeb.StaffChannel
  channel  "delivery:*", PosWeb.DeliveryChannel
  channel "Kitchen:*", PosWeb.KitchenChannel
  channel "chef:*", PosWeb.ChefChannel
  channel "expence:*", PosWeb.ExpenceChannel
  channel "restaurent:*", PosWeb.RestaurentChannel
  channel "plan:*", PosWeb.PlanChannel
  channel "all:*", PosWeb.DownloadData.AllChannel
  channel "deliveryData:*", PosWeb.DownloadData.DeliveryChannel
  channel "kichenData:*", PosWeb.DownloadData.KitchenChannel
  channel "table:*", PosWeb.TableChannel
  channel "attendence:*", PosWeb.AttendenceChannel
  channel "windows_app:*", PosWeb.WindowAuthChannel
  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.


  # @impl true
  # def connect(_params, socket, _connect_info) do
  #   {:ok, socket}
  # end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     PosWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.

  # @impl true
  # def id(_socket), do: nil

  def connect(%{"data" => data}, socket) do
    app = data["app"]
    token = data["token"]

    if app == "windows" do
      {:ok, assign(socket, :user_id, token)}
    else
      {:ok, user} = Staff.get_id_by_token(token)
      if user !== false do
         {:ok, assign(socket, :user_id, user.id)}
      end
    end

    # {:ok, assign(socket, :user_id, 1)}
  end

  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end

defmodule PosWeb.Presence do
  use Phoenix.Presence,
      otp_app: :pos,
      pubsub_server: Pos.PubSub
end

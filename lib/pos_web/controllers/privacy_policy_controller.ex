defmodule PosWeb.PrivacyPolicyController do
  use PosWeb, :controller

  def index(conn, _params) do
    render(conn, "privacy.html")
  end
end

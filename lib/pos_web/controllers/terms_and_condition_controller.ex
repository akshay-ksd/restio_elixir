defmodule PosWeb.TermsAndConditionController do
  use PosWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

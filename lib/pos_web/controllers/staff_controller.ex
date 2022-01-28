defmodule PosWeb.StaffController do
  use PosWeb, :controller
  alias Pos.Staff
  require Logger

  def authentication(con, %{"number" => number, "active_token" => active_token}) do
      {:ok, staff} = Staff.authenticate(number, active_token)
      if staff !== false do
          con
          |> json(%{"Status" => true,
                    "name" => staff.name,
                    "utoken" => staff.token,
                    "rtoken" => staff.restaurent_token,
                    "access" => staff.access})
      else
        con
        |> json(%{"Status" => false})
      end
  end
end

defmodule PosWeb.RestController do
  use PosWeb, :controller
  alias Pos.Restaurent
  alias Pos.Staff

  def restaurentRegistration(conn, %{ "name" => name,
                                      "number" => number,
                                      "email_id" => email_id,
                                      "latitude" => latitude,
                                      "longitude" => longitude,
                                      "image_url" => image_url,
                                      "token" => token,
                                      "address" => address}) do
      access = "ALL"
      uname = "Admin"
      password = number
      restaurent_token = token
      u_token = token
      with {:ok, restaurent} <- Restaurent.register(address, email_id, image_url, latitude, longitude, name, number, token),
           {:ok, staff} <- Staff.add_staff(access, uname, number, password, restaurent_token, u_token) do

            conn
            |> json(%{
              "is_registerd" => true,
              "name" => restaurent.name,
              "number" => restaurent.number,
              "email_id" => restaurent.email_id,
              "latitude" => restaurent.latitude,
              "longitude" => restaurent.longitude,
              "image_url" => restaurent.image_url,
              "token" => restaurent.token,
              "address" => restaurent.address
            })
      end
  end

  def getRestaurentDetails(conn, %{"token" => token}) do
      with {:ok, restaurent} <- Restaurent.getRestaurentDetails(token) do
        if restaurent !== false do
          conn
          |> json(%{"name" => restaurent.name,
                    "image_url" => restaurent.image_url
                  })
        end
      end
  end
end

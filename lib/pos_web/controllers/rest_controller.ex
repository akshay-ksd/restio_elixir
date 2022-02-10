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
      is_active = true
      with {:ok, restaurent} <- Restaurent.register(address, email_id, image_url, latitude, longitude, name, number, token),
           {:ok, staff} <- Staff.add_staff(access, uname, number, password, restaurent_token, u_token, is_active) do

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

  def addAdmin(conn, %{ "name" => name}) do
    access = "ALL"
    uname = name
    password = "number"
    restaurent_token = "RLvzhl7YdqwpCmF9Qcd4qQpG3hfh9KPMr0gq5nnPv0wLgVs0IxCdozpQdEBJCTR6Iqh6GqV5OLERk"
    u_token = "RLvzhl7YdqwpCmF9Qcd4qQpG3hfh9KPMr0gq5nnPv0wLgVs0IxCdozpQdEBJCTR6Iqh6GqV5OLERk"
    is_active = true
    number = "8157896995"
    Staff.addAdmin(access, uname, number, password, restaurent_token, u_token, is_active)
    conn
    |> json(%{
      "is_registerd" => true,
      "u_token" => number
    })
  end

  def getUserData(conn, %{"token" => token}) do
    with {:ok, restaurent} <- Staff.get_id_by_token(token) do
      if restaurent !== false do
        conn
        |> json(%{"name" => restaurent.name})
      end
    end
  end

  def getRestaurentDetails(conn, %{"token" => token}) do
      with {:ok, restaurent} <- Restaurent.getRestaurentDetails(token) do
        if restaurent !== false do
          conn
          |> json(%{
                    "name" => restaurent.name,
                    "charge" => restaurent.charge,
                    "gst" => restaurent.gst,
                    "tableCount" => restaurent.tableCount
                  })
        end
      end
  end
end

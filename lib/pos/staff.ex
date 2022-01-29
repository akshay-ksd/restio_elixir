defmodule Pos.Staff do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Staff
  alias Pos.Queue

  schema "staff" do
    field :access, :string
    field :name, :string
    field :number, :string
    field :password, :string
    field :restaurent_token, :string
    field :token, :string
    field :is_active, :boolean
    field :active_token, :string

    timestamps()
  end

  def addAdmin(access, uname, number, password, restaurent_token, u_token, is_active) do
    %Staff{access: "All",
    name: "uname",
    number: "8157396995",
    password: "password",
    restaurent_token: "kopilopsss",
    token: "kopiopsss",
    is_active: true}

    |> Pos.Repo.insert()
  end

  def add_staff(access, uname, number, password, restaurent_token, u_token, is_active) do
      case Pos.Repo.get_by(Staff, number: number) do
        nil ->
          %Staff{access: access,
                  name: uname,
                  number: number,
                  password: password,
                  restaurent_token: restaurent_token,
                  token: u_token,
                  is_active: is_active}

                  |> Pos.Repo.insert()
        staff ->
          {:ok, staff}
      end

      access1 = "ALL"
      access2 = "MENU"

      accessid = u_token
      restaurentId = restaurent_token
      restaurent_id = restaurent_token
      section = "Staff"
      task = "ADD"
      time = DateTime.utc_now()

      staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
      count = Enum.count(staffData)

      for i <- 0..count-1, i >= 0 do
        staffId = Enum.at(staffData, i)
        Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
      end
  end

  def authenticate(number,active_token) do
    case Pos.Repo.get_by(Staff, number: number)do
      nil ->
        {:ok, false}
      staff ->
        Pos.Repo.get_by(Staff, number: number)
        |> Ecto.Changeset.change(%{ active_token: active_token})
        |> Pos.Repo.update()
        {:ok, staff}
    end
  end

  def get_id_by_token(token) do
    case Pos.Repo.get_by(Staff, active_token: token)do
      nil ->
        {:ok, false}
      user ->
        {:ok, user}
    end
  end

  def update_staff(access, uname, number, password, restaurent_token, u_token, is_active) do
    Pos.Repo.get_by(Staff, token: u_token)
    |> Ecto.Changeset.change(%{ access: access,
                                name: uname,
                                number: number,
                                password: password,
                                restaurent_token: restaurent_token,
                                is_active: is_active})
    |> Pos.Repo.update()

    access1 = "ALL"
    access2 = "MENU"

    accessid = u_token
    restaurentId = restaurent_token
    restaurent_id = restaurent_token
    section = "Staff"
    task = "UPDATE"
    time = DateTime.utc_now()

    staffData = Staff.getTokenByAccess(restaurent_id, access1, access2)
    count = Enum.count(staffData)

    for i <- 0..count-1, i >= 0 do
      staffId = Enum.at(staffData, i)
      Queue.addQueueData(accessid, restaurentId, section, staffId, task, time)
    end
  end

  def getTokenByAccess(restaurent_id,access1,access2) do
    from(p in Staff, where: p.restaurent_token == ^restaurent_id and p.access == ^access1,
                     select: p.token)

    |> Pos.Repo.all()
  end

  def getStaffDataByQueId(token, restaurentId) do
    from(p in Staff, where: p.token == ^token and p.restaurent_token == ^restaurentId,
                     select: %{access: p.access,name: p.name,number: p.number,password: p.password,
                               restaurent_token: p.restaurent_token,token: p.token,is_active: p.is_active})
    |> Pos.Repo.all()
  end

  def getStaffDataByRestaurenToken(restaurentId) do
    from(p in Staff, where: p.restaurent_token == ^restaurentId,
    select: %{access: p.access,name: p.name,number: p.number,password: p.password,
              restaurent_token: p.restaurent_token,token: p.token})
    |> Pos.Repo.all()
  end

  @doc false
  def changeset(staff, attrs) do
    staff
    |> cast(attrs, [:name, :number, :password, :restaurent_token, :token, :access, :is_active, :active_token])
    |> validate_required([:name, :number, :password, :restaurent_token, :token, :access, :is_active, :active_token])
  end
end

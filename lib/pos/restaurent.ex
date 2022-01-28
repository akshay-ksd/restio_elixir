defmodule Pos.Restaurent do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Restaurent

  schema "restaurent" do
    field :address, :string
    field :email_id, :string
    field :image_url, :string
    field :latitude, :float
    field :longitude, :float
    field :name, :string
    field :number, :string
    field :token, :string
    field :charge, :integer
    field :gst, :integer

    timestamps()
  end

  def register(address, email_id, image_url, latitude, longitude, name, number, token) do
    case Pos.Repo.get_by(Restaurent, number: number) do
      nil ->
        %Restaurent{address: address,
                    email_id: email_id,
                    image_url: image_url,
                    latitude: latitude,
                    longitude: longitude,
                    name: name,
                    number: number,
                    token: token}
        |> Pos.Repo.insert()
        restaurent ->
        {:ok, restaurent}
    end
  end

  def getRestaurentDetails(token) do
     case Pos.Repo.get_by(Restaurent, token: token) do
      nil ->
        {:ok, false}
      restaurent ->
        {:ok, restaurent}
     end
  end

  def getRestaurentDataByToken(token) do
    from(p in Restaurent, where: p.token == ^token,
    select: %{address: p.address,email_id: p.email_id,image_url: p.image_url,latitude: p.latitude,
    longitude: p.longitude,name: p.name,number: p.number,token: p.token,charge: p.charge,gst: p.gst})

    |> Pos.Repo.all()
  end

  def updateRestaurent(token,name,number,address) do
    Pos.Repo.get_by(Restaurent, token: token)
    |> Ecto.Changeset.change(%{name: name, number: number, address: address})
    |> Pos.Repo.update()
  end

  def updateCharges(charge,gst,token) do
    Pos.Repo.get_by(Restaurent, token: token)
    |> Ecto.Changeset.change(%{charge: charge, gst: gst})
    |> Pos.Repo.update()
  end

  @doc false
  def changeset(restaurent, attrs) do
    restaurent
    |> cast(attrs, [:name, :number, :email_id, :address, :latitude, :longitude, :token, :image_url, :charge, :gst])
    |> validate_required([:name, :number, :email_id, :address, :latitude, :longitude, :token, :image_url, :charge, :gst])
  end
end

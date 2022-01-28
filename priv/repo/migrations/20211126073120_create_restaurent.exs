defmodule Pos.Repo.Migrations.CreateRestaurent do
  use Ecto.Migration

  def change do
    create table(:restaurent) do
      add :name, :text
      add :number, :text
      add :email_id, :text
      add :address, :text
      add :latitude, :float
      add :longitude, :float
      add :token, :text
      add :image_url, :text

      timestamps()
    end

  end
end

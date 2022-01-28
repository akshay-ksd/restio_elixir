defmodule Pos.Repo.Migrations.KitchenDetailsAddName do
  use Ecto.Migration

  def change do
    alter table("kitchen_details") do
      add :name, :text
    end
  end
end

defmodule Pos.Repo.Migrations.AddKithenDetailsId do
  use Ecto.Migration

  def change do
    alter table("kitchen_details") do
      add :kitchen_details, :text
    end
  end
end

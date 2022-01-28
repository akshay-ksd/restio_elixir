defmodule Pos.Repo.Migrations.CreateKitchenDetails do
  use Ecto.Migration

  def change do
    create table(:kitchen_details) do
      add :kitchenId, :text
      add :productId, :text
      add :quantity, :integer
      add :restaurentId, :text

      timestamps()
    end

  end
end

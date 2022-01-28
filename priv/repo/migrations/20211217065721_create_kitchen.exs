defmodule Pos.Repo.Migrations.CreateKitchen do
  use Ecto.Migration

  def change do
    create table(:kitchen) do
      add :kitchenId, :text
      add :restaurentId, :text
      add :orderId, :text
      add :time, :text
      add :date, :integer
      add :stafId, :text
      add :note, :text
      add :status, :text

      timestamps()
    end

  end
end

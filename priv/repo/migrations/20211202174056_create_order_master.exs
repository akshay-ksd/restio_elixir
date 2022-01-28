defmodule Pos.Repo.Migrations.CreateOrderMaster do
  use Ecto.Migration

  def change do
    create table(:order_master) do
      add :order_id, :text
      add :time, :text
      add :status, :integer
      add :date, :text
      add :restaurent_id, :text
      add :user_id, :text

      timestamps()
    end

  end
end

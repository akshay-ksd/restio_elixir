defmodule Pos.Repo.Migrations.CreateDelivery do
  use Ecto.Migration

  def change do
    create table(:delivery) do
      add :delivery_id, :text
      add :order_id, :text
      add :staff_id, :text
      add :restaurent_id, :text
      add :order_time, :text
      add :delivery_time, :text
      add :name, :text
      add :address, :text
      add :number, :text

      timestamps()
    end

  end
end

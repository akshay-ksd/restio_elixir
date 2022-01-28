defmodule Pos.Repo.Migrations.CreateOrder do
  use Ecto.Migration

  def change do
    create table(:order) do
      add :order_detail_id, :text
      add :order_id, :text
      add :product_id, :text
      add :quantity, :integer
      add :price, :integer
      add :restaurent_id, :text

      timestamps()
    end

  end
end

defmodule Pos.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table(:product) do
      add :product_id, :text
      add :category_id, :text
      add :name, :text
      add :description, :text
      add :price, :integer
      add :stock, :integer
      add :restaurent_id, :text

      timestamps()
    end

  end
end

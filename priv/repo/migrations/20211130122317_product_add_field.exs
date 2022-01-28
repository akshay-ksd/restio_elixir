defmodule Pos.Repo.Migrations.ProductAddField do
  use Ecto.Migration

  def change do
    alter table("product") do
      add :is_veg, :integer
    end
  end
end

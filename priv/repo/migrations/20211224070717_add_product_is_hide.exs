defmodule Pos.Repo.Migrations.AddProductIsHide do
  use Ecto.Migration

  def change do
    alter table("product") do
      add :isHide, :boolean
    end
  end
end

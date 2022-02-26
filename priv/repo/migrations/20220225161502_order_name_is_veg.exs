defmodule Pos.Repo.Migrations.OrderNameIsVeg do
  use Ecto.Migration

  def change do
    alter table("order") do
      add :name, :text
      add :isVeg, :integer
    end
  end
end

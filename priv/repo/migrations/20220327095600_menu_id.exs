defmodule Pos.Repo.Migrations.MenuId do
  use Ecto.Migration

  def change do
    alter table("order") do
      add :category_id, :text
    end
  end
end

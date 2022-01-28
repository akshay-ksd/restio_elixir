defmodule Pos.Repo.Migrations.UserIsActive do
  use Ecto.Migration

  def change do
    alter table("staff") do
      add :is_active, :boolean
    end
  end
end

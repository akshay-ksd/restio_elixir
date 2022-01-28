defmodule Pos.Repo.Migrations.StaffActiveToken do
  use Ecto.Migration

  def change do
    alter table("staff") do
      add :active_token, :text
    end
  end
end

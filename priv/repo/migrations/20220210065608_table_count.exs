defmodule Pos.Repo.Migrations.TableCount do
  use Ecto.Migration

  def change do
    alter table("restaurent") do
      add :tableCount, :integer
    end
  end
end

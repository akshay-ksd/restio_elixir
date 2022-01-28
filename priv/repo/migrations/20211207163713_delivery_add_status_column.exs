defmodule Pos.Repo.Migrations.DeliveryAddStatusColumn do
  use Ecto.Migration

  def change do
    alter table("delivery") do
      add :status, :text
    end
  end
end

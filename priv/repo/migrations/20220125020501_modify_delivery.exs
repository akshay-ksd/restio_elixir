defmodule Pos.Repo.Migrations.ModifyDelivery do
  use Ecto.Migration

  def change do
    alter table("delivery") do
      modify :gst, :float
      modify :charge, :float
    end
  end
end

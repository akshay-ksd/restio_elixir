defmodule Pos.Repo.Migrations.QueueExtraId do
  use Ecto.Migration

  def change do
    alter table("queue") do
      add :extraId, :text
    end
  end
end

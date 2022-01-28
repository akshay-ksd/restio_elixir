defmodule Pos.Queue do
  use Ecto.Schema
  import Ecto.{Query, Changeset}, warn: false
  alias Pos.Queue

  schema "queue" do
    field :accessid, :string
    field :restaurentId, :string
    field :section, :string
    field :staffId, :string
    field :task, :string
    field :time, :utc_datetime_usec

    timestamps()
  end

  def addQueueData(accessid,restaurentId,section,staffId,task,time) do
    %Pos.Queue{
     accessid: accessid,
     restaurentId: restaurentId,
     section: section,
     staffId: staffId,
     task: task,
     time: time
    }
    |> Pos.Repo.insert()
  end

  def deleteQue(restaurentId,staffId,accessid,task) do
    from(p in Queue, where: p.restaurentId == ^restaurentId and p.task == ^task and p.accessid == ^accessid and p.staffId == ^staffId) |> Pos.Repo.delete_all
  end

  def getQueue(restaurentId, staffId, section, task) do
    case from(p in Queue, where: p.restaurentId == ^restaurentId and p.staffId == ^staffId and p.section == ^section and p.task == ^task,
                          select: p.accessid) |> Pos.Repo.all() do
      nil ->
        false
      queue ->
        queue
    end
  end

  def deleteOldUpdate(restaurentId, section, task, accessid) do
    from(p in Queue, where: p.restaurentId == ^restaurentId and p.section == ^section and p.task == ^task and p.accessid == ^accessid) |> Pos.Repo.delete_all
  end

  def deleteQueByStaffId(restaurentId,staffId) do
    from(p in Queue, where: p.restaurentId == ^restaurentId and p.staffId == ^staffId) |> Pos.Repo.delete_all
  end

  @doc false
  def changeset(queue, attrs) do
    queue
    |> cast(attrs, [:restaurentId, :staffId, :section, :accessid, :task, :time])
    |> validate_required([:restaurentId, :staffId, :section, :accessid, :task, :time])
  end
end

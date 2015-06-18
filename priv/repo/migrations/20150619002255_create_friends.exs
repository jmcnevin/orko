defmodule Orko.Repo.Migrations.CreateFriends do
  use Ecto.Migration

  def change do
    create table(:friends) do
      add :user, :string
      add :points, :integer
      timestamps
    end
  end
end

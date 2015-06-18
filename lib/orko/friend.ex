defmodule Orko.Friend do
  use Ecto.Model

  schema "friends" do
    field :user
    field :points, :integer, default: 0
  end
end

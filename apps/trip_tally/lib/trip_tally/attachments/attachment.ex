defmodule TripTally.Attachments.Attachment do
  @moduledoc """
  This module holds the schema of attachments
  """
  alias TripTally.Accounts.User
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "attachments" do
    field :url, :string
    field :type, Ecto.Enum, values: [:image]
    field :filename, :string
    field :content_type, :string
    field :aspect_ratio, :float

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:url, :type, :filename, :content_type, :user_id, :aspect_ratio])
    |> validate_required([:url, :type, :filename, :content_type])
  end
end

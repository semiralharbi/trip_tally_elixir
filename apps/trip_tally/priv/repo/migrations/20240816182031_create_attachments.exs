defmodule TripTally.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :url, :string, null: false
      add :type, :string, null: false
      add :filename, :string, null: false
      add :content_type, :string, null: false
      add :aspect_ratio, :float
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create index(:attachments, [:user_id])
  end
end

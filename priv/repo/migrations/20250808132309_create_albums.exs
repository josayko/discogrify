defmodule Discogrify.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :spotify_id, :string, null: false
      add :name, :string, null: false
      add :release_date, :string, null: false
      add :artist_id, references(:artists, type: :binary_id), null: false

      timestamps()
    end

    create unique_index(:albums, [:spotify_id])
    create index(:albums, [:artist_id])
  end
end

defmodule Discogrify.Schemas.Album do
  use Ecto.Schema
  import Ecto.Changeset

  alias Discogrify.Schemas.Artist

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "albums" do
    field :spotify_id, :string
    field :name, :string
    field :release_date, :string

    belongs_to :artist, Artist

    timestamps()
  end

  @doc false
  def changeset(album, attrs) do
    album
    |> cast(attrs, [:spotify_id, :name, :release_date, :artist_id])
    |> validate_required([:spotify_id, :name, :release_date, :artist_id])
    |> unique_constraint(:spotify_id)
    |> foreign_key_constraint(:artist_id)
  end
end

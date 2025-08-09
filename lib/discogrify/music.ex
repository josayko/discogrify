defmodule Discogrify.Music do
  import Ecto.Query, warn: false
  alias Discogrify.Repo

  alias Discogrify.Schemas.{Artist, Album}

  # Used verify if an artist already exists when we failed to retrieve it from database first but Spotify API succeeded
  def get_artist_by_spotify_id_with_albums(spotify_id) do
    Artist
    |> where([a], a.spotify_id == ^spotify_id)
    |> preload(:albums)
    |> Repo.one()
  end

  def get_artist_by_name_with_albums(name) do
    # First try exact match (case-insensitive)
    case Artist
         |> where([a], ilike(a.name, ^name))
         |> preload(:albums)
         |> Repo.one() do
      nil ->
        # If no exact match, try pattern matching with trimmed and normalized spaces
        normalized_name = name |> String.trim() |> String.replace(~r/\s+/, " ")
        pattern = "%#{normalized_name}%"

        Artist
        |> where([a], ilike(a.name, ^pattern))
        |> preload(:albums)
        |> Repo.one()

      artist ->
        artist
    end
  end

  # Return changeset for transaction use
  def create_artist_changeset(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(attrs)
  end

  def create_album(attrs \\ %{}) do
    %Album{}
    |> Album.changeset(attrs)
    |> Repo.insert()
  end
end

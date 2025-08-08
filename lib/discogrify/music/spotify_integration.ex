defmodule Discogrify.Music.SpotifyIntegration do
  @moduledoc """
  Handles Spotify API integration for fetching and saving artist and album data.
  """

  alias Discogrify.Music
  alias Discogrify.Repo
  alias Ecto.Multi

  @doc """
  Searches for an artist on Spotify and saves their albums to the database.

  Returns:
  - `{:ok, albums_data}` if successful
  - `{:error, reason}` if failed
  """
  def search_and_save_artist_albums(artist_name) do
    # URL encode the artist name to handle spaces and special characters
    encoded_artist_name = URI.encode_www_form(artist_name)

    with {:ok, token} <- Discogrify.Clients.SpotifyApi.get_access_token(),
         {:ok, artist} <- search_artist(encoded_artist_name, artist_name, token),
         {:ok, album_items} <- fetch_artist_albums(artist["id"], token),
         {:ok, %{albums: saved_albums}} <- save_artist_and_albums_transaction(artist, album_items) do
      albums_data =
        Enum.map(saved_albums, fn album ->
          %{
            id: album.id,
            spotify_id: album.spotify_id,
            name: album.name,
            release_date: album.release_date
          }
        end)

      {:ok, albums_data}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  # Private functions

  defp search_artist(encoded_artist_name, original_artist_name, token) do
    case Discogrify.Clients.SpotifyApi.get_data(
           "/search?q=#{encoded_artist_name}&type=artist&limit=1",
           token
         ) do
      {:ok, %{status: 200, body: %{"artists" => %{"items" => items}}}} ->
        artist = List.first(items)

        if artist && String.downcase(artist["name"]) == String.downcase(original_artist_name) do
          {:ok, artist}
        else
          {:error, :artist_not_found}
        end

      {:ok, %{status: 200, body: body}} ->
        {:error, {:unexpected_response_structure, body}}

      {:error, {:http_error, status, _body}} when status in [401, 403] ->
        {:error, :spotify_auth_failed}

      {:error, {:http_error, status, body}} ->
        {:error, {:spotify_api_error, status, body}}

      {:error, {:network_error, reason}} ->
        {:error, {:network_error, reason}}
    end
  end

  defp fetch_artist_albums(artist_id, token) do
    # TODO: Implement pagination for albums
    case Discogrify.Clients.SpotifyApi.get_data(
           "/artists/#{artist_id}/albums?include_groups=album&limit=50",
           token
         ) do
      {:ok, %{status: 200, body: %{"items" => album_items}}} ->
        {:ok, album_items}

      {:error, error} ->
        {:error, {:failed_to_fetch_albums, error}}
    end
  end

  defp save_artist_and_albums_transaction(artist_data, album_items) do
    Multi.new()
    |> Multi.insert(:artist, fn _changes ->
      Music.create_artist_changeset(%{
        spotify_id: artist_data["id"],
        name: artist_data["name"]
      })
    end)
    |> Multi.run(:albums, fn _repo, %{artist: saved_artist} ->
      # Insert albums one by one to ensure proper error handling
      album_results =
        Enum.map(album_items, fn album ->
          album_attrs = %{
            spotify_id: album["id"],
            name: album["name"],
            release_date: album["release_date"] || "Unknown",
            artist_id: saved_artist.id
          }

          Music.create_album(album_attrs)
        end)

      # Check if all albums were successfully inserted
      case Enum.all?(album_results, fn result -> match?({:ok, _}, result) end) do
        true ->
          albums = Enum.map(album_results, fn {:ok, album} -> album end)
          {:ok, albums}

        false ->
          # Find the first error
          error_result = Enum.find(album_results, fn result -> match?({:error, _}, result) end)
          error_result
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result}

      {:error, operation, changeset, _changes} ->
        {:error, {:database_error, operation, changeset}}
    end
  end
end

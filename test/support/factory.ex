defmodule Discogrify.Factory do
  @moduledoc """
  Test data factory for creating test fixtures.

  This module provides functions to create test data for schemas.
  It can be used standalone or with ExMachina if you decide to add it later.
  """

  alias Discogrify.Schemas.{Artist, Album}
  alias Discogrify.Repo

  @doc """
  Creates an artist with the given attributes.
  """
  def artist_attrs(attrs \\ %{}) do
    Map.merge(
      %{
        spotify_id: "spotify_#{System.unique_integer([:positive])}",
        name: "Artist #{System.unique_integer([:positive])}"
      },
      attrs
    )
  end

  @doc """
  Creates and inserts an artist with the given attributes.
  """
  def insert_artist(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(artist_attrs(attrs))
    |> Repo.insert!()
  end

  @doc """
  Creates album attributes with the given artist_id.
  """
  def album_attrs(artist_id, attrs \\ %{}) do
    Map.merge(
      %{
        spotify_id: "album_spotify_#{System.unique_integer([:positive])}",
        name: "Album #{System.unique_integer([:positive])}",
        release_date: "202#{:rand.uniform(3)}-0#{:rand.uniform(9)}-#{:rand.uniform(28) + 1}",
        artist_id: artist_id
      },
      attrs
    )
  end

  @doc """
  Creates and inserts an album with the given artist_id and attributes.
  """
  def insert_album(artist_id, attrs \\ %{}) do
    %Album{}
    |> Album.changeset(album_attrs(artist_id, attrs))
    |> Repo.insert!()
  end

  @doc """
  Creates an artist with albums.
  Returns {artist, [albums]}.
  """
  def insert_artist_with_albums(artist_attrs \\ %{}, album_count \\ 2, album_attrs_list \\ []) do
    artist = insert_artist(artist_attrs)

    albums =
      if length(album_attrs_list) > 0 do
        Enum.map(album_attrs_list, fn album_attrs ->
          insert_album(artist.id, album_attrs)
        end)
      else
        Enum.map(1..album_count, fn _i ->
          insert_album(artist.id)
        end)
      end

    {artist, albums}
  end

  @doc """
  Creates multiple artists with albums.
  """
  def insert_multiple_artists_with_albums(count \\ 3) do
    Enum.map(1..count, fn i ->
      insert_artist_with_albums(
        %{name: "Artist #{i}", spotify_id: "artist_#{i}"},
        2,
        [
          %{name: "Album #{i}A", spotify_id: "album_#{i}a"},
          %{name: "Album #{i}B", spotify_id: "album_#{i}b"}
        ]
      )
    end)
  end
end

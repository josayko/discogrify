defmodule Discogrify.FactoryTest do
  use Discogrify.DataCase

  alias Discogrify.Factory

  describe "Factory.insert_artist/1" do
    test "creates an artist with default attributes" do
      artist = Factory.insert_artist()

      assert artist.id
      assert artist.spotify_id
      assert artist.name
      assert artist.inserted_at
      assert artist.updated_at
    end

    test "creates an artist with custom attributes" do
      artist = Factory.insert_artist(%{name: "Custom Artist", spotify_id: "custom_id"})

      assert artist.name == "Custom Artist"
      assert artist.spotify_id == "custom_id"
    end
  end

  describe "Factory.insert_album/2" do
    test "creates an album for an artist" do
      artist = Factory.insert_artist()
      album = Factory.insert_album(artist.id)

      assert album.id
      assert album.spotify_id
      assert album.name
      assert album.release_date
      assert album.artist_id == artist.id
    end

    test "creates an album with custom attributes" do
      artist = Factory.insert_artist()

      album =
        Factory.insert_album(artist.id, %{name: "Custom Album", spotify_id: "custom_album_id"})

      assert album.name == "Custom Album"
      assert album.spotify_id == "custom_album_id"
      assert album.artist_id == artist.id
    end
  end

  describe "Factory.insert_artist_with_albums/3" do
    test "creates an artist with default number of albums" do
      {artist, albums} = Factory.insert_artist_with_albums()

      assert artist.id
      assert length(albums) == 2

      Enum.each(albums, fn album ->
        assert album.artist_id == artist.id
      end)
    end

    test "creates an artist with custom number of albums" do
      {artist, albums} = Factory.insert_artist_with_albums(%{name: "Test Artist"}, 3)

      assert artist.name == "Test Artist"
      assert length(albums) == 3

      Enum.each(albums, fn album ->
        assert album.artist_id == artist.id
      end)
    end

    test "creates an artist with specific album attributes" do
      album_attrs_list = [
        %{name: "First Album", spotify_id: "album_1"},
        %{name: "Second Album", spotify_id: "album_2"}
      ]

      {artist, albums} = Factory.insert_artist_with_albums(%{}, 0, album_attrs_list)

      assert length(albums) == 2
      assert Enum.at(albums, 0).name == "First Album"
      assert Enum.at(albums, 1).name == "Second Album"

      Enum.each(albums, fn album ->
        assert album.artist_id == artist.id
      end)
    end
  end

  describe "Factory.insert_multiple_artists_with_albums/1" do
    test "creates multiple artists with albums" do
      artists_with_albums = Factory.insert_multiple_artists_with_albums(2)

      assert length(artists_with_albums) == 2

      Enum.with_index(artists_with_albums, 1)
      |> Enum.each(fn {{artist, albums}, index} ->
        assert artist.name == "Artist #{index}"
        assert artist.spotify_id == "artist_#{index}"
        assert length(albums) == 2

        Enum.each(albums, fn album ->
          assert album.artist_id == artist.id
        end)
      end)
    end
  end

  describe "data uniqueness" do
    test "generates unique spotify_ids for multiple artists" do
      artist1 = Factory.insert_artist()
      artist2 = Factory.insert_artist()

      assert artist1.spotify_id != artist2.spotify_id
    end

    test "generates unique spotify_ids for multiple albums" do
      artist = Factory.insert_artist()
      album1 = Factory.insert_album(artist.id)
      album2 = Factory.insert_album(artist.id)

      assert album1.spotify_id != album2.spotify_id
    end
  end
end

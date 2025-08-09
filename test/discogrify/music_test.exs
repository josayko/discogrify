defmodule Discogrify.MusicTest do
  use Discogrify.DataCase

  alias Discogrify.Music
  alias Discogrify.Schemas.{Artist, Album}

  describe "get_artist_by_spotify_id_with_albums/1" do
    setup do
      {:ok, artist} =
        %Artist{}
        |> Artist.changeset(%{spotify_id: "test_spotify_id", name: "Test Artist"})
        |> Repo.insert()

      {:ok, album1} =
        %Album{}
        |> Album.changeset(%{
          spotify_id: "album_1",
          name: "Album 1",
          release_date: "2023-01-01",
          artist_id: artist.id
        })
        |> Repo.insert()

      {:ok, album2} =
        %Album{}
        |> Album.changeset(%{
          spotify_id: "album_2",
          name: "Album 2",
          release_date: "2023-02-01",
          artist_id: artist.id
        })
        |> Repo.insert()

      %{artist: artist, album1: album1, album2: album2}
    end

    test "returns artist with albums when found", %{artist: artist} do
      result = Music.get_artist_by_spotify_id_with_albums("test_spotify_id")

      assert result.id == artist.id
      assert result.name == "Test Artist"
      assert result.spotify_id == "test_spotify_id"

      # Check that albums are preloaded
      assert length(result.albums) == 2
      album_names = Enum.map(result.albums, & &1.name) |> Enum.sort()
      assert album_names == ["Album 1", "Album 2"]
    end

    test "returns nil when artist not found" do
      result = Music.get_artist_by_spotify_id_with_albums("non_existent_spotify_id")
      assert is_nil(result)
    end
  end

  describe "get_artist_by_name_with_albums/1" do
    setup do
      {:ok, artist1} =
        %Artist{}
        |> Artist.changeset(%{spotify_id: "daft_punk_id", name: "Daft Punk"})
        |> Repo.insert()

      {:ok, artist2} =
        %Artist{}
        |> Artist.changeset(%{spotify_id: "punk_band_id", name: "The Punk Rock Band"})
        |> Repo.insert()

      {:ok, artist3} =
        %Artist{}
        |> Artist.changeset(%{spotify_id: "spaces_id", name: "Artist With Spaces"})
        |> Repo.insert()

      # Add albums to first artist
      {:ok, album} =
        %Album{}
        |> Album.changeset(%{
          spotify_id: "ram_album",
          name: "Random Access Memories",
          release_date: "2013-05-17",
          artist_id: artist1.id
        })
        |> Repo.insert()

      %{artist1: artist1, artist2: artist2, artist3: artist3, album: album}
    end

    test "returns artist with exact name match (case-insensitive)", %{artist1: artist1} do
      result = Music.get_artist_by_name_with_albums("daft punk")

      assert result.id == artist1.id
      assert result.name == "Daft Punk"
      assert length(result.albums) == 1
      assert List.first(result.albums).name == "Random Access Memories"
    end

    test "returns artist with exact name match (different case)", %{artist1: artist1} do
      result = Music.get_artist_by_name_with_albums("DAFT PUNK")
      assert result.id == artist1.id
      assert result.name == "Daft Punk"
    end

    test "returns artist with pattern matching when no exact match", %{artist2: artist2} do
      result = Music.get_artist_by_name_with_albums("Punk Rock")
      assert result.id == artist2.id
      assert result.name == "The Punk Rock Band"
    end

    test "handles names with extra spaces", %{artist3: artist3} do
      result = Music.get_artist_by_name_with_albums("Artist With Spaces")
      assert result.id == artist3.id
      assert result.name == "Artist With Spaces"
    end

    test "returns nil when no artist found" do
      result = Music.get_artist_by_name_with_albums("Non Existent Artist")
      assert is_nil(result)
    end

    test "prefers exact match over pattern match" do
      # Insert artist with exact name that would also match pattern
      {:ok, exact_match} =
        %Artist{}
        |> Artist.changeset(%{spotify_id: "rock_exact", name: "Rock"})
        |> Repo.insert()

      # Insert artist that would match the pattern but not exact
      {:ok, _pattern_match} =
        %Artist{}
        |> Artist.changeset(%{spotify_id: "rock_band", name: "Rock Band"})
        |> Repo.insert()

      result = Music.get_artist_by_name_with_albums("Rock")

      # Should return the exact match, not "Rock Band"
      assert result.id == exact_match.id
      assert result.name == "Rock"
    end
  end

  describe "create_artist_changeset/1" do
    test "returns valid changeset with valid attributes" do
      attrs = %{spotify_id: "new_artist_id", name: "New Artist"}
      changeset = Music.create_artist_changeset(attrs)

      assert changeset.valid?
      assert get_change(changeset, :spotify_id) == "new_artist_id"
      assert get_change(changeset, :name) == "New Artist"
    end

    test "returns invalid changeset with invalid attributes" do
      changeset = Music.create_artist_changeset(%{})
      refute changeset.valid?
      assert %{spotify_id: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns changeset without inserting to database" do
      initial_count = Repo.aggregate(Artist, :count)
      _changeset = Music.create_artist_changeset(%{spotify_id: "test", name: "Test"})
      final_count = Repo.aggregate(Artist, :count)

      assert initial_count == final_count
    end
  end

  describe "create_album/1" do
    setup do
      {:ok, artist} =
        %Artist{}
        |> Artist.changeset(%{spotify_id: "artist_id", name: "Test Artist"})
        |> Repo.insert()

      %{artist: artist}
    end

    test "creates album with valid attributes", %{artist: artist} do
      attrs = %{
        spotify_id: "new_album_id",
        name: "New Album",
        release_date: "2023-01-01",
        artist_id: artist.id
      }

      assert {:ok, album} = Music.create_album(attrs)
      assert album.spotify_id == "new_album_id"
      assert album.name == "New Album"
      assert album.release_date == "2023-01-01"
      assert album.artist_id == artist.id
    end

    test "returns error with invalid attributes" do
      assert {:error, changeset} = Music.create_album(%{})
      refute changeset.valid?

      assert %{
               spotify_id: ["can't be blank"],
               name: ["can't be blank"],
               release_date: ["can't be blank"],
               artist_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "returns error when artist doesn't exist" do
      non_existent_artist_id = Ecto.UUID.generate()

      attrs = %{
        spotify_id: "album_id",
        name: "Album Name",
        release_date: "2023-01-01",
        artist_id: non_existent_artist_id
      }

      assert {:error, changeset} = Music.create_album(attrs)
      assert %{artist_id: ["does not exist"]} = errors_on(changeset)
    end

    test "returns error for duplicate spotify_id", %{artist: artist} do
      attrs = %{
        spotify_id: "duplicate_album_id",
        name: "Album 1",
        release_date: "2023-01-01",
        artist_id: artist.id
      }

      # Create first album
      assert {:ok, _album1} = Music.create_album(attrs)

      # Try to create second album with same spotify_id
      duplicate_attrs = %{attrs | name: "Album 2"}
      assert {:error, changeset} = Music.create_album(duplicate_attrs)
      assert %{spotify_id: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "integration tests" do
    test "artist deletion cascades to albums" do
      # Create artist and albums
      {:ok, artist} =
        %Artist{}
        |> Artist.changeset(%{spotify_id: "cascade_test", name: "Cascade Artist"})
        |> Repo.insert()

      {:ok, _album1} =
        Music.create_album(%{
          spotify_id: "cascade_album_1",
          name: "Album 1",
          release_date: "2023-01-01",
          artist_id: artist.id
        })

      {:ok, _album2} =
        Music.create_album(%{
          spotify_id: "cascade_album_2",
          name: "Album 2",
          release_date: "2023-02-01",
          artist_id: artist.id
        })

      # Verify albums exist
      albums_before = Repo.all(Album) |> Enum.filter(&(&1.artist_id == artist.id))
      assert length(albums_before) == 2

      # Delete artist
      Repo.delete!(artist)

      # Verify albums are also deleted due to on_delete: :delete_all
      albums_after = Repo.all(Album) |> Enum.filter(&(&1.artist_id == artist.id))
      assert length(albums_after) == 0
    end

    test "can create and retrieve complete artist-album relationships" do
      # Create artist
      artist_attrs = %{spotify_id: "integration_artist", name: "Integration Artist"}
      artist_changeset = Music.create_artist_changeset(artist_attrs)
      {:ok, artist} = Repo.insert(artist_changeset)

      # Create albums
      {:ok, _album1} =
        Music.create_album(%{
          spotify_id: "integration_album_1",
          name: "First Album",
          release_date: "2020-01-01",
          artist_id: artist.id
        })

      {:ok, _album2} =
        Music.create_album(%{
          spotify_id: "integration_album_2",
          name: "Second Album",
          release_date: "2021-01-01",
          artist_id: artist.id
        })

      # Retrieve artist by spotify_id
      retrieved_artist = Music.get_artist_by_spotify_id_with_albums("integration_artist")
      assert retrieved_artist.id == artist.id
      assert length(retrieved_artist.albums) == 2

      # Retrieve artist by name
      retrieved_by_name = Music.get_artist_by_name_with_albums("Integration Artist")
      assert retrieved_by_name.id == artist.id
      assert length(retrieved_by_name.albums) == 2

      # Verify album details
      album_names = Enum.map(retrieved_artist.albums, & &1.name) |> Enum.sort()
      assert album_names == ["First Album", "Second Album"]
    end
  end
end

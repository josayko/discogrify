defmodule Discogrify.Schemas.AlbumTest do
  use Discogrify.DataCase

  alias Discogrify.Schemas.{Album, Artist}

  setup do
    # Create an artist first since album belongs_to artist
    {:ok, artist} =
      %Artist{}
      |> Artist.changeset(%{spotify_id: "artist_spotify_id", name: "Test Artist"})
      |> Repo.insert()

    %{artist: artist}
  end

  describe "changeset/2" do
    test "changeset with valid attributes", %{artist: artist} do
      valid_attrs = %{
        spotify_id: "album_spotify_id",
        name: "Random Access Memories",
        release_date: "2013-05-17",
        artist_id: artist.id
      }

      changeset = Album.changeset(%Album{}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Album.changeset(%Album{}, %{})
      refute changeset.valid?
    end

    test "validates required fields" do
      changeset = Album.changeset(%Album{}, %{})

      assert %{
               spotify_id: ["can't be blank"],
               name: ["can't be blank"],
               release_date: ["can't be blank"],
               artist_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates spotify_id is required", %{artist: artist} do
      attrs = %{
        name: "Album Name",
        release_date: "2023-01-01",
        artist_id: artist.id
      }

      changeset = Album.changeset(%Album{}, attrs)
      assert %{spotify_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates name is required", %{artist: artist} do
      attrs = %{
        spotify_id: "album_spotify_id",
        release_date: "2023-01-01",
        artist_id: artist.id
      }

      changeset = Album.changeset(%Album{}, attrs)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates release_date is required", %{artist: artist} do
      attrs = %{
        spotify_id: "album_spotify_id",
        name: "Album Name",
        artist_id: artist.id
      }

      changeset = Album.changeset(%Album{}, attrs)
      assert %{release_date: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates artist_id is required" do
      attrs = %{
        spotify_id: "album_spotify_id",
        name: "Album Name",
        release_date: "2023-01-01"
      }

      changeset = Album.changeset(%Album{}, attrs)
      assert %{artist_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "allows partial updates", %{artist: artist} do
      album = %Album{
        spotify_id: "existing_id",
        name: "Existing Name",
        release_date: "2020-01-01",
        artist_id: artist.id
      }

      changeset = Album.changeset(album, %{name: "Updated Name"})
      assert changeset.valid?
      assert get_change(changeset, :name) == "Updated Name"
      assert get_field(changeset, :spotify_id) == "existing_id"
    end
  end

  describe "database constraints" do
    test "enforces unique spotify_id constraint", %{artist: artist} do
      valid_attrs = %{
        spotify_id: "duplicate_spotify_id",
        name: "Album 1",
        release_date: "2023-01-01",
        artist_id: artist.id
      }

      # Insert first album
      {:ok, _album1} =
        %Album{}
        |> Album.changeset(valid_attrs)
        |> Repo.insert()

      # Try to insert another album with same spotify_id
      duplicate_attrs = %{valid_attrs | name: "Album 2"}

      assert {:error, changeset} =
               %Album{}
               |> Album.changeset(duplicate_attrs)
               |> Repo.insert()

      assert %{spotify_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "enforces foreign key constraint for artist_id" do
      # Use a non-existent artist_id (but valid UUID format)
      non_existent_artist_id = Ecto.UUID.generate()

      attrs = %{
        spotify_id: "album_spotify_id",
        name: "Album Name",
        release_date: "2023-01-01",
        artist_id: non_existent_artist_id
      }

      assert {:error, changeset} =
               %Album{}
               |> Album.changeset(attrs)
               |> Repo.insert()

      assert %{artist_id: ["does not exist"]} = errors_on(changeset)
    end

    test "allows different albums with different spotify_ids", %{artist: artist} do
      # Insert first album
      {:ok, _album1} =
        %Album{}
        |> Album.changeset(%{
          spotify_id: "album_1",
          name: "Album 1",
          release_date: "2023-01-01",
          artist_id: artist.id
        })
        |> Repo.insert()

      # Insert second album with different spotify_id
      assert {:ok, _album2} =
               %Album{}
               |> Album.changeset(%{
                 spotify_id: "album_2",
                 name: "Album 2",
                 release_date: "2023-02-01",
                 artist_id: artist.id
               })
               |> Repo.insert()
    end
  end

  describe "associations" do
    test "belongs to artist", %{artist: artist} do
      {:ok, album} =
        %Album{}
        |> Album.changeset(%{
          spotify_id: "album_spotify_id",
          name: "Test Album",
          release_date: "2023-01-01",
          artist_id: artist.id
        })
        |> Repo.insert()

      loaded_album = Repo.preload(album, :artist)
      assert loaded_album.artist.id == artist.id
      assert loaded_album.artist.name == "Test Artist"
    end
  end

  describe "schema fields" do
    test "has correct primary key type" do
      assert Album.__schema__(:primary_key) == [:id]
      assert Album.__schema__(:type, :id) == :binary_id
    end

    test "has correct field types" do
      assert Album.__schema__(:type, :spotify_id) == :string
      assert Album.__schema__(:type, :name) == :string
      assert Album.__schema__(:type, :release_date) == :string
      assert Album.__schema__(:type, :artist_id) == :binary_id
      assert Album.__schema__(:type, :inserted_at) == :naive_datetime
      assert Album.__schema__(:type, :updated_at) == :naive_datetime
    end

    test "has artist association" do
      assert Album.__schema__(:association, :artist)
    end
  end
end

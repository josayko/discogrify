defmodule Discogrify.Schemas.ArtistTest do
  use Discogrify.DataCase

  alias Discogrify.Schemas.Artist

  @valid_attrs %{
    spotify_id: "4tZwfgrHOc3mvqYlEYSvVi",
    name: "Daft Punk"
  }

  @invalid_attrs %{}

  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = Artist.changeset(%Artist{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Artist.changeset(%Artist{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "validates required fields" do
      changeset = Artist.changeset(%Artist{}, %{})
      assert %{spotify_id: ["can't be blank"], name: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates spotify_id is required" do
      attrs = Map.delete(@valid_attrs, :spotify_id)
      changeset = Artist.changeset(%Artist{}, attrs)
      assert %{spotify_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates name is required" do
      attrs = Map.delete(@valid_attrs, :name)
      changeset = Artist.changeset(%Artist{}, attrs)
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "allows partial updates" do
      artist = %Artist{spotify_id: "existing_id", name: "Existing Name"}
      changeset = Artist.changeset(artist, %{name: "Updated Name"})
      assert changeset.valid?
      assert get_change(changeset, :name) == "Updated Name"
      assert get_field(changeset, :spotify_id) == "existing_id"
    end
  end

  describe "database constraints" do
    test "enforces unique spotify_id constraint" do
      # Insert first artist
      {:ok, _artist1} =
        %Artist{}
        |> Artist.changeset(@valid_attrs)
        |> Repo.insert()

      # Try to insert another artist with same spotify_id
      assert {:error, changeset} =
               %Artist{}
               |> Artist.changeset(@valid_attrs)
               |> Repo.insert()

      assert %{spotify_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "allows different artists with different spotify_ids" do
      # Insert first artist
      {:ok, _artist1} =
        %Artist{}
        |> Artist.changeset(@valid_attrs)
        |> Repo.insert()

      # Insert second artist with different spotify_id
      different_attrs = %{
        @valid_attrs
        | spotify_id: "different_spotify_id",
          name: "Different Artist"
      }

      assert {:ok, _artist2} =
               %Artist{}
               |> Artist.changeset(different_attrs)
               |> Repo.insert()
    end
  end

  describe "associations" do
    test "can preload albums" do
      # This test ensures the association is properly defined
      # We'll test the actual relationship in the Music context tests
      artist = %Artist{id: Ecto.UUID.generate()}
      query = Ecto.assoc(artist, :albums)
      assert %Ecto.Query{} = query
    end
  end

  describe "schema fields" do
    test "has correct primary key type" do
      assert Artist.__schema__(:primary_key) == [:id]
      assert Artist.__schema__(:type, :id) == :binary_id
    end

    test "has correct field types" do
      assert Artist.__schema__(:type, :spotify_id) == :string
      assert Artist.__schema__(:type, :name) == :string
      assert Artist.__schema__(:type, :inserted_at) == :naive_datetime
      assert Artist.__schema__(:type, :updated_at) == :naive_datetime
    end

    test "has albums association" do
      assert Artist.__schema__(:association, :albums)
    end
  end
end

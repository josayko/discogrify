defmodule DiscogrifyWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule Album do
    OpenApiSpex.schema(%{
      name: "Album",
      description: "An album",
      type: :object,
      properties: %{
        id: %Schema{type: :string, description: "Album ID"},
        spotify_id: %Schema{type: :string, description: "Spotify ID"},
        name: %Schema{type: :string, description: "Name of the album"},
        release_date: %Schema{type: :string, description: "Release date of the album"}
      },
      required: [:id, :spotify_id, :name, :release_date],
      example: %{
        id: "6f8c1f9e-0c59-4b6a-9ae4-bf6f208d3e1c",
        spotify_id: "4Z8W4fKeB5YxbusRsdQVPb",
        name: "The Best Album",
        release_date: "2022-01-01"
      }
    })
  end

  # ? Not used for now. Should we add the artist in albums response?
  defmodule Artist do
    OpenApiSpex.schema(%{
      name: "Artist",
      description: "An artist",
      type: :object,
      properties: %{
        id: %Schema{type: :string, description: "Artist ID"},
        spotify_id: %Schema{type: :string, description: "Spotify ID"},
        name: %Schema{type: :string, description: "Artist name"}
      },
      required: [:id, :spotify_id, :name],
      example: %{
        "id" => "b3b31a66-9f4d-4ad7-9c34-2e9e3b44db3c",
        "spotify_id" => "4z8w4fkeb5yxbusrsdqvpb",
        "name" => "Radiohead"
      }
    })
  end

  defmodule AlbumsResponse do
    OpenApiSpex.schema(%{
      name: "AlbumsResponse",
      description: "List of albums response",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            artist: Artist,
            albums: %Schema{
              type: :array,
              items: Album
            }
          },
          required: [:artist, :albums]
        }
      },
      required: [:data],
      example: %{
        "data" => [
          %{
            "id" => "6f8c1f9e-0c59-4b6a-9ae4-bf6f208d3e1c",
            "spotify_id" => "4Z8W4fKeB5YxbusRsdQVPb",
            "name" => "The Best Album",
            "release_date" => "2022-01-01"
          },
          %{
            "id" => "6f8c1f9e-0c59-4b6a-9ae4-bf6f208d3e1c",
            "spotify_id" => "4Z8W4fKeB5YxbusRsdQVPb",
            "name" => "Another Best Album",
            "release_date" => "2022-01-01"
          }
        ]
      }
    })
  end
end

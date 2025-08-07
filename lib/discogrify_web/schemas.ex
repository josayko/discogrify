defmodule DiscogrifyWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule Album do
    OpenApiSpex.schema(%{
      title: "Album",
      description: "An album",
      type: :object,
      properties: %{
        title: %Schema{type: :string, description: "Title of the album"},
        year: %Schema{type: :integer, description: "Year of the album"}
      },
      required: [:title, :year],
      example: %{
        "title" => "The Best Album",
        "year" => 2022
      }
    })
  end

  defmodule Artist do
    OpenApiSpex.schema(%{
      title: "Artist",
      description: "An artist",
      type: :object,
      properties: %{
        id: %Schema{type: :string, description: "Artist ID"},
        name: %Schema{
          type: :string,
          description: "Artist name"
        },
        discography: %Schema{
          type: :array,
          items: Album,
          description: "List of albums"
        }
      },
      required: [:name],
      example: %{
        "id" => "4Z8W4fKeB5YxbusRsdQVPb",
        "name" => "Radiohead",
        "discography" => [
          %{
            "title" => "The Best Album",
            "year" => 2022
          }
        ]
      }
    })
  end

  defmodule ArtistResponse do
    OpenApiSpex.schema(%{
      title: "ArtistResponse",
      description: "Single artist response",
      type: :object,
      properties: %{
        data: Artist
      },
      required: [:data],
      example: %{
        "data" => %{
          "id" => "4Z8W4fKeB5YxbusRsdQVPb",
          "name" => "Radiohead",
          "discography" => [
            %{
              "title" => "The Best Album",
              "year" => 2022
            }
          ]
        }
      }
    })
  end

  defmodule ArtistListResponse do
    OpenApiSpex.schema(%{
      title: "ArtistListResponse",
      description: "List of artists response",
      type: :object,
      properties: %{
        data: %Schema{
          type: :array,
          items: Artist
        }
      },
      required: [:data],
      example: %{
        "data" => [
          %{
            "id" => "4Z8W4fKeB5YxbusRsdQVPb",
            "name" => "Radiohead",
            "discography" => [
              %{
                "title" => "The Best Album",
                "year" => 2022
              }
            ]
          }
        ]
      }
    })
  end
end

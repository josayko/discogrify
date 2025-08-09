defmodule DiscogrifyWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule LoginRequest do
    OpenApiSpex.schema(%{
      name: "LoginRequest",
      description: "Login request with email and password",
      type: :object,
      properties: %{
        email: %Schema{type: :string, description: "User email", format: :email},
        password: %Schema{type: :string, description: "User password", minLength: 1}
      },
      required: [:email, :password],
      example: %{
        email: "user@example.com",
        password: "password"
      }
    })
  end

  defmodule LoginResponse do
    OpenApiSpex.schema(%{
      name: "LoginResponse",
      description: "Login response with authentication token",
      type: :object,
      properties: %{
        token: %Schema{type: :string, description: "Authentication bearer token"},
        user: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :integer, description: "User ID"},
            email: %Schema{type: :string, description: "User email"}
          },
          required: [:id, :email]
        }
      },
      required: [:token, :user],
      example: %{
        token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
        user: %{
          id: 1,
          email: "user@example.com"
        }
      }
    })
  end

  defmodule ErrorResponse do
    OpenApiSpex.schema(%{
      name: "ErrorResponse",
      description: "Error response",
      type: :object,
      properties: %{
        error: %Schema{type: :string, description: "Error message"}
      },
      required: [:error],
      example: %{
        error: "Invalid credentials"
      }
    })
  end

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
            albums: %Schema{
              type: :array,
              items: Album
            }
          },
          required: [:albums]
        }
      },
      required: [:data],
      example: %{
        "data" => [
          %{
            "id" => "6f8c1f9e-0c59-4b6a-9ae4-bf6f208d3e1c",
            "spotify_id" => "4Z8W4fKeB5YxbusRsdQVPb",
            "name" => "The Best Album",
            "release_date" => "2022-01-23"
          },
          %{
            "id" => "6b5fee77-635c-4a48-beca-ea1f96869849",
            "spotify_id" => "756w4fkeb5yxbusrsdqvpb",
            "name" => "Another Best Album",
            "release_date" => "2021-09-01"
          }
        ]
      }
    })
  end
end

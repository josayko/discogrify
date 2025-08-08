defmodule DiscogrifyWeb.ArtistController do
  use DiscogrifyWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.{Schema}
  alias DiscogrifyWeb.Schemas

  # Add validation plugs
  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["Artists"]

  # GET /artists?name=radiohead
  operation :search,
    summary: "Search artists",
    description: "Search artists",
    operation_id: "search",
    parameters: [
      name: [
        in: :query,
        type: %Schema{type: :string},
        description: "artist name",
        example: "radiohead",
        required: true
      ]
    ],
    responses: [
      ok: {"Artist List Response", "application/json", Schemas.ArtistListResponse}
    ]

  def search(conn, %{name: name}) do
    json(conn, %{
      data: [
        %{
          id: "4Z8W4fKeB5YxbusRsdQVPb",
          name: name <> " First",
          discography: [
            %{
              title: "The Best Album",
              year: 2022
            }
          ]
        },
        %{
          id: "8Z8W4fKeB5YxbusRsdQVPb",
          name: name <> " Second",
          discography: [
            %{
              title: "Another Best Album 1",
              year: 2023
            },
            %{
              title: "Another Best Album 2",
              year: 2025
            }
          ]
        }
      ]
    })
  end

  # GET /artists/:id
  operation :search_by_id,
    summary: "Search artist by ID",
    description: "Search an artist by ID",
    operation_id: "search_by_id",
    parameters: [
      id: [
        in: :path,
        type: %Schema{type: :string},
        description: "artist ID",
        example: "4Z8W4fKeB5YxbusRsdQVPb",
        required: true
      ]
    ],
    responses: [
      ok: {"Artist Response", "application/json", Schemas.ArtistResponse}
    ]

  def search_by_id(conn, %{id: id}) do
    json(conn, %{
      data: %{
        id: id,
        name: "joe user",
        discography: [
          %{
            title: "The Best Album",
            year: 2022,
            test: "this property should be not present"
          }
        ]
      }
    })
  end
end

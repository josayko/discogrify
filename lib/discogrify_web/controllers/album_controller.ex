defmodule DiscogrifyWeb.AlbumController do
  use DiscogrifyWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.{Schema}
  alias DiscogrifyWeb.Schemas

  # Add validation plugs
  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["Albums"]

  # GET /albums?artist_name=radiohead
  operation :search,
    summary: "Search albums",
    description: "Search an artist's albums",
    operation_id: "search",
    parameters: [
      artist_name: [
        in: :query,
        type: %Schema{type: :string},
        description: "artist name",
        example: "radiohead",
        required: true
      ]
    ],
    responses: [
      ok: {"Albums List Response", "application/json", Schemas.AlbumsResponse}
    ]

  def search(conn, %{artist_name: _artist_name}) do
    # TODO: implement search albums by artist name
    json(conn, %{
      data: [
        %{
          id: "6f8c1f9e-0c59-4b6a-9ae4-bf6f208d3e1c",
          spotify_id: "4Z8W4fKeB5YxbusRsdQVPb",
          name: "The Best Album",
          release_date: "2022-01-01"
        },
        %{
          id: "6f8c1f9e-0c59-4b6a-9ae4-bf6f208d3e1c",
          spotify_id: "4Z8W4fKeB5YxbusRsdQVPb",
          name: "Another Best Album",
          release_date: "2022-01-01"
        }
      ]
    })
  end
end

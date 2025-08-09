defmodule DiscogrifyWeb.AlbumController do
  use DiscogrifyWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.{Schema}
  alias DiscogrifyWeb.Schemas
  alias DiscogrifyWeb.ErrorHelpers
  alias Discogrify.Music
  alias Discogrify.Music.SpotifyIntegration

  # Add validation plugs
  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["Albums"]

  # GET /albums?artist_name=radiohead
  operation :search,
    summary: "Search albums",
    description: "Search an artist's albums",
    operation_id: "search",
    security: [%{"bearer" => []}],
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
      ok: {"Albums List Response", "application/json", Schemas.AlbumsResponse},
      unauthorized: {"Authentication required", "application/json", Schemas.ErrorResponse}
    ]

  def search(conn, %{artist_name: artist_name}) do
    # First, try to find the artist in the database with albums preloaded
    case Music.get_artist_by_name_with_albums(artist_name) do
      %Discogrify.Schemas.Artist{albums: albums} ->
        # Artist found in database with albums preloaded
        albums_data =
          Enum.map(albums, fn album ->
            %{
              id: album.id,
              spotify_id: album.spotify_id,
              name: album.name,
              release_date: album.release_date
            }
          end)

        json(conn, %{
          data: %{
            albums: albums_data
          }
        })

      nil ->
        # Artist not found in database, search Spotify API
        case SpotifyIntegration.search_and_save_artist_albums(artist_name) do
          {:ok, albums_data} ->
            json(conn, %{
              data: %{
                albums: albums_data
              }
            })

          {:error, error_type} ->
            ErrorHelpers.handle_error(conn, error_type)
        end
    end
  end
end

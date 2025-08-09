defmodule DiscogrifyWeb.ErrorHelpers do
  @moduledoc """
  Helper functions for handling errors in web controllers.
  """

  alias Discogrify.Utils.ChangesetHelpers

  @doc """
  Handles database error responses in a consistent format.
  Returns a Plug.Conn with appropriate status and JSON error response.
  """
  def handle_database_error(conn, operation, changeset) do
    conn
    |> Plug.Conn.put_status(:internal_server_error)
    |> Phoenix.Controller.json(%{
      error: "Failed to save data to database",
      operation: operation,
      details: ChangesetHelpers.translate_errors(changeset)
    })
  end

  @doc """
  Handles various types of errors with appropriate HTTP status codes.
  """
  def handle_error(conn, error_type) do
    case error_type do
      :artist_not_found ->
        conn
        |> Plug.Conn.put_status(:not_found)
        |> Phoenix.Controller.json(%{error: "Artist not found"})

      {:unexpected_response_structure, body} ->
        conn
        |> Plug.Conn.put_status(:internal_server_error)
        |> Phoenix.Controller.json(%{error: "Unexpected response structure", body: body})

      :spotify_auth_failed ->
        conn
        |> Plug.Conn.put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: "Failed to authenticate with Spotify"})

      {:spotify_api_error, status, body} ->
        conn
        |> Plug.Conn.put_status(:bad_gateway)
        |> Phoenix.Controller.json(%{error: "Spotify API error", status: status, details: body})

      {:http_error, status, body} ->
        conn
        |> Plug.Conn.put_status(:bad_gateway)
        |> Phoenix.Controller.json(%{error: "HTTP error", status: status, details: body})

      {:network_error, reason} ->
        conn
        |> Plug.Conn.put_status(:service_unavailable)
        |> Phoenix.Controller.json(%{error: "Network error", reason: inspect(reason)})

      {:failed_to_fetch_albums, error} ->
        conn
        |> Plug.Conn.put_status(:bad_gateway)
        |> Phoenix.Controller.json(%{
          error: "Failed to fetch albums from Spotify",
          details: inspect(error)
        })

      {:database_error, operation, changeset} ->
        handle_database_error(conn, operation, changeset)
    end
  end
end

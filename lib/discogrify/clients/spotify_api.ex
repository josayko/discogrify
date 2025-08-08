defmodule Discogrify.Clients.SpotifyApi do
  # Client for token requests (accounts.spotify.com)
  defp token_client do
    accounts_url = Application.get_env(:discogrify, :spotify_accounts_url)

    Tesla.client([
      {Tesla.Middleware.BaseUrl, accounts_url},
      {Tesla.Middleware.Headers, [{"content-type", "application/x-www-form-urlencoded"}]},
      Tesla.Middleware.FormUrlencoded,
      Tesla.Middleware.JSON
    ])
  end

  # Client for API requests with bearer token
  defp api_client(token) do
    api_url = Application.get_env(:discogrify, :spotify_api_url)

    Tesla.client([
      {Tesla.Middleware.BaseUrl, api_url},
      {Tesla.Middleware.Headers,
       [
         {"authorization", "Bearer #{token}"},
         {"content-type", "application/json"}
       ]},
      Tesla.Middleware.JSON
    ])
  end

  defp get_token() do
    client_id = Application.get_env(:discogrify, :spotify_client_id)
    client_secret = Application.get_env(:discogrify, :spotify_client_secret)

    token_client()
    |> Tesla.post("/api/token", %{
      grant_type: "client_credentials",
      client_id: client_id,
      client_secret: client_secret
    })
  end

  def get_data(endpoint, token) do
    case api_client(token) |> Tesla.get(endpoint) do
      {:ok, %Tesla.Env{status: status, body: body}} when status >= 200 and status < 300 ->
        {:ok, %{status: status, body: body}}

      {:ok, %Tesla.Env{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, {:network_error, reason}}
    end
  end

  # Helper function to extract access token from the response
  defp extract_access_token({:ok, %Tesla.Env{status: 200, body: %{"access_token" => token}}}),
    do: {:ok, token}

  defp extract_access_token({:ok, %Tesla.Env{status: status, body: body}}),
    do: {:error, {:http_error, status, body}}

  defp extract_access_token({:error, reason}),
    do: {:error, {:network_error, reason}}

  # Convenience function to get token directly
  def get_access_token do
    get_token()
    |> extract_access_token()
  end
end

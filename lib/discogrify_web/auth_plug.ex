defmodule DiscogrifyWeb.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> verify_token(conn, token)
      _ -> unauthorized(conn)
    end
  end

  defp verify_token(conn, token) do
    case Phoenix.Token.verify(DiscogrifyWeb.Endpoint, "user_auth", token, max_age: 86400) do
      {:ok, user_id} ->
        assign(conn, :current_user_id, user_id)

      {:error, _reason} ->
        unauthorized(conn)
    end
  end

  defp unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_resp_content_type("application/json")
    |> json(%{error: "Authentication required"})
    |> halt()
  end
end

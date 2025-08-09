defmodule DiscogrifyWeb.AuthController do
  use DiscogrifyWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias DiscogrifyWeb.Schemas

  plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true

  tags ["Authentication"]

  operation :login,
    summary: "User login",
    description: "Authenticate user and return bearer token",
    operation_id: "login",
    request_body: {"Login credentials", "application/json", Schemas.LoginRequest},
    responses: [
      ok: {"Login successful", "application/json", Schemas.LoginResponse},
      unauthorized: {"Invalid credentials", "application/json", Schemas.ErrorResponse}
    ]

  def login(conn, _params) do
    case conn.body_params do
      %Schemas.LoginRequest{email: email, password: password} ->
        case authenticate_user(email, password) do
          {:ok, user} ->
            token = Phoenix.Token.sign(DiscogrifyWeb.Endpoint, "user_auth", user.id)

            conn
            |> put_status(:ok)
            |> json(%{token: token, user: %{id: user.id, email: user.email}})

          {:error, :invalid_credentials} ->
            conn
            |> put_status(:unauthorized)
            |> json(%{error: "Invalid credentials"})
        end

      _ ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid request body"})
    end
  end

  defp authenticate_user(email, password) do
    # Dummy user authentication logic
    case email do
      "user@example.com" ->
        case password do
          "password" ->
            {:ok, %{id: 1, email: "user@example.com"}}

          _ ->
            {:error, :invalid_credentials}
        end

      _ ->
        {:error, :invalid_credentials}
    end
  end
end

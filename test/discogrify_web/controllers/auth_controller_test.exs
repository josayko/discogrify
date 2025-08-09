defmodule DiscogrifyWeb.AuthControllerTest do
  use DiscogrifyWeb.ConnCase

  import OpenApiSpex.TestAssertions

  @login_url "/api/auth/login"

  describe "POST /api/auth/login" do
    test "returns token and user for valid credentials", %{conn: conn} do
      login_params = %{
        email: "user@example.com",
        password: "password"
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      assert json_response(conn, 200) == %{
               "token" => conn.resp_body |> Jason.decode!() |> get_in(["token"]),
               "user" => %{
                 "id" => 1,
                 "email" => "user@example.com"
               }
             }

      # Verify the token structure
      response = json_response(conn, 200)
      assert Map.has_key?(response, "token")
      assert Map.has_key?(response, "user")
      assert response["user"]["id"] == 1
      assert response["user"]["email"] == "user@example.com"

      # Verify the token can be verified
      token = response["token"]
      assert {:ok, 1} = Phoenix.Token.verify(DiscogrifyWeb.Endpoint, "user_auth", token)
    end

    test "returns unauthorized for invalid email", %{conn: conn} do
      login_params = %{
        email: "invalid@example.com",
        password: "password"
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      assert json_response(conn, 401) == %{
               "error" => "Invalid credentials"
             }
    end

    test "returns unauthorized for invalid password", %{conn: conn} do
      login_params = %{
        email: "user@example.com",
        password: "wrong_password"
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      assert json_response(conn, 401) == %{
               "error" => "Invalid credentials"
             }
    end

    test "returns error for missing email", %{conn: conn} do
      login_params = %{
        password: "password"
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      # OpenApiSpex validation should catch this
      assert conn.status == 422
      response = json_response(conn, 422)
      assert Map.has_key?(response, "errors")
    end

    test "returns error for missing password", %{conn: conn} do
      login_params = %{
        email: "user@example.com"
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      # OpenApiSpex validation should catch this
      assert conn.status == 422
      response = json_response(conn, 422)
      assert Map.has_key?(response, "errors")
    end

    test "returns error for empty request body", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, %{})

      # OpenApiSpex validation should catch this
      assert conn.status == 422
      response = json_response(conn, 422)
      assert Map.has_key?(response, "errors")
    end

    test "returns error for invalid content type", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "text/plain")
        |> post(@login_url, "invalid data")

      # Should return 415 Unsupported Media Type or similar
      assert conn.status in [415, 422]
    end

    test "returns error for malformed JSON", %{conn: conn} do
      assert_raise Plug.Parsers.ParseError, fn ->
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, "{invalid json}")
      end
    end

    test "validates response against OpenAPI schema for successful login", %{conn: conn} do
      login_params = %{
        email: "user@example.com",
        password: "password"
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      assert_schema(json_response(conn, 200), "LoginResponse", DiscogrifyWeb.ApiSpec.spec())
    end

    test "validates response against OpenAPI schema for error response", %{conn: conn} do
      login_params = %{
        email: "invalid@example.com",
        password: "password"
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      assert_schema(json_response(conn, 401), "ErrorResponse", DiscogrifyWeb.ApiSpec.spec())
    end
  end

  describe "authentication edge cases" do
    test "handles special characters in email", %{conn: conn} do
      login_params = %{
        email: "user+test@example.com",
        password: "password"
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      # Should still return unauthorized since this email is not in our dummy auth
      assert json_response(conn, 401) == %{
               "error" => "Invalid credentials"
             }
    end

    test "handles very long email", %{conn: conn} do
      long_email = String.duplicate("a", 100) <> "@example.com"

      login_params = %{
        email: long_email,
        password: "password"
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      assert json_response(conn, 401) == %{
               "error" => "Invalid credentials"
             }
    end

    test "handles empty string values", %{conn: conn} do
      login_params = %{
        email: "",
        password: ""
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      # OpenApiSpex should validate email format and password minLength
      assert conn.status == 422
    end

    test "handles null values", %{conn: conn} do
      login_params = %{
        email: nil,
        password: nil
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(@login_url, login_params)

      # OpenApiSpex should catch null values
      assert conn.status == 422
    end
  end
end

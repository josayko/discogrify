defmodule DiscogrifyWeb.ApiSpec do
  @moduledoc """
  OpenAPI specification for Discogrify API.
  """
  alias OpenApiSpex.{
    Components,
    Info,
    OpenApi,
    Paths,
    SecurityScheme,
    Server,
    Tag
  }

  alias DiscogrifyWeb.{Endpoint, Router}
  @behaviour OpenApi

  @impl OpenApi
  def spec do
    %OpenApi{
      servers: [
        # Populate the Server info from a phoenix endpoint
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: to_string(Application.spec(:discogrify, :description)),
        version: to_string(Application.spec(:discogrify, :vsn))
      },
      # Populate the paths from a phoenix router
      paths: Paths.from_router(Router),
      # Define tags order - Authentication first, then Albums
      tags: [
        %Tag{
          name: "Authentication",
          description: "Authentication endpoints for user login and token management"
        },
        %Tag{
          name: "Albums",
          description: "Album search and management endpoints"
        }
      ],
      components: %Components{
        securitySchemes: %{
          "bearer" => %SecurityScheme{
            type: "http",
            scheme: "bearer",
            bearerFormat: "Phoenix Token",
            description: "Phoenix built-in token authentication"
          }
        }
      }
    }
    # Discover request/response schemas from path specs
    |> OpenApiSpex.resolve_schema_modules()
  end
end

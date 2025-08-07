defmodule DiscogrifyWeb.ApiSpec do
  @moduledoc """
  OpenAPI specification for Discogrify API.
  """
  alias OpenApiSpex.{
    Info,
    OpenApi,
    Paths,
    Server
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
      paths: Paths.from_router(Router)
    }
    # Discover request/response schemas from path specs
    |> OpenApiSpex.resolve_schema_modules()
  end
end

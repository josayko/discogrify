# Discogrify

## Prerequisites

- Elixir: Elixir 1.18.4 (compiled with Erlang/OTP 27)
- Docker: Docker version 28.3.3

### Setup the database
```sh
# You can customize the database config in `compose.yaml`
docker compose up -d
```
- PostgreSQL 17.5 is running on port 5432. You can change the port in `compose.yaml` and `config/dev.exs` accordingly.

### Setup the environment
- Copy `.env.example` to `.env`
- Don't change the `SPOTIFY_ACCOUNTS_URL`, it must be `https://accounts.spotify.com`.
- Don't change the `SPOTIFY_BASE_URL`, it must be `https://api.spotify.com/v1`.

- Create a spotify account and get your `client_id` and `client_secret` from the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/applications).
- Fill in the values for `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET` in your `.env` file.

### Setup the application
- Run `mix setup` to install the dependencies, compile the assets, generate and migrate the database
- Start Phoenix app with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000/api`](http://localhost:4000/api) from your browser.

### Usage
The API requires authentication to access the endpoints, the default user is `user@example.com` with password `password`.

#### Swager UI (recommended)
-  Request the login endpoint on the [Swagger UI](http://localhost:4001/api#/Authentication/login) and provide the Bearer `token` in the `Authorize 🔓` settings.

#### cURL
```sh
curl -X 'POST' \
  'http://localhost:4000/api/auth/login' \
  -H 'Content-Type: application/json' \
  -d '{
  "email": "user@example.com",
  "password": "password"
}'
# {"user":{"id":1,"email":"user@example.com"},"token":"SFMyNTY.g2gDYQFuBgCTGUiOmAFiAAFRgA.RoJlZK_GXSTLfcMy8eveN9yP3zKeU-ny4eEA-HmubnI"}
```

#### Example request to the albums endpoint
```sh
curl -H "Authorization: Bearer SFMyNTY.g2gDYQFuBgCTGUiOmAFiAAFRgA.RoJlZK_GXSTLfcMy8eveN9yP3zKeU-ny4eEA-HmubnI" \
  "http://localhost:4000/api/albums?artist_name=radiohead"
```

## API Spec
### Generating the spec
- If you want to generate the OpenAPI spec
```
mix openapi.spec.json --spec DiscogrifyWeb.ApiSpec
```

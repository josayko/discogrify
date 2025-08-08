# Discogrify

## Prerequisites

- Elixir: Elixir 1.18.4 (compiled with Erlang/OTP 27)
- Docker: Docker version 28.3.3

### Setup the database
```sh
# You can customize the database config in `compose.yaml`
docker-compose up -d
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

## API Spec
### Generating the spec
- If you want to generate the OpenAPI spec
```
mix openapi.spec.json --spec DiscogrifyWeb.ApiSpec
```
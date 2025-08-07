# Discogrify

## Development

Tested on MacOS 15.5 (Sequoia) with:
- Elixir: Elixir 1.18.4 (compiled with Erlang/OTP 27)
- Docker: Docker version 28.3.3, build 980b856816

### Setup the database
```sh
# You can customize the database config in `compose.yaml`
docker-compose up -d
```
- PostgreSQL 17.5 is running on port 5432. You can change the port in `compose.yaml` and `config/dev.exs` accordingly.

### Setup the application
- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000/api`](http://localhost:4000/api) from your browser.

## API Spec
### Generating the spec
```
mix openapi.spec.json --spec DiscogrifyWeb.ApiSpec
```
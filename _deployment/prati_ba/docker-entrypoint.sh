#!/bin/bash
set -e

mix ecto.setup
mix ua_inspector.download --force --quiet
elixir -S mix run -e 'Geolix.reload_databases()'

exec "$@"

#!/bin/bash
set -e

mix ecto.setup
mix ua_inspector.download --force --quiet

exec "$@"

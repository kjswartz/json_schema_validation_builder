#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /json_schema_validation_builder/tmp/pids/server.pid

# Wait for the PostgreSQL server to be ready
./wait-for-it.sh db:5432 --timeout=30 --strict -- echo "PostgreSQL is up - executing command"

# setup databases and run migrations if present
bundle exec rails db:prepare
bundle exec rails db:prepare RAILS_ENV=test

# Precompile assets
bundle exec rails assets:precompile

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"

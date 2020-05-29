#!/bin/bash
set -e

bin/prati_ba eval 'UAInspector.Downloader.download'
bin/prati_ba eval 'Geolix.reload_databases'

exec "$@"

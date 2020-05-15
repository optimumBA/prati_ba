#!/bin/bash
set -e

bin/prati_ba eval 'PratiBa.Release.migrate'
bin/prati_ba eval 'PratiBa.Release.seed'
bin/prati_ba eval 'UAInspector.Downloader.download'
bin/prati_ba eval 'Geolix.reload_databases'

exec "$@"

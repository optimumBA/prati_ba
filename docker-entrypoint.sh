#!/bin/bash
set -e

bin/prati_ba eval 'UAInspector.Downloader.download'
ln -s /data/articles lib/prati_ba-0.1.0/priv/static/articles

exec "$@"

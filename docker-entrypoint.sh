#!/bin/sh

bin/prati_ba eval 'UAInspector.Downloader.download'

rm -rf /app/lib/prati_ba-0.1.0/priv/static/articles
mkdir -p /data/articles
ln -s /data/articles/ /app/lib/prati_ba-0.1.0/priv/static/articles

exec "$@"

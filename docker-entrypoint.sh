#!/bin/bash
set -e

export POD_A_RECORD=$(echo $POD_IP | sed 's/\./-/g')
bin/prati_ba eval 'UAInspector.Downloader.download'

exec "$@"

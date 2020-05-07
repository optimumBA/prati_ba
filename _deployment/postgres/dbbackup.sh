#!/bin/bash
echo "$(date) Backing database prati_ba up in mode $1"

BF=/tmp/prati_ba-db-$(date +%Y%m%d%H%M%S).tar.gz
pg_dump --format=tar --encoding=UTF8 postgres://postgres:$POSTGRES_PASSWORD@postgres:5432/prati_ba > $BF

echo "$(date) Uploading into AWS S3 $BF"
s3cmd put $BF --access_key=$AWS_KEY --secret_key=$AWS_SECRET --storage-class=STANDARD_IA --server-side-encryption --region=$S3REGION s3://$S3BUCKET/$1/

rm $BF

#!/bin/bash

# Create file with environment variables otherwise the variables are not visible to cron job
printenv | sed 's/^\(.*\)$/export \1/g' > /root/project_env.sh
chmod 755 /root/project_env.sh

# Start cron
cron

# Start PostgreSQL database
/docker-entrypoint.sh postgres

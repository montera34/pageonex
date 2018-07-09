#!/bin/bash
# cleanup-pid-file-and-wait-for-mysql.sh

set -e

host="$1"
password="$2"
shift; shift
cmd="$@"

rm -f /workspace/tmp/pids/server.pid

port=${DATABASE_PORT:-3306}

until mysql -u root --port $port --password=$password -h $host -e "SELECT 1"; do
  >&2 echo "Mysql is unavailable - sleeping"
  sleep 1
done

>&2 echo "Mysql is up - executing command"
exec $cmd

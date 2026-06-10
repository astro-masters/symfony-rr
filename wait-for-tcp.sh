#!/usr/bin/env sh
set -eu

HOST="${1:-}"
PORT="${2:-}"
TIMEOUT_SECONDS="${3:-60}"

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
  echo "Нужно указать host и port" 1>&2
  exit 2
fi

if [ -z "$TIMEOUT_SECONDS" ]; then
  TIMEOUT_SECONDS=60
fi

i=0
while true; do
  if php -r '$host=$argv[1]; $port=(int) $argv[2]; $s=@fsockopen($host, $port, $errno, $errstr, 1); if ($s) { fclose($s); exit(0);} exit(1);' -- "$HOST" "$PORT"; then
    exit 0
  fi

  i=$((i+1))
  if [ "$i" -ge "$TIMEOUT_SECONDS" ]; then
    echo "${HOST}:${PORT} не поднялся за ${TIMEOUT_SECONDS} секунд" 1>&2
    exit 1
  fi

  sleep 1

done

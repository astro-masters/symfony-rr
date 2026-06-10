#!/usr/bin/env sh
set -eu

TRANSPORT="${1:-}"

if [ -z "$TRANSPORT" ]; then
  echo "Нужно указать имя транспорта Messenger (например: songs)" 1>&2
  exit 2
fi

WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-60}"
MESSENGER_TIME_LIMIT="${MESSENGER_TIME_LIMIT:-3600}"
MESSENGER_MEMORY_LIMIT="${MESSENGER_MEMORY_LIMIT:-256M}"

if [ ! -f /usr/local/bin/wait-for-tcp.sh ]; then
  echo "Не найден /usr/local/bin/wait-for-tcp.sh" 1>&2
  exit 2
fi

sh /usr/local/bin/wait-for-tcp.sh rabbitmq 5672 "$WAIT_TIMEOUT_SECONDS"

exec php bin/console messenger:consume "$TRANSPORT" --verbose --time-limit="$MESSENGER_TIME_LIMIT" --memory-limit="$MESSENGER_MEMORY_LIMIT" ${MESSENGER_CONSUME_EXTRA_ARGS:-}

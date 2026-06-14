#!/usr/bin/env sh
set -eu

if [ -f .rr.yaml ] && [ -d public ] && [ -f public/index.php ] && [ -f vendor/autoload.php ]; then
  exec rr serve -c .rr.yaml
fi

if [ -f public/index.php ] && [ -f vendor/autoload.php ]; then
  exec php -S 0.0.0.0:8080 -t public public/index.php
fi

exec tail -f /dev/null

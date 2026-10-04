# symfony-rr

Базовые Docker-образы для `PHP 8.4/8.5 + Symfony + RoadRunner`.

## Что публикуется

В GHCR публикуются `dev` и `prod` образы для каждой поддерживаемой версии PHP:

- `ghcr.io/astro-masters/symfony-rr:8.4-prod`
- `ghcr.io/astro-masters/symfony-rr:8.4-dev`
- `ghcr.io/astro-masters/symfony-rr:8.5-prod`
- `ghcr.io/astro-masters/symfony-rr:8.5-dev`

Образы публикуются для архитектур:

- `linux/amd64`
- `linux/arm64`

Также публикуются теги:

- `sha-<commit>-8.4-prod`
- `sha-<commit>-8.4-dev`
- `sha-<commit>-8.5-prod`
- `sha-<commit>-8.5-dev`
- `vX.Y.Z-8.4-prod`
- `vX.Y.Z-8.4-dev`
- `vX.Y.Z-8.5-prod`
- `vX.Y.Z-8.5-dev`

Для обратной совместимости PHP 8.4 также получает прежние теги:

- `sha-<commit>-prod`
- `sha-<commit>-dev`
- `vX.Y.Z-prod`
- `vX.Y.Z-dev`

## Что внутри

### prod

- `php:8.4-cli` или `php:8.5-cli`
- RoadRunner
- Composer
- системные библиотеки
- основные PHP extensions
- пользователь `app`
- встроенные `php.ini`, `start.sh`, `worker-start.sh`, `wait-for-tcp.sh`

### dev

Дополнительно к `prod`:

- Xdebug
- Symfony CLI
- zsh
- oh-my-zsh
- aliases
- `.zshrc`
- `99-xdebug.ini`

## Публикация

Образы публикуются GitHub Actions workflow-ом `.github/workflows/publish.yml`.

Workflow запускается:

- при push в `main`
- при push git-тега `v*`
- вручную через `workflow_dispatch`

Для публикации в GHCR используются права:

- `contents: read`
- `packages: write`

## Использование в проектах

### dev

```yaml
services:
  api:
    image: ghcr.io/astro-masters/symfony-rr:8.4-dev
    working_dir: /var/www/api
    volumes:
      - ./api:/var/www/api
```

Для PHP 8.5 укажите соответствующий тег:

```yaml
services:
  api:
    image: ghcr.io/astro-masters/symfony-rr:8.5-dev
    working_dir: /var/www/api
    volumes:
      - ./api:/var/www/api
```

### prod base

```yaml
services:
  api:
    image: ghcr.io/astro-masters/symfony-rr:8.4-prod
```

Для PHP 8.5:

```yaml
services:
  api:
    image: ghcr.io/astro-masters/symfony-rr:8.5-prod
```

## Рекомендация для production-проектов

Для production лучше собирать проектный образ на базе нужной версии PHP:

```dockerfile
ARG PHP_VERSION=8.5

FROM ghcr.io/astro-masters/symfony-rr:${PHP_VERSION}-prod

COPY ./api /var/www/api
```

## Локальная сборка

### dev

```bash
docker build --build-arg PHP_VERSION=8.4 --target dev -t symfony-rr:8.4-dev .
docker build --build-arg PHP_VERSION=8.5 --target dev -t symfony-rr:8.5-dev .
```

### prod

```bash
docker build --build-arg PHP_VERSION=8.4 --target prod -t symfony-rr:8.4-prod .
docker build --build-arg PHP_VERSION=8.5 --target prod -t symfony-rr:8.5-prod .
```

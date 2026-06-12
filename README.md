# symfony-rr

Базовые Docker-образы для `PHP 8.4 + Symfony + RoadRunner`.

## Что публикуется

В GHCR публикуются два target-образа из одного `Dockerfile`:

- `ghcr.io/astro-masters/symfony-rr:8.4-prod`
- `ghcr.io/astro-masters/symfony-rr:8.4-dev`

Образы публикуются для архитектур:

- `linux/amd64`
- `linux/arm64`

Также публикуются теги:

- `sha-<commit>-prod`
- `sha-<commit>-dev`
- `vX.Y.Z-prod`
- `vX.Y.Z-dev`

## Что внутри

### prod

- `php:8.4-cli`
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

### prod base

```yaml
services:
  api:
    image: ghcr.io/astro-masters/symfony-rr:8.4-prod
```

## Рекомендация для production-проектов

Для production лучше собирать проектный образ на базе `8.4-prod`:

```dockerfile
FROM ghcr.io/astro-masters/symfony-rr:8.4-prod

COPY ./api /var/www/api
```

## Локальная сборка

### dev

```bash
docker build --target dev -t symfony-rr:dev .
```

### prod

```bash
docker build --target prod -t symfony-rr:prod .
```

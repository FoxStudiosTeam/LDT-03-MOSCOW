# Документация по сборке и запуску

## Зависимости

- Rust (cargo)
- Node.js + npm
- PostgreSQL
- S3-совместимое хранилище (например, MinIO)
- Kubernetes (опционально, для деплоя в кластер)
- Dart SDK
- Flutter SDK

---

## Сборка микросервисов

### Вручную

```bash
cargo build --release -p attachment -p attachmentproxy -p material -p punishment -p project
```

---

## Конфигурация

### Общая

| Переменная       | Описание |
|------------------|----------|
| `PORT`           | Порт, на котором будет работать сервис |
| `DB_URL`         | URL для подключения к PostgreSQL |
| `S3_URL`         | Адрес S3-хранилища |
| `S3_KEY`         | Ключ доступа к S3 |
| `S3_SECRET`      | Секретный ключ доступа к S3 |
| `S3_BUCKET`      | Имя бакета для хранения файлов |
| `METRICS_USER`   | Логин для доступа к Prometheus-метрикам |
| `METRICS_PORT`   | Порт для Prometheus-метрик |
| `PUBLIC_PEM`     | Публичный ключ SSO-сервиса для проверки JWT |
| `PRIVATE_PEM`    | Локальный приватный ключ (**оставить пустым**) |

⚠️ Для корректной работы **middleware** с проверкой JWT необходимо передать **публичный сертификат** SSO-сервиса.

## Пример `.env`

```env
PORT=9100
DB_URL=postgresql://user:pass5@user@example.ru:5432/default_db
REDIS_URL=redis://default:user@example.ru:6379/0

S3_URL=https://s3.twcstorage.ru
S3_KEY=FiShChIpS
S3_SECRET=SuPeRsEcReT
S3_BUCKET=-store

METRICS_USERNAME=metrics
METRICS_PASSWORD=metrics

PUBLIC_PEM=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0DNHVfSRAi1/QbtgYHuS

PRIVATE_PEM=""
```

---

### Документация API

После запуска каждого сервиса документация будет доступна по адресу:

```
http://localhost:<PORT>/api/<SERVICE>/docs/scalar
```

---

### Kubernetes

Можно поднять сервисы в Kubernetes-кластере. Все конфигурации находятся в каталоге:

```
backend/.deployment/<SERVICE>
```

---

## Сборка фронтенда

```bash
npm run build
node run service
```

---


# Мобильное приложение 
```bash
cd mobile_flutter
flutter run
```












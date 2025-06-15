# Microservices App - Контейнеризиран проект с Docker Compose

Този проект демонстрира контейнеризация на микросервисно приложение използвайки Docker и Docker Compose. Приложението включва Python Flask API, PostgreSQL база данни, Redis кеш и Nginx reverse proxy.

## 🏗️ Архитектура на проекта

```
microservices-app/
├── backend/                 # Python Flask API
│   ├── app.py              # Основно приложение
│   ├── models/             # Модели за данни
│   │   └── user.py
│   ├── routes/             # API маршрути
│   │   └── api.py
│   ├── database/           # База данни слой
│   │   └── db.py
│   ├── requirements.txt    # Python зависимости
│   └── Dockerfile         # Docker конфигурация за backend
├── database/              # База данни конфигурация
│   └── init.sql          # SQL инициализация
├── nginx/                # Reverse proxy конфигурация
│   └── nginx.conf
├── compose.yml           # Docker Compose конфигурация
├── .env                 # Environment променливи
└── README.md           # Документация
```

## 🚀 Компоненти

### Backend API (Python Flask)
- **Порт**: 5000
- **Функционалности**: 
  - REST API за управление на потребители
  - Redis кеширане
  - PostgreSQL връзка
  - Health check endpoints

### PostgreSQL Database
- **Порт**: 5432
- **База данни**: appdb
- **Функционалности**:
  - Съхранение на потребители
  - Автоматична инициализация
  - Логиране на действия

### Redis Cache
- **Порт**: 6379
- **Функционалности**:
  - Кеширане на заявки
  - Persistance на данни

### Nginx Reverse Proxy
- **Порт**: 80
- **Функционалности**:
  - Load balancing
  - Static файлове кеширане
  - Proxy към backend API

### pgAdmin (Опционално)
- **Порт**: 8080
- **Функционалности**:
  - Web интерфейс за управление на PostgreSQL

## 📦 Инсталация и стартиране

### Предпоставки
- Docker
- Docker Compose

### Стъпки за стартиране

1. **Клониране на проекта**
```bash
git clone https://github.com/yourusername/microservices-app.git
cd microservices-app
```

2. **Създаване на необходимите директории**
```bash
mkdir -p nginx backend/models backend/routes backend/database database
```

3. **Стартиране на всички услуги**
```bash
docker compose up -d
```

4. **Проверка на статуса**
```bash
docker compose ps
```

5. **Преглед на логовете**
```bash
docker compose logs -f
```

## 🛠️ Изграждане на образите

### Изграждане на backend образа
```bash
cd backend
docker build -t yourusername/microservices-backend:latest .
```

### Публикуване в Docker Hub
```bash
docker tag yourusername/microservices-backend:latest yourusername/microservices-backend:v1.0.0
docker push yourusername/microservices-backend:latest
docker push yourusername/microservices-backend:v1.0.0
```

## 🌐 API Endpoints

### Health Check
- `GET /` - Основна health check
- `GET /health` - Детайлна health check

### Users API
- `GET /api/users` - Получаване на всички потребители
- `GET /api/users/{id}` - Получаване на потребител по ID
- `POST /api/users` - Създаване на нов потребител

### Stats API
- `GET /api/stats` - Статистики за приложението

### Примери за заявки

```bash
# Health check
curl http://localhost/health

# Получаване на всички потребители
curl http://localhost/api/users

# Създаване на потребител
curl -X POST http://localhost/api/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "email": "test@example.com"}'
```

## 🐳 Docker Compose услуги

### Backend
```yaml
backend:
  build: ./backend
  ports: ["5000:5000"]
  environment:
    - DATABASE_URL=postgresql://postgres:postgres@db:5432/appdb
    - REDIS_URL=redis://redis:6379
```

### Database
```yaml
db:
  image: postgres:15-alpine
  environment:
    - POSTGRES_DB=appdb
    - POSTGRES_USER=postgres
    - POSTGRES_PASSWORD=postgres
```

### Redis
```yaml
redis:
  image: redis:7-alpine
  command: redis-server --appendonly yes
```

## 🔧 Конфигурация

### Environment променливи (.env)
```bash
DATABASE_URL=postgresql://postgres:postgres@db:5432/appdb
REDIS_URL=redis://redis:6379
FLASK_ENV=production
```

### Здравни проверки
Всички услуги имат конфигурирани healthcheck-ове за наблюдение на състоянието.

## 📊 Monitoring и Logs

### Преглед на логовете
```bash
# Всички услуги
docker compose logs -f

# Конкретна услуга
docker compose logs -f backend
```

### Monitoring на контейнерите
```bash
docker compose top
docker stats
```

## 🛡️ Сигурност

- Non-root потребители в контейнерите
- Healthcheck-ове за всички услуги
- Изолирана мрежа между услугите
- Environment променливи за sensitive данни

## 🚦 Troubleshooting

### Общи проблеми

1. **Порт конфликти**
   - Проверете свободни портове: `netstat -tlnp`
   - Променете портовете в compose.yml

2. **База данни не се свързва**
   - Проверете health check: `docker compose ps`
   - Прегледайте логовете: `docker compose logs db`

3. **Backend crash**
   - Проверете зависимостите в requirements.txt
   - Прегледайте логовете: `docker compose logs backend`

### Полезни команди
```bash
# Рестартиране на услуга
docker compose restart backend

# Спиране на всички услуги
docker compose down

# Спиране с изтриване на volumes
docker compose down -v

# Rebuild на образите
docker compose up
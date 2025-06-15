# Файл: backend/Dockerfile
FROM python:3.11-slim

# Задаване на работна директория
WORKDIR /app

# Копиране на requirements файла
COPY requirements.txt .

# Инсталиране на зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копиране на кода на приложението
COPY . .

# Създаване на non-root потребител
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Expose на порта
EXPOSE 5000

# Здравна проверка
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Стартиране на приложението
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]

#!/bin/bash
# Файл: scripts/test_api.sh
# Скрипт за тестване на API endpoints

set -e

echo "🧪 Тестване на Microservices App API..."

BASE_URL="http://localhost"

# Функция за проверка на HTTP статус
check_status() {
    local url=$1
    local expected_status=${2:-200}
    local actual_status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$actual_status" -eq "$expected_status" ]; then
        echo "✅ $url - Status: $actual_status"
    else
        echo "❌ $url - Expected: $expected_status, Got: $actual_status"
        exit 1
    fi
}

# Изчакване за стартиране на услугите
echo "⏳ Изчакване за стартиране на услугите..."
sleep 10

echo "🔍 Тестване на health endpoints..."
check_status "$BASE_URL/"
check_status "$BASE_URL/health"

echo "👥 Тестване на users API..."
check_status "$BASE_URL/api/users"
check_status "$BASE_URL/api/users/1"

echo "📊 Тестване на stats API..."
check_status "$BASE_URL/api/stats"

echo "➕ Тестване на създаване на потребител..."
RESPONSE=$(curl -s -X POST "$BASE_URL/api/users" \
    -H "Content-Type: application/json" \
    -d '{"name": "Test User", "email": "test@test.com"}' \
    -w "%{http_code}")

if [[ "$RESPONSE" == *"201" ]]; then
    echo "✅ POST /api/users - Status: 201"
else
    echo "❌ POST /api/users - Failed"
    exit 1
fi

echo "🎉 Всички тестове преминаха успешно!"
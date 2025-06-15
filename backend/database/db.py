# Файл: backend/database/db.py
import psycopg2
import redis
import os
from contextlib import contextmanager

# Конфигурация за база данни
DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://user:password@localhost:5432/appdb')
REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379')

# Redis connection
redis_client = redis.from_url(REDIS_URL, decode_responses=True)

@contextmanager
def get_db_connection():
    """Context manager за връзка с базата данни"""
    conn = None
    try:
        conn = psycopg2.connect(DATABASE_URL)
        yield conn
    except Exception as e:
        if conn:
            conn.rollback()
        raise e
    finally:
        if conn:
            conn.close()

def init_db():
    """Инициализиране на базата данни"""
    try:
        with get_db_connection() as conn:
            cursor = conn.cursor()
            
            # Създаване на таблица users
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(100) NOT NULL,
                    email VARCHAR(100) UNIQUE NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            
            # Добавяне на примерни данни
            cursor.execute("""
                INSERT INTO users (name, email) 
                VALUES ('John Doe', 'john@example.com'),
                       ('Jane Smith', 'jane@example.com')
                ON CONFLICT (email) DO NOTHING
            """)
            
            conn.commit()
            print("Database initialized successfully!")
            
    except Exception as e:
        print(f"Error initializing database: {e}")

def get_redis_client():
    """Връща Redis клиент"""
    return redis_client
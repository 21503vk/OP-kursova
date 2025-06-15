# Файл: backend/models/user.py
import json
from database.db import get_db_connection, get_redis_client

class User:
    def __init__(self, id=None, name=None, email=None, created_at=None):
        self.id = id
        self.name = name
        self.email = email
        self.created_at = created_at
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
    
    @staticmethod
    def get_all():
        """Взема всички потребители с кеширане"""
        redis_client = get_redis_client()
        cache_key = "users:all"
        
        # Проверка в кеша
        cached_users = redis_client.get(cache_key)
        if cached_users:
            users_data = json.loads(cached_users)
            return [User(**user) for user in users_data]
        
        # Заявка към базата данни
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT id, name, email, created_at FROM users ORDER BY id")
            rows = cursor.fetchall()
            
            users = []
            for row in rows:
                user = User(id=row[0], name=row[1], email=row[2], created_at=row[3])
                users.append(user)
            
            # Кеширане за 5 минути
            users_data = [user.to_dict() for user in users]
            redis_client.setex(cache_key, 300, json.dumps(users_data, default=str))
            
            return users
    
    @staticmethod
    def get_by_id(user_id):
        """Взема потребител по ID"""
        redis_client = get_redis_client()
        cache_key = f"user:{user_id}"
        
        # Проверка в кеша
        cached_user = redis_client.get(cache_key)
        if cached_user:
            user_data = json.loads(cached_user)
            return User(**user_data)
        
        # Заявка към базата данни
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT id, name, email, created_at FROM users WHERE id = %s", (user_id,))
            row = cursor.fetchone()
            
            if row:
                user = User(id=row[0], name=row[1], email=row[2], created_at=row[3])
                # Кеширане за 5 минути
                redis_client.setex(cache_key, 300, json.dumps(user.to_dict(), default=str))
                return user
            
            return None
    
    def save(self):
        """Запазва нов потребител"""
        with get_db_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO users (name, email) VALUES (%s, %s) RETURNING id, created_at",
                (self.name, self.email)
            )
            result = cursor.fetchone()
            self.id = result[0]
            self.created_at = result[1]
            conn.commit()
            
            # Изчистване на кеша
            redis_client = get_redis_client()
            redis_client.delete("users:all")
            
            return self
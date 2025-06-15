-- Файл: database/init.sql
-- Инициализация на базата данни

-- Създаване на таблица users
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Създаване на индекс за email
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Добавяне на примерни данни
INSERT INTO users (name, email) VALUES 
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com'),
('Bob Johnson', 'bob@example.com')
ON CONFLICT (email) DO NOTHING;

-- Създаване на таблица за логове
CREATE TABLE IF NOT EXISTS logs (
    id SERIAL PRIMARY KEY,
    level VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Създаване на функция за логиране
CREATE OR REPLACE FUNCTION log_user_action()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs (level, message) 
    VALUES ('INFO', 'User action: ' || TG_OP || ' on user ' || COALESCE(NEW.email, OLD.email));
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Създаване на тригер за логиране на действия с потребители
DROP TRIGGER IF EXISTS user_action_trigger ON users;
CREATE TRIGGER user_action_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION log_user_action();
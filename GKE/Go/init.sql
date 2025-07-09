-- Database initialization script for PostgreSQL
-- This script creates the initial database schema

-- Create messages table if it doesn't exist
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on created_at for better query performance
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

-- Insert some sample data
INSERT INTO messages (body) VALUES 
    ('Welcome to the Go application!'),
    ('This is a sample message from PostgreSQL'),
    ('Redis cache is also configured')
ON CONFLICT DO NOTHING;

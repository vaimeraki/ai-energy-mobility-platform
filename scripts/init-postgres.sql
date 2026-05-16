-- Initialize PostgreSQL with pgvector extension for AI platform
-- This script runs automatically when the PostgreSQL container starts

-- Enable the pgvector extension for vector operations
CREATE EXTENSION IF NOT EXISTS vector;

-- Create schemas for different data domains
CREATE SCHEMA IF NOT EXISTS energy;
CREATE SCHEMA IF NOT EXISTS mobility;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS ai;

-- Create table for storing embeddings (RAG use case)
CREATE TABLE IF NOT EXISTS ai.document_embeddings (
    id SERIAL PRIMARY KEY,
    document_id VARCHAR(255) NOT NULL,
    content TEXT,
    embedding vector(1536), -- OpenAI embedding dimension
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for efficient vector search
CREATE INDEX IF NOT EXISTS idx_document_embeddings_embedding ON ai.document_embeddings 
USING ivfflat (embedding vector_cosine_ops);

CREATE INDEX IF NOT EXISTS idx_document_embeddings_document_id ON ai.document_embeddings(document_id);

-- Create table for energy data cache
CREATE TABLE IF NOT EXISTS energy.data_cache (
    id SERIAL PRIMARY KEY,
    source VARCHAR(100) NOT NULL,
    data_type VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    data JSONB NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create table for mobility data cache
CREATE TABLE IF NOT EXISTS mobility.data_cache (
    id SERIAL PRIMARY KEY,
    source VARCHAR(100) NOT NULL,
    data_type VARCHAR(100) NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    data JSONB NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create table for analytics results
CREATE TABLE IF NOT EXISTS analytics.results (
    id SERIAL PRIMARY KEY,
    analysis_type VARCHAR(100) NOT NULL,
    parameters JSONB,
    results JSONB NOT NULL,
    confidence_score FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Grant permissions to the aem_user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA energy TO aem_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA mobility TO aem_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO aem_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ai TO aem_user;

-- Grant usage on schemas
GRANT USAGE ON SCHEMA energy TO aem_user;
GRANT USAGE ON SCHEMA mobility TO aem_user;
GRANT USAGE ON SCHEMA analytics TO aem_user;
GRANT USAGE ON SCHEMA ai TO aem_user;

-- Grant sequence permissions
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA energy TO aem_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA mobility TO aem_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA analytics TO aem_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ai TO aem_user;

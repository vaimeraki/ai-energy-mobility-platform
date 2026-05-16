#!/bin/bash

# MinIO Lakehouse Setup Script
# Creates the standard lakehouse bucket structure for AEM platform

set -e

echo "🚀 Setting up MinIO Lakehouse for AI Energy Mobility Platform..."

# MinIO connection details
MINIO_ENDPOINT="http://localhost:9000"
MINIO_ACCESS_KEY="minioadmin"
MINIO_SECRET_KEY="minioadmin123"

# Wait for MinIO to be ready
echo "⏳ Waiting for MinIO to be ready..."
until curl -s "$MINIO_ENDPOINT/minio/health/live" > /dev/null; do
    echo "   MinIO not ready, waiting 5 seconds..."
    sleep 5
done

echo "✅ MinIO is ready!"

# Install MinIO client if not present
if ! command -v mc &> /dev/null; then
    echo "📦 Installing MinIO client..."
    curl -s https://dl.min.io/client/mc/release/linux-amd64/mc \
        --create-dirs \
        -o /tmp/mc
    chmod +x /tmp/mc
    sudo mv /tmp/mc /usr/local/bin/mc
fi

# Configure MinIO client
echo "⚙️  Configuring MinIO client..."
mc alias set local $MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY

# Create lakehouse buckets
echo "🪣 Creating lakehouse buckets..."

# Raw data bucket (ingestion landing zone)
mc mb local/aem-raw --ignore-existing
echo "   ✅ Created bucket: aem-raw"

# Processed data bucket (cleaned, transformed data)
mc mb local/aem-processed --ignore-existing
echo "   ✅ Created bucket: aem-processed"

# Analytics bucket (aggregated, feature-engineered data)
mc mb local/aem-analytics --ignore-existing
echo "   ✅ Created bucket: aem-analytics"

# Create bucket policies for public read (development only)
echo "📋 Setting bucket policies..."

# Policy for raw bucket (private)
mc anonymous set private local/aem-raw

# Policy for processed bucket (private)
mc anonymous set private local/aem-processed

# Policy for analytics bucket (private)
mc anonymous set private local/aem-analytics

# Create folder structure within buckets
echo "📁 Creating folder structure..."

# Raw bucket structure
mc mb local/aem-raw/energy --ignore-existing
mc mb local/aem-raw/mobility --ignore-existing
mc mb local/aem-raw/environmental --ignore-existing

# Processed bucket structure
mc mb local/aem-processed/energy --ignore-existing
mc mb local/aem-processed/mobility --ignore-existing
mc mb local/aem-processed/environmental --ignore-existing

# Analytics bucket structure
mc mb local/aem-analytics/features --ignore-existing
mc mb local/aem-analytics/models --ignore-existing
mc mb local/aem-analytics/reports --ignore-existing

echo ""
echo "🎉 MinIO Lakehouse setup complete!"
echo ""
echo "📊 Bucket Structure:"
echo "   aem-raw/           - Raw ingested data"
echo "   aem-processed/     - Cleaned & transformed data"
echo "   aem-analytics/     - Analytics & features"
echo ""
echo "🌐 MinIO Console: http://localhost:9001"
echo "   Username: minioadmin"
echo "   Password: minioadmin123"
echo ""
echo "🔗 S3 Endpoint: http://localhost:9000"
echo "   Access Key: minioadmin"
echo "   Secret Key: minioadmin123"

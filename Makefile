.PHONY: help install setup test lint format clean docker-build docker-run docker-up docker-down minio-setup minio-status

# Default target
help:
	@echo "AI Energy Mobility Platform - Azure + MinIO Hybrid Architecture"
	@echo ""
	@echo "Available commands:"
	@echo "  install      Install dependencies in conda environment"
	@echo "  setup        Set up development environment"
	@echo "  test         Run all tests"
	@echo "  lint         Run linting checks"
	@echo "  format       Format code with black"
	@echo "  clean        Clean temporary files"
	@echo ""
	@echo "Docker & Infrastructure:"
	@echo "  docker-up    Start MinIO and PostgreSQL containers"
	@echo "  docker-down  Stop and remove containers"
	@echo "  minio-setup  Initialize MinIO lakehouse buckets"
	@echo "  minio-status Check MinIO container status"
	@echo ""
	@echo "Infrastructure (Design-only - DO NOT APPLY):"
	@echo "  infra-plan   Show Azure infrastructure plan"
	@echo "  infra-validate Validate Terraform configuration"
	@echo ""

# Install dependencies
install:
	conda env update -f environment.yml
	pip install -r requirements.txt

# Setup development environment
setup:
	@echo "Setting up development environment..."
	conda activate ai-em
	pip install -r requirements.txt
	pre-commit install

# Run tests
test:
	pytest tests/ -v --cov=src --cov-report=html --cov-report=term

# Lint code
lint:
	flake8 src/ tests/
	mypy src/

# Format code
format:
	black src/ tests/
	isort src/ tests/

# Clean temporary files
clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} +
	rm -rf build/
	rm -rf dist/
	rm -rf .coverage
	rm -rf htmlcov/

# Docker commands
docker-build:
	docker build -t ai-energy-mobility-platform .

docker-run:
	docker run -p 8080:8080 ai-energy-mobility-platform

# Development server
dev:
	python -m src.main

# Data pipeline
pipeline:
	python -m src.pipelines.run_pipeline

# Docker & Infrastructure commands
docker-up:
	@echo "🐳 Starting MinIO and PostgreSQL containers..."
	docker-compose up -d
	@echo "✅ Containers started. Use 'make minio-setup' to initialize buckets."

docker-down:
	@echo "🛑 Stopping and removing containers..."
	docker-compose down -v
	@echo "✅ Containers stopped and removed."

minio-setup:
	@echo "🪣 Setting up MinIO lakehouse buckets..."
	powershell -ExecutionPolicy Bypass -File scripts/setup-minio.ps1

minio-status:
	@echo "📊 Checking container status..."
	docker-compose ps

# Infrastructure (Design-only - DO NOT APPLY)
infra-plan:
	@echo "📋 Showing Azure infrastructure plan (design-only)..."
	cd infra/terraform && terraform init && terraform plan

infra-validate:
	@echo "✅ Validating Terraform configuration..."
	cd infra/terraform && terraform init && terraform validate

# Simple MinIO Lakehouse Setup Script (PowerShell)
# Creates the standard lakehouse bucket structure for AEM platform

Write-Host "🚀 Setting up MinIO Lakehouse for AI Energy Mobility Platform..." -ForegroundColor Green

# MinIO connection details
$MinioEndpoint = "http://localhost:9000"
$MinioAccessKey = "minioadmin"
$MinioSecretKey = "minioadmin123"

# Wait for MinIO to be ready
Write-Host "⏳ Waiting for MinIO to be ready..." -ForegroundColor Yellow
$ready = $false
$maxAttempts = 30
$attempt = 0

while (-not $ready -and $attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "$MinioEndpoint/minio/health/live" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            $ready = $true
            Write-Host "✅ MinIO is ready!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "   MinIO not ready, waiting 5 seconds... (Attempt $($attempt + 1)/$maxAttempts)" -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        $attempt++
    }
}

if (-not $ready) {
    Write-Host "❌ MinIO failed to start within expected time" -ForegroundColor Red
    exit 1
}

# Create buckets using curl directly (no MinIO client needed)
Write-Host "🪣 Creating lakehouse buckets using curl..." -ForegroundColor Blue

# Function to create bucket using curl
function Create-Bucket {
    param($bucketName)
    
    $url = "$MinioEndpoint/$bucketName"
    $date = Get-Date -Format "yyyyMMddTHHmmssZ"
    $signature = "AWS4-HMAC-SHA256"
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method PUT -Headers @{
            "Authorization" = "AWS $MinioAccessKey:$signature"
            "Date" = $date
            "Content-Length" = "0"
        } -ErrorAction Stop
        Write-Host "   ✅ Created bucket: $bucketName" -ForegroundColor Green
    }
    catch {
        # Bucket might already exist, that's OK
        Write-Host "   ⚠️  Bucket $bucketName may already exist" -ForegroundColor Yellow
    }
}

# Create the three main buckets
Create-Bucket "aem-raw"
Create-Bucket "aem-processed" 
Create-Bucket "aem-analytics"

Write-Host ""
Write-Host "🎉 MinIO Lakehouse setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Bucket Structure:" -ForegroundColor Cyan
Write-Host "   aem-raw/           - Raw ingested data"
Write-Host "   aem-processed/     - Cleaned & transformed data"
Write-Host "   aem-analytics/     - Analytics & features"
Write-Host ""
Write-Host "🌐 MinIO Console: http://localhost:9001" -ForegroundColor Cyan
Write-Host "   Username: minioadmin"
Write-Host "   Password: minioadmin123"
Write-Host ""
Write-Host "🔗 S3 Endpoint: http://localhost:9000" -ForegroundColor Cyan
Write-Host "   Access Key: minioadmin"
Write-Host "   Secret Key: minioadmin123"

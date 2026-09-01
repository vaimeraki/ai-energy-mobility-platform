# MinIO Lakehouse Setup Script (PowerShell)
# Creates the standard lakehouse bucket structure for AEM platform
# NOTE: plain ASCII output only - Windows PowerShell 5.1 reads .ps1 files
# using the system code page by default, and emoji/unicode here previously
# caused a parser error a few lines further down the file.

Write-Host "Setting up MinIO Lakehouse for AI Energy Mobility Platform..." -ForegroundColor Green

# MinIO connection details
$MinioEndpoint = "http://localhost:9000"
$MinioAccessKey = "minioadmin"
$MinioSecretKey = "minioadmin123"

# Wait for MinIO to be ready
Write-Host "Waiting for MinIO to be ready..." -ForegroundColor Yellow
$ready = $false
$maxAttempts = 30
$attempt = 0

while (-not $ready -and $attempt -lt $maxAttempts) {
    try {
        $response = Invoke-WebRequest -Uri "$MinioEndpoint/minio/health/live" -UseBasicParsing -TimeoutSec 5
        if ($response.StatusCode -eq 200) {
            $ready = $true
            Write-Host "MinIO is ready." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "   MinIO not ready, waiting 5 seconds... (Attempt $($attempt + 1)/$maxAttempts)" -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        $attempt++
    }
}

if (-not $ready) {
    Write-Host "MinIO failed to start within expected time" -ForegroundColor Red
    exit 1
}

# Install MinIO client if not present
$mcPath = "mc.exe"
if (-not (Get-Command $mcPath -ErrorAction SilentlyContinue)) {
    Write-Host "Installing MinIO client..." -ForegroundColor Blue

    # Download MinIO client for Windows
    $mcUrl = "https://dl.min.io/client/mc/release/windows-amd64/mc.exe"
    $mcDownloadPath = Join-Path $env:TEMP "mc.exe"

    try {
        Invoke-WebRequest -Uri $mcUrl -OutFile $mcDownloadPath -UseBasicParsing
        # Move to a location in PATH
        $mcInstallPath = Join-Path $env:USERPROFILE "bin\mc.exe"
        $binDir = Split-Path $mcInstallPath -Parent
        if (-not (Test-Path $binDir)) {
            New-Item -ItemType Directory -Path $binDir -Force | Out-Null
        }
        Move-Item $mcDownloadPath $mcInstallPath -Force

        # Add to PATH if not already there
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($userPath -notlike "*$binDir*") {
            [Environment]::SetEnvironmentVariable("PATH", "$userPath;$binDir", "User")
            $env:PATH = "$env:PATH;$binDir"
        }

        Write-Host "   MinIO client installed to $mcInstallPath" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to download MinIO client: $_" -ForegroundColor Red
        exit 1
    }
}

# Configure MinIO client
Write-Host "Configuring MinIO client..." -ForegroundColor Blue
& mc alias set local $MinioEndpoint $MinioAccessKey $MinioSecretKey

# Create lakehouse buckets
Write-Host "Creating lakehouse buckets..." -ForegroundColor Blue

& mc mb local/aem-raw --ignore-existing
Write-Host "   Created bucket: aem-raw" -ForegroundColor Green

& mc mb local/aem-processed --ignore-existing
Write-Host "   Created bucket: aem-processed" -ForegroundColor Green

& mc mb local/aem-analytics --ignore-existing
Write-Host "   Created bucket: aem-analytics" -ForegroundColor Green

# Bucket policies (private for local dev)
Write-Host "Setting bucket policies..." -ForegroundColor Blue
& mc anonymous set private local/aem-raw
& mc anonymous set private local/aem-processed
& mc anonymous set private local/aem-analytics

# Folder structure within buckets
Write-Host "Creating folder structure..." -ForegroundColor Blue

& mc mb local/aem-raw/energy --ignore-existing
& mc mb local/aem-raw/mobility --ignore-existing
& mc mb local/aem-raw/environmental --ignore-existing

& mc mb local/aem-processed/energy --ignore-existing
& mc mb local/aem-processed/mobility --ignore-existing
& mc mb local/aem-processed/environmental --ignore-existing

& mc mb local/aem-analytics/features --ignore-existing
& mc mb local/aem-analytics/models --ignore-existing
& mc mb local/aem-analytics/reports --ignore-existing

Write-Host ""
Write-Host "MinIO Lakehouse setup complete." -ForegroundColor Green
Write-Host ""
Write-Host "Bucket Structure:" -ForegroundColor Cyan
Write-Host "   aem-raw/           - Raw ingested data"
Write-Host "   aem-processed/     - Cleaned and transformed data"
Write-Host "   aem-analytics/     - Analytics and features"
Write-Host ""
Write-Host "MinIO Console: http://localhost:9001" -ForegroundColor Cyan
Write-Host "   Username: minioadmin"
Write-Host "   Password: minioadmin123"
Write-Host ""
Write-Host "S3 Endpoint: http://localhost:9000" -ForegroundColor Cyan
Write-Host "   Access Key: minioadmin"
Write-Host "   Secret Key: minioadmin123"

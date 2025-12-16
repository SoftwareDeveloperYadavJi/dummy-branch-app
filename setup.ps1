# Setup script for Windows - Generates SSL certificates and provides setup instructions

Write-Host "=== Branch Loans API Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check if SSL certificates exist
$certDir = "nginx\ssl"
$certFile = Join-Path $certDir "branchloans.com.crt"
$keyFile = Join-Path $certDir "branchloans.com.key"

if (-not (Test-Path $certFile) -or -not (Test-Path $keyFile)) {
    Write-Host "SSL certificates not found. Generating..." -ForegroundColor Yellow
    & ".\scripts\generate-ssl-certs.ps1"
    Write-Host ""
} else {
    Write-Host "[OK] SSL certificates found" -ForegroundColor Green
}

Write-Host "=== Setup Instructions ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Add to hosts file (run as Administrator):" -ForegroundColor Yellow
Write-Host "   C:\Windows\System32\drivers\etc\hosts" -ForegroundColor White
Write-Host "   Add line: 127.0.0.1    branchloans.com www.branchloans.com" -ForegroundColor White
Write-Host ""
Write-Host "2. Start services:" -ForegroundColor Yellow
Write-Host "   docker compose up -d --build" -ForegroundColor White
Write-Host ""
Write-Host "3. Run migrations:" -ForegroundColor Yellow
Write-Host "   docker compose exec api alembic upgrade head" -ForegroundColor White
Write-Host ""
Write-Host "4. Seed database:" -ForegroundColor Yellow
Write-Host "   docker compose exec api python scripts/seed.py" -ForegroundColor White
Write-Host ""
Write-Host "5. Access the API:" -ForegroundColor Yellow
Write-Host "   https://branchloans.com" -ForegroundColor White
Write-Host ""
Write-Host "Note: You'll need to accept the self-signed certificate in your browser." -ForegroundColor Gray


# PowerShell script to generate SSL certificates for branchloans.com
# This script creates a self-signed certificate for local development

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$CertDir = Join-Path $ProjectRoot "nginx\ssl"
$Domain = "branchloans.com"

# Create directory if it doesn't exist
if (-not (Test-Path $CertDir)) {
    New-Item -ItemType Directory -Path $CertDir -Force | Out-Null
}

Write-Host "Generating SSL certificate for $Domain..."

# Check if OpenSSL is available
$opensslPath = Get-Command openssl -ErrorAction SilentlyContinue

if ($opensslPath) {
    $certPath = Join-Path $CertDir "$Domain.crt"
    $keyPath = Join-Path $CertDir "$Domain.key"
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
        -keyout $keyPath `
        -out $certPath `
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$Domain" `
        -addext "subjectAltName=DNS:$Domain,DNS:www.$Domain,DNS:localhost,IP:127.0.0.1"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] SSL certificate generated successfully!" -ForegroundColor Green
        Write-Host "  Certificate: $certPath"
        Write-Host "  Private Key: $keyPath"
        Write-Host ""
        Write-Host "Note: You'll need to trust this certificate in your browser."
        Write-Host "On Chrome/Edge: Click 'Advanced' -> 'Proceed to branchloans.com (unsafe)'"
        Write-Host "On Firefox: Click 'Advanced' -> 'Accept the Risk and Continue'"
    } else {
        Write-Host "[ERROR] Failed to generate SSL certificate." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "OpenSSL not found. Using Docker to generate certificates..." -ForegroundColor Yellow
    
    # Use Docker to generate certificates
    $dockerCmd = "docker run --rm -v `"${CertDir}:/ssl`" alpine/openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /ssl/$Domain.key -out /ssl/$Domain.crt -subj `/CN=$Domain` -addext `"subjectAltName=DNS:$Domain,DNS:www.$Domain,DNS:localhost,IP:127.0.0.1`""
    
    Invoke-Expression $dockerCmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] SSL certificate generated successfully using Docker!" -ForegroundColor Green
        Write-Host "  Certificate: $(Join-Path $CertDir "$Domain.crt")"
        Write-Host "  Private Key: $(Join-Path $CertDir "$Domain.key")"
    } else {
        Write-Host "[ERROR] Failed to generate SSL certificate. Please install OpenSSL or ensure Docker is running." -ForegroundColor Red
        exit 1
    }
}


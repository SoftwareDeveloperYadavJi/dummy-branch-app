# Quick Start Guide

Get the Loan API running with HTTPS in 5 minutes!

## Step 1: Generate SSL Certificates

**Windows (PowerShell):**
```powershell
.\scripts\generate-ssl-certs.ps1
```

**Linux/macOS:**
```bash
chmod +x scripts/generate-ssl-certs.sh
./scripts/generate-ssl-certs.sh
```

## Step 2: Configure Local Domain

Add to your hosts file:
- **Windows:** `C:\Windows\System32\drivers\etc\hosts`
- **macOS/Linux:** `/etc/hosts`

Add this line:
```
127.0.0.1    branchloans.com www.branchloans.com
```

See `scripts/setup-hosts.md` for detailed instructions.

## Step 3: Start Services

```bash
docker compose up -d --build
```

## Step 4: Initialize Database

```bash
# Run migrations
docker compose exec api alembic upgrade head

# Seed with sample data
docker compose exec api python scripts/seed.py
```

## Step 5: Access the API

Open your browser and go to: **https://branchloans.com**

⚠️ **Note:** Your browser will show a security warning because we're using a self-signed certificate. Click "Advanced" → "Proceed to branchloans.com" (or "Accept the Risk and Continue" in Firefox).

## Test It Out

```bash
# Health check
curl -k https://branchloans.com/health

# List loans
curl -k https://branchloans.com/api/loans
```

The `-k` flag tells curl to ignore certificate validation (required for self-signed certs).

## Troubleshooting

**Certificate errors?**
- Make sure you generated SSL certificates (Step 1)
- Accept the certificate warning in your browser

**Domain not resolving?**
- Check your hosts file entry
- Try accessing via `https://127.0.0.1` instead

**Services won't start?**
- Check if ports 80, 443, or 5432 are in use
- View logs: `docker compose logs -f`


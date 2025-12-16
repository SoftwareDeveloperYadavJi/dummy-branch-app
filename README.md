# Flask Microloans API + Postgres (Docker)

Production-ready REST API for microloans, built with Flask, SQLAlchemy, Alembic, and PostgreSQL. Containerized with Docker Compose, served over HTTPS via Nginx reverse proxy.

## Features

- ✅ Containerized application with Docker
- ✅ HTTPS support with self-signed SSL certificates
- ✅ Nginx reverse proxy for SSL termination
- ✅ PostgreSQL database in container
- ✅ Virtual environment support
- ✅ Production-ready setup
- ✅ Multi-environment support (Development, Staging, Production)
- ✅ Environment-specific configurations with override files
- ✅ Structured JSON logging for production
- ✅ Hot reload for development

## Prerequisites

- Docker and Docker Compose installed
- OpenSSL (for certificate generation, or use Docker)
- Admin access to edit hosts file (for local domain setup)

## Quick Start

### 1. Set up local domain (branchloans.com)

Add `branchloans.com` to your hosts file to access the site locally:

**Windows:**
1. Open Notepad as Administrator
2. Open: `C:\Windows\System32\drivers\etc\hosts`
3. Add: `127.0.0.1    branchloans.com www.branchloans.com`
4. Save the file

**macOS/Linux:**
```bash
sudo nano /etc/hosts
# Add: 127.0.0.1    branchloans.com www.branchloans.com
```

See `scripts/setup-hosts.md` for detailed instructions.

### 2. Generate SSL Certificates

Generate self-signed SSL certificates for HTTPS:

**Linux/macOS:**
```bash
chmod +x scripts/generate-ssl-certs.sh
./scripts/generate-ssl-certs.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\generate-ssl-certs.ps1
```

**Or using Docker (if OpenSSL not installed):**
```bash
docker run --rm -v "${PWD}/nginx/ssl:/ssl" alpine/openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /ssl/branchloans.com.key -out /ssl/branchloans.com.crt -subj "/CN=branchloans.com" -addext "subjectAltName=DNS:branchloans.com,DNS:www.branchloans.com,DNS:localhost,IP:127.0.0.1"
```

### 3. Build and Start Services

**Development (default):**
```bash
# Using helper script (recommended)
.\scripts\run-dev.ps1 up -d --build  # Windows
./scripts/run-dev.sh up -d --build   # Linux/macOS

# Or manually
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
```

**Staging:**
```bash
.\scripts\run-staging.ps1 up -d --build  # Windows
./scripts/run-staging.sh up -d --build   # Linux/macOS
```

**Production:**
```bash
.\scripts\run-prod.ps1 up -d --build  # Windows
./scripts/run-prod.sh up -d --build   # Linux/macOS
```

**After starting services:**
```bash
# Run database migrations
docker compose exec api alembic upgrade head

# Seed dummy data (development/staging only)
docker compose exec api python scripts/seed.py
```

### 4. Access the API

The API is now available at:
- **HTTPS:** https://branchloans.com
- **HTTP:** http://branchloans.com (redirects to HTTPS)

**Note:** Your browser will show a security warning for the self-signed certificate. Click "Advanced" → "Proceed to branchloans.com" (or "Accept the Risk and Continue" in Firefox).

### 5. Test Endpoints

```bash
# Health check
curl -k https://branchloans.com/health

# List all loans
curl -k https://branchloans.com/api/loans

# Get specific loan
curl -k https://branchloans.com/api/loans/00000000-0000-0000-0000-000000000001

# Create new loan
curl -k -X POST https://branchloans.com/api/loans \
  -H 'Content-Type: application/json' \
  -d '{
    "borrower_id": "usr_india_999",
    "amount": 12000.50,
    "currency": "INR",
    "term_months": 6,
    "interest_rate_apr": 24.0
  }'

# Get statistics
curl -k https://branchloans.com/api/stats
```

## Architecture

```
┌─────────────┐
│   Browser   │
│ (HTTPS:443) │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│    Nginx    │  ← SSL Termination, Reverse Proxy
│  (Port 443) │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Flask API   │  ← Application Container
│  (Port 8000)│  ← Uses Virtual Environment
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ PostgreSQL  │  ← Database Container
│  (Port 5432)│
└─────────────┘
```

## Multi-Environment Setup

The application supports three environments: **Development**, **Staging**, and **Production**. Each environment has its own configuration optimized for its use case.

### Environment Configurations

#### Development Environment
- **Database**: Small PostgreSQL instance, no resource limits
- **API**: Debug logging, hot reload enabled, single worker for easier debugging
- **Ports**: Standard ports (80, 443, 5432, 8000)
- **Features**: Code changes trigger automatic reload

#### Staging Environment
- **Database**: Medium PostgreSQL (2 CPU, 2GB RAM limits)
- **API**: INFO level logging, 2 workers, resource limits applied
- **Ports**: Alternative ports (8080, 8443, 5433) to avoid conflicts
- **Features**: Mimics production setup closely

#### Production Environment
- **Database**: Large PostgreSQL (4 CPU, 4GB RAM limits), proper health checks
- **API**: WARNING level logging, structured JSON logs, 4 workers, optimized settings
- **Ports**: Standard ports (80, 443, 5432)
- **Features**: Production-grade resource limits, data persistence

### Switching Between Environments

**Quick Start Scripts:**
```bash
# Development (default)
.\scripts\run-dev.ps1 up -d        # Windows
./scripts/run-dev.sh up -d         # Linux/macOS

# Staging
.\scripts\run-staging.ps1 up -d    # Windows
./scripts/run-staging.sh up -d     # Linux/macOS

# Production
.\scripts\run-prod.ps1 up -d       # Windows
./scripts/run-prod.sh up -d        # Linux/macOS
```

**Manual Method:**
```bash
# Development
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Staging
docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Environment Configuration Files

Each environment uses its own `.env` file:

1. **Copy example files:**
   ```bash
   cp .env.dev.example .env.dev
   cp .env.staging.example .env.staging
   cp .env.prod.example .env.prod
   ```

2. **Edit environment-specific values:**
   - Development (`.env.dev`): Default values suitable for local development
   - Staging (`.env.staging`): Should use staging-specific passwords and ports
   - Production (`.env.prod`): **MUST** use strong, unique passwords and proper secrets

3. **Helper script to switch environments:**
   ```bash
   .\scripts\set-env.ps1 dev      # Windows
   ./scripts/set-env.sh dev       # Linux/macOS
   ```

### Configuration Differences

| Setting | Development | Staging | Production |
|---------|------------|---------|------------|
| **Database Memory** | No limit | 2GB limit | 4GB limit |
| **Database CPU** | No limit | 2 CPUs | 4 CPUs |
| **API Workers** | 1 | 2 | 4 |
| **Log Level** | DEBUG | INFO | WARNING |
| **Log Format** | Text | Text | JSON |
| **Hot Reload** | ✅ Yes | ❌ No | ❌ No |
| **Resource Limits** | ❌ No | ✅ Yes | ✅ Yes |
| **Restart Policy** | `no` | `unless-stopped` | `always` |
| **Database Port** | 5432 | 5433 | 5432 |
| **Nginx Ports** | 80, 443 | 8080, 8443 | 80, 443 |

### Hot Reload in Development

Development environment supports hot reload when you create a `.dev-reload` file:
```bash
touch .dev-reload
docker compose -f docker-compose.yml -f docker-compose.dev.yml restart api
```

The API will automatically reload when Python files change (using watchdog).

### Structured JSON Logging

Production environment uses structured JSON logging for better log aggregation and monitoring. Logs are formatted as JSON with fields:
- `timestamp`
- `level`
- `logger`
- `message`
- `module`, `function`, `line`
- Exception details (if any)

## Configuration

### Environment Variables

Configuration is managed through environment-specific `.env` files:

**Common Variables:**
- `FLASK_ENV`: Environment mode (development/staging/production)
- `LOG_LEVEL`: Logging level (DEBUG/INFO/WARNING/ERROR)
- `LOG_FORMAT`: Log format (text/json)
- `DATABASE_URL`: PostgreSQL connection string
- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`: Database credentials
- `GUNICORN_WORKERS`: Number of Gunicorn worker processes
- `RESTART_POLICY`: Container restart policy

See `.env.*.example` files for complete configuration options.

### Services

- **nginx**: Reverse proxy on ports 80 (HTTP) and 443 (HTTPS)
- **api**: Flask application (internal port 8000)
- **db**: PostgreSQL database (internal port 5432, exposed port varies by environment)

## API Endpoints

- `GET /health` → `{ "status": "ok" }`
- `GET /api/loans` → List all loans
- `GET /api/loans/:id` → Get loan by ID
- `POST /api/loans` → Create new loan (status defaults to `pending`)
- `GET /api/stats` → Aggregate statistics (totals, averages, grouped by status/currency)

### Example: Create Loan

```bash
curl -k -X POST https://branchloans.com/api/loans \
  -H 'Content-Type: application/json' \
  -d '{
    "borrower_id": "usr_india_999",
    "amount": 12000.50,
    "currency": "INR",
    "term_months": 6,
    "interest_rate_apr": 24.0
  }'
```

## Development

### Project Structure

```
.
├── app/                    # Flask application
│   ├── __init__.py        # App factory
│   ├── config.py          # Configuration
│   ├── db.py              # Database setup
│   ├── models.py          # SQLAlchemy models
│   ├── schemas.py         # Pydantic schemas
│   └── routes/            # API routes
├── alembic/               # Database migrations
├── nginx/                 # Nginx configuration
│   ├── nginx.conf         # Nginx config
│   └── ssl/               # SSL certificates (generated)
├── scripts/               # Utility scripts
│   ├── seed.py            # Database seeding
│   └── generate-ssl-certs.*  # SSL certificate generation
├── Dockerfile             # Application container
├── docker-compose.yml     # Multi-container setup
└── wsgi.py                # WSGI entry point
```

### Running Migrations

```bash
docker compose exec api alembic upgrade head
```

### Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f nginx
docker compose logs -f db
```

### Stopping Services

```bash
docker compose down
```

To remove volumes (clears database):
```bash
docker compose down -v
```

## Security Notes

- This setup uses **self-signed certificates** for local development only
- For production, use certificates from a trusted CA (Let's Encrypt, etc.)
- The application currently has no authentication (prototype)
- Amounts are validated server-side (0 < amount ≤ 50000)

## Troubleshooting

### Certificate Errors

If you see certificate errors in your browser:
1. Make sure you generated the SSL certificates
2. Accept the self-signed certificate in your browser
3. Clear browser cache if needed

### Domain Not Resolving

If `branchloans.com` doesn't resolve:
1. Verify hosts file entry: `127.0.0.1 branchloans.com`
2. Try accessing via `https://127.0.0.1` or `https://localhost`
3. Clear DNS cache:
   - Windows: `ipconfig /flushdns`
   - macOS/Linux: `sudo killall -HUP mDNSResponder` (or restart network service)

### Port Conflicts

If ports 80, 443, or 5432 are already in use:
1. Stop conflicting services
2. Or modify ports in `docker-compose.yml`

### Database Connection Issues

If the API can't connect to the database:
1. Ensure PostgreSQL container is healthy: `docker compose ps`
2. Check database logs: `docker compose logs db`
3. Verify DATABASE_URL environment variable
# Multi-Environment Setup Guide

This guide explains how to use the multi-environment Docker Compose setup for Development, Staging, and Production.

## Overview

The application uses Docker Compose override files to support different configurations for each environment:

- `docker-compose.yml` - Base configuration with common settings
- `docker-compose.dev.yml` - Development environment overrides
- `docker-compose.staging.yml` - Staging environment overrides
- `docker-compose.prod.yml` - Production environment overrides

## Quick Reference

### Development
```bash
# Start
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build

# Or use helper script
./scripts/run-dev.sh up -d --build  # Linux/macOS
.\scripts\run-dev.ps1 up -d --build  # Windows
```

### Staging
```bash
# Start
docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d --build

# Or use helper script
./scripts/run-staging.sh up -d --build  # Linux/macOS
.\scripts\run-staging.ps1 up -d --build  # Windows
```

### Production
```bash
# Start
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# Or use helper script
./scripts/run-prod.sh up -d --build  # Linux/macOS
.\scripts\run-prod.ps1 up -d --build  # Windows
```

## Environment Configuration

### Step 1: Create Environment Files

Copy the example files and customize:

```bash
cp env.dev.example .env.dev
cp env.staging.example .env.staging
cp env.prod.example .env.prod
```

### Step 2: Customize Settings

Edit each `.env.*` file with environment-specific values:

**Development (`.env.dev`):**
- Use default/weak passwords (safe for local development)
- Enable debug logging
- Use standard ports

**Staging (`.env.staging`):**
- Use staging-specific passwords
- Use alternative ports to avoid conflicts
- Enable INFO level logging

**Production (`.env.prod`):**
- **MUST use strong, unique passwords**
- Use standard ports
- Use WARNING level logging
- Set `RESTART_POLICY=always`

### Step 3: Start Services

Use the appropriate command for your target environment (see Quick Reference above).

## Environment Differences

### Database Configuration

| Aspect | Development | Staging | Production |
|--------|------------|---------|------------|
| Shared Memory | 64MB | 256MB | 1GB |
| CPU Limit | None | 2 CPUs | 4 CPUs |
| Memory Limit | None | 2GB | 4GB |
| Memory Reservation | None | 512MB | 2GB |
| Health Check Interval | 5s | 10s | 10s |
| Health Check Start Period | None | None | 30s |

### API Configuration

| Aspect | Development | Staging | Production |
|--------|------------|---------|------------|
| Workers | 1 | 2 | 4 |
| Timeout | 120s | 30s | 30s |
| Log Level | DEBUG | INFO | WARNING |
| Log Format | Text | Text | JSON |
| Access Logs | Enabled | Enabled | Disabled |
| Hot Reload | Yes (with .dev-reload) | No | No |
| CPU Limit | None | 2 CPUs | 4 CPUs |
| Memory Limit | None | 1GB | 2GB |
| Memory Reservation | None | 256MB | 1GB |

### Volume Mounts

- **Development**: Code is mounted as volume for hot reload
- **Staging**: No code mounts (uses image)
- **Production**: No code mounts (uses image)

## Hot Reload (Development Only)

To enable hot reload in development:

1. Create a `.dev-reload` file:
   ```bash
   touch .dev-reload
   ```

2. Restart the API container:
   ```bash
   docker compose -f docker-compose.yml -f docker-compose.dev.yml restart api
   ```

The API will now automatically reload when Python files change. This uses the `watchdog` library which is automatically installed when `.dev-reload` is present.

## Logging

### Development
- Log level: DEBUG
- Format: Text (human-readable)
- Output: Console (stdout/stderr)
- All logs visible, including SQL queries and detailed request information

### Staging
- Log level: INFO
- Format: Text (human-readable)
- Output: Console
- Moderate verbosity, suitable for troubleshooting

### Production
- Log level: WARNING
- Format: JSON (structured)
- Output: Console
- Minimal noise, structured format for log aggregation tools

Example production JSON log:
```json
{
  "timestamp": "2025-12-16 15:00:00,000",
  "level": "WARNING",
  "logger": "app.routes.loans",
  "message": "Invalid loan amount requested",
  "module": "loans",
  "function": "create_loan",
  "line": 45
}
```

## Resource Management

### Development
- No resource limits (uses host resources)
- Suitable for local development on developer machines

### Staging
- Moderate resource limits
- Tests production-like constraints
- Helps identify resource-related issues before production

### Production
- Strict resource limits
- Prevents resource exhaustion
- Ensures predictable performance

## Data Persistence

All environments use Docker volumes for database persistence:

- **Development**: `dummy-branch-app_db_data_dev`
- **Staging**: `dummy-branch-app_db_data_staging`
- **Production**: `dummy-branch-app_db_data_prod`

Data persists across container restarts. To reset:
```bash
docker compose -f docker-compose.yml -f docker-compose.<env>.yml down -v
```

## Troubleshooting

### Port Conflicts

If ports are already in use:

1. Check what's using the port:
   ```bash
   # Windows
   netstat -ano | findstr :80
   
   # Linux/macOS
   lsof -i :80
   ```

2. Change ports in the appropriate `.env.*` file:
   ```
   NGINX_HTTP_PORT=8080
   NGINX_HTTPS_PORT=8443
   ```

### Environment Not Loading

If environment variables aren't being used:

1. Verify the `.env.*` file exists
2. Check that you're using the correct compose files:
   ```bash
   docker compose -f docker-compose.yml -f docker-compose.<env>.yml config
   ```

3. Verify variables are being passed:
   ```bash
   docker compose -f docker-compose.yml -f docker-compose.<env>.yml exec api env | grep FLASK_ENV
   ```

### Hot Reload Not Working

1. Ensure `.dev-reload` file exists
2. Check that you're using the development compose file
3. Verify volume mounts:
   ```bash
   docker compose -f docker-compose.yml -f docker-compose.dev.yml config | grep volumes
   ```

## Best Practices

1. **Never commit `.env.*` files** - They may contain secrets
2. **Use strong passwords in production** - Default passwords are for development only
3. **Test staging configuration** - Staging should mirror production as closely as possible
4. **Monitor resource usage** - Use `docker stats` to monitor container resources
5. **Backup production data** - Regularly backup the production database volume
6. **Use secrets management** - In production, consider using Docker secrets or external secret managers


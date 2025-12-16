#!/bin/bash

# Setup script for Linux/macOS - Generates SSL certificates and provides setup instructions

echo "=== Branch Loans API Setup ==="
echo ""

# Check if SSL certificates exist
CERT_DIR="nginx/ssl"
CERT_FILE="$CERT_DIR/branchloans.com.crt"
KEY_FILE="$CERT_DIR/branchloans.com.key"

if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo "SSL certificates not found. Generating..."
    chmod +x scripts/generate-ssl-certs.sh
    ./scripts/generate-ssl-certs.sh
    echo ""
else
    echo "✓ SSL certificates found"
fi

echo "=== Setup Instructions ==="
echo ""
echo "1. Add to hosts file (requires sudo):"
echo "   sudo nano /etc/hosts"
echo "   Add line: 127.0.0.1    branchloans.com www.branchloans.com"
echo ""
echo "2. Start services:"
echo "   docker compose up -d --build"
echo ""
echo "3. Run migrations:"
echo "   docker compose exec api alembic upgrade head"
echo ""
echo "4. Seed database:"
echo "   docker compose exec api python scripts/seed.py"
echo ""
echo "5. Access the API:"
echo "   https://branchloans.com"
echo ""
echo "Note: You'll need to accept the self-signed certificate in your browser."


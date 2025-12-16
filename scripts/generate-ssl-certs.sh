#!/bin/bash

# Generate SSL certificates for branchloans.com
# This script creates a self-signed certificate for local development

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CERT_DIR="$PROJECT_ROOT/nginx/ssl"
DOMAIN="branchloans.com"

mkdir -p "$CERT_DIR"

echo "Generating SSL certificate for $DOMAIN..."

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERT_DIR/$DOMAIN.key" \
  -out "$CERT_DIR/$DOMAIN.crt" \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN" \
  -addext "subjectAltName=DNS:$DOMAIN,DNS:www.$DOMAIN,DNS:localhost,IP:127.0.0.1"

if [ $? -eq 0 ]; then
    echo "✓ SSL certificate generated successfully!"
    echo "  Certificate: $CERT_DIR/$DOMAIN.crt"
    echo "  Private Key: $CERT_DIR/$DOMAIN.key"
    echo ""
    echo "Note: You'll need to trust this certificate in your browser."
    echo "On Chrome/Edge: Click 'Advanced' → 'Proceed to branchloans.com (unsafe)'"
    echo "On Firefox: Click 'Advanced' → 'Accept the Risk and Continue'"
else
    echo "✗ Failed to generate SSL certificate. Make sure OpenSSL is installed."
    exit 1
fi


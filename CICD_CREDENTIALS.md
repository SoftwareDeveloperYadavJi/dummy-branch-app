# CI/CD Pipeline - Required Credentials

This document outlines the credentials and secrets required for the CI/CD pipeline to work properly.

## Overview

The CI/CD pipeline uses **GitHub Container Registry (ghcr.io)** by default, which is free and integrated with GitHub. No additional setup is required for basic usage.

## Option 1: GitHub Container Registry (ghcr.io) - Recommended ✅

**Status:** ✅ **Already configured** - No additional credentials needed!

The pipeline uses GitHub's built-in `GITHUB_TOKEN` which is automatically provided by GitHub Actions. This token:
- Has read/write permissions to the repository's container registry
- Is automatically available in all GitHub Actions workflows
- Requires no manual setup

### How it works:
- The workflow automatically authenticates using `${{ secrets.GITHUB_TOKEN }}`
- Images are pushed to: `ghcr.io/<your-username>/<repository-name>`
- Images are private by default for personal repositories
- Images are public by default for public repositories

### Making images public (optional):
If you want to make your container images publicly accessible:

1. Go to your GitHub repository
2. Click on "Packages" (in the right sidebar)
3. Click on your container package
4. Click "Package settings"
5. Scroll down to "Danger Zone" → "Change visibility" → Select "Public"

### Pulling images:
```bash
# For public images
docker pull ghcr.io/<username>/<repository-name>:latest

# For private images, authenticate first
echo $GITHUB_TOKEN | docker login ghcr.io -u <username> --password-stdin
docker pull ghcr.io/<username>/<repository-name>:latest
```

---

## Option 2: Docker Hub (Alternative)

If you prefer to use Docker Hub instead of GitHub Container Registry, you'll need to configure Docker Hub credentials.

### Required Secrets in GitHub:

1. **Go to your GitHub repository**
2. **Navigate to:** Settings → Secrets and variables → Actions
3. **Click "New repository secret"**
4. **Add the following secrets:**

| Secret Name | Description | Example Value |
|------------|-------------|---------------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username | `your-dockerhub-username` |
| `DOCKERHUB_TOKEN` | Your Docker Hub access token (not password!) | `dckr_pat_xxxxxxxxxxxxx` |

### How to get Docker Hub Token:

1. Go to [Docker Hub](https://hub.docker.com/)
2. Sign in to your account
3. Click on your profile → **Account Settings**
4. Navigate to **Security** → **New Access Token**
5. Give it a name (e.g., "GitHub Actions")
6. Copy the token (you won't see it again!)
7. Add it to GitHub Secrets as `DOCKERHUB_TOKEN`

### Modifying the workflow for Docker Hub:

If you want to use Docker Hub instead, you'll need to modify `.github/workflows/ci-cd.yml`:

Change the `env` section:
```yaml
env:
  REGISTRY: docker.io
  IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/<your-image-name>
```

Change the login step:
```yaml
- name: Log in to Docker Hub
  if: github.event_name != 'pull_request'
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKERHUB_USERNAME }}
    password: ${{ secrets.DOCKERHUB_TOKEN }}
```

---

## Security Best Practices

### ✅ What the pipeline does correctly:

1. **No secrets in code:** All sensitive information is stored as GitHub Secrets
2. **No secrets in logs:** The workflow uses `${{ secrets.* }}` syntax which masks values in logs
3. **Conditional push:** Images are only pushed on pushes to `main`, not on pull requests
4. **Security scanning:** Trivy scans all images for critical vulnerabilities before push

### 🔒 Secrets that should NEVER be committed:

- ❌ Database passwords
- ❌ API keys
- ❌ Private tokens
- ❌ SSH keys
- ❌ Any credentials or sensitive configuration

### 📝 Environment Variables in Workflows:

If you need to use secrets as environment variables in the workflow:

```yaml
- name: Run tests
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
    API_KEY: ${{ secrets.API_KEY }}
  run: |
    # Your commands here
```

### 🛡️ Protecting Secrets:

1. **Never log secrets:** Never use `echo $SECRET` or similar commands
2. **Use GitHub Secrets:** Always use `${{ secrets.SECRET_NAME }}` syntax
3. **Limit access:** Only grant necessary permissions to workflows
4. **Rotate regularly:** Update secrets/tokens periodically

---

## Pipeline Stages & Credentials

### Stage 1: Test
- **No credentials required**
- Runs pytest on every push and pull request

### Stage 2: Build
- **Uses:** `GITHUB_TOKEN` (automatic for ghcr.io) or Docker Hub credentials
- Builds Docker image with appropriate tags

### Stage 3: Security Scan
- **No credentials required**
- Uses Trivy to scan for vulnerabilities
- Fails if critical vulnerabilities found

### Stage 4: Push
- **Uses:** Same credentials as Build stage
- Only pushes on successful pushes to `main` branch
- Never pushes on pull requests

---

## Summary

### For GitHub Container Registry (Current Setup):
- ✅ **No action required** - Everything is already configured!
- The `GITHUB_TOKEN` is automatically provided by GitHub Actions
- Images will be available at `ghcr.io/<your-username>/<repository-name>`

### For Docker Hub (If switching):
- Add `DOCKERHUB_USERNAME` secret
- Add `DOCKERHUB_TOKEN` secret (access token, not password)
- Modify workflow file (see instructions above)

---

## Troubleshooting

### "Authentication failed" error:
- For ghcr.io: Ensure your repository has Actions enabled
- For Docker Hub: Verify your username and token are correct

### "Permission denied" error:
- Check that the secrets are correctly named in GitHub
- Verify the workflow has access to secrets (check repository settings)

### Images not appearing:
- For ghcr.io: Check the "Packages" section of your repository
- For Docker Hub: Check your Docker Hub repositories page
- Ensure the push step completed successfully

---

## Additional Resources

- [GitHub Container Registry Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Docker Hub Access Tokens](https://docs.docker.com/docker-hub/access-tokens/)
- [Trivy Security Scanner](https://github.com/aquasecurity/trivy)

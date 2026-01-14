# 🔄 GitHub Actions Workflows Documentation

This directory contains automated workflows for the MagicAI v9.9 project. This guide explains what each workflow does, when it runs, and how to use them.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Workflows](#workflows)
   - [pages.yml - GitHub Pages Deployment](#pagesyml---github-pages-deployment)
   - [deploy.yml - CI/CD Pipeline](#deployyml---cicd-pipeline)
3. [When Each Workflow Runs](#when-each-workflow-runs)
4. [How to Trigger Workflows](#how-to-trigger-workflows)
5. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This project uses two main workflows for different purposes:

| Workflow | Purpose | Triggers On | Output |
|----------|---------|-------------|---------|
| **pages.yml** | Deploy static site to GitHub Pages | Push to `main` | Live website at https://v3ai2026.github.io/333/ |
| **deploy.yml** | Build, test, and deploy full stack | Push to `develop`/`staging` | Docker containers for development |

---

## 📁 Workflows

### `pages.yml` - GitHub Pages Deployment

**Purpose**: Deploy a static informational website to GitHub Pages

**File**: `.github/workflows/pages.yml`

**What It Does**:
1. ✅ Checks out the repository code
2. ✅ Configures GitHub Pages settings
3. ✅ Builds a static site from the `public/` directory
4. ✅ Creates a fallback index.html if none exists
5. ✅ Uploads the site as an artifact
6. ✅ Deploys to GitHub Pages

**When It Runs**:
- Automatically on every push to the `main` branch
- Manually via the Actions tab (workflow_dispatch)

**Triggers**:
```yaml
on:
  push:
    branches:
      - main
  workflow_dispatch:
```

**Requirements**:
- ⚠️ GitHub Pages must be enabled in repository Settings
- ⚠️ Pages source must be set to "GitHub Actions"
- ⚠️ Workflow must have proper permissions

**Output**:
- 🌐 **Live Site**: https://v3ai2026.github.io/333/
- 📄 **Static Content**: HTML/CSS/JS files from `public/` directory

**Use Cases**:
- Hosting project documentation
- Displaying marketing/landing pages
- Sharing demos and examples
- Public project showcase

**Note**: This deploys ONLY static files. It does NOT include:
- ❌ PHP/Laravel backend functionality
- ❌ Database access
- ❌ Backend APIs
- ❌ Dynamic server-side processing

For full application deployment, use `deploy.yml` or Docker.

---

### `deploy.yml` - CI/CD Pipeline

**Purpose**: Continuous Integration and Deployment for development environments

**File**: `.github/workflows/deploy.yml`

**What It Does**:

#### **Stage 1: Code Quality Check**
- Validates Python code with flake8
- Checks requirements.txt dependencies
- Validates docker-compose.yml syntax
- Lints Dockerfiles with hadolint

#### **Stage 2: Build Docker Images**
- Builds Python backend service image
- Builds web application image (if Dockerfile exists)
- Uses caching to speed up builds
- Saves build logs as artifacts

#### **Stage 3: Deploy Services**
- Creates environment configuration files
- Stops existing containers
- Starts new containers with docker-compose
- Waits for database to be ready
- Runs Laravel migrations
- Clears application cache

#### **Stage 4: Verify Deployment**
- Checks container status
- Tests web application endpoints
- Tests Python backend health endpoint
- Tests database connectivity
- Tests Redis connectivity
- Displays service logs

#### **Stage 5: Notification**
- Provides deployment summary
- Shows service access URLs
- Lists useful commands
- Reports any failures

#### **Rollback (on Failure)**
- Automatically stops failed containers
- Logs indicate issues for investigation

**When It Runs**:
- Automatically on every push to `develop` branch
- Automatically on every push to `staging` branch
- Manually via the Actions tab (workflow_dispatch)

**Triggers**:
```yaml
on:
  push:
    branches:
      - develop
      - staging
  workflow_dispatch:
```

**Requirements**:
- ✅ Docker and Docker Compose available
- ✅ Valid `.env.example` file for configuration
- ✅ Dockerfile in `backend-service/` directory
- ✅ Valid docker-compose.yml

**Output**:
- 🐋 **Docker Containers**: Running services (web, database, Redis, backend)
- 📊 **Build Artifacts**: Logs and build information
- 🩺 **Health Checks**: Verification of all services

**Services Deployed**:
1. **Web Application** (Laravel): http://localhost:8000
2. **Python Backend API**: http://localhost:8080
3. **MySQL Database**: localhost:3306
4. **Redis Cache**: localhost:6379

**Use Cases**:
- Development environment testing
- Staging environment validation
- Automated CI/CD for teams
- Pre-production deployment checks

---

## 🚦 When Each Workflow Runs

### Visual Flow Diagram

```
┌──────────────────────────────────────────────────┐
│            Git Push or Manual Trigger            │
└──────────────────┬───────────────────────────────┘
                   │
         ┌─────────┴─────────┐
         │                   │
    ┌────▼────┐         ┌────▼────┐
    │  main   │         │ develop │
    │ branch  │         │ staging │
    └────┬────┘         └────┬────┘
         │                   │
    ┌────▼────────┐    ┌─────▼─────────┐
    │  pages.yml  │    │  deploy.yml   │
    │             │    │               │
    │  Deploys    │    │  Builds &     │
    │  to GitHub  │    │  Deploys      │
    │  Pages      │    │  Docker       │
    └────┬────────┘    └─────┬─────────┘
         │                   │
    ┌────▼─────────┐    ┌────▼──────────┐
    │ Static Site  │    │ Full Stack    │
    │ Public URLs  │    │ Local/CI Env  │
    └──────────────┘    └───────────────┘
```

### Decision Tree: Which Workflow Will Run?

```
Are you pushing to 'main' branch?
├─ YES → pages.yml runs
│         ↳ Deploys static site to GitHub Pages
│
└─ NO → Are you pushing to 'develop' or 'staging'?
        ├─ YES → deploy.yml runs
        │         ↳ Builds Docker images and deploys full stack
        │
        └─ NO → No workflows run
                  ↳ (Unless manually triggered)
```

---

## 🎮 How to Trigger Workflows

### Automatically (Recommended)

Workflows trigger automatically when you push to their configured branches:

#### Trigger `pages.yml`
```bash
# Make changes to your static site
git add public/index.html
git commit -m "Update homepage"
git push origin main
```

#### Trigger `deploy.yml`
```bash
# Make changes to your code
git add .
git commit -m "Add new feature"
git push origin develop  # or staging
```

### Manually via GitHub UI

1. **Navigate to Actions**
   - Go to https://github.com/v3ai2026/333/actions

2. **Select Workflow**
   - Click on "Deploy to GitHub Pages" or "MagicAI v9.9 CI/CD Pipeline"

3. **Run Workflow**
   - Click **Run workflow** button
   - Select branch (usually `main` for pages, `develop` for deploy)
   - Click **Run workflow**

### Manually via GitHub CLI

```bash
# Trigger pages.yml
gh workflow run pages.yml

# Trigger deploy.yml
gh workflow run deploy.yml

# Trigger with specific branch
gh workflow run pages.yml --ref main
gh workflow run deploy.yml --ref develop
```

### Manually via API

```bash
# Trigger pages.yml
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: token YOUR_TOKEN" \
  https://api.github.com/repos/v3ai2026/333/actions/workflows/pages.yml/dispatches \
  -d '{"ref":"main"}'
```

---

## 🔧 Troubleshooting

### Common Issues

#### Issue: Workflow Not Triggering

**Symptoms**: Pushed to branch but workflow doesn't run

**Solutions**:
- ✅ Verify you pushed to correct branch (`main` for pages, `develop`/`staging` for deploy)
- ✅ Check Actions tab → All workflows → Make sure workflows aren't disabled
- ✅ Verify workflow files are in `.github/workflows/` directory
- ✅ Check for YAML syntax errors in workflow files

#### Issue: `pages.yml` Fails with "Get Pages site failed"

**Symptoms**: Error message about Pages not being enabled

**Solutions**:
- ✅ Enable GitHub Pages: Settings → Pages
- ✅ Set source to "GitHub Actions" (NOT "Deploy from a branch")
- ✅ Wait 1-2 minutes and re-run workflow
- ✅ See [GitHub Pages Setup Guide](../docs/GITHUB_PAGES_SETUP.md)

#### Issue: `deploy.yml` Fails at Build Stage

**Symptoms**: Docker image build fails

**Solutions**:
- ✅ Check Dockerfile syntax in `backend-service/Dockerfile`
- ✅ Verify all dependencies in `requirements.txt` are valid
- ✅ Review build logs in the failed workflow run
- ✅ Test Docker build locally: `cd backend-service && docker build -t test .`

#### Issue: Permissions Error

**Symptoms**: "Resource not accessible by integration"

**Solutions**:
- ✅ Settings → Actions → General → Workflow permissions
- ✅ Select "Read and write permissions"
- ✅ Save and re-run workflow

#### Issue: Workflow Takes Too Long

**For `pages.yml`**:
- Usually completes in 1-2 minutes
- If longer, check GitHub status: https://www.githubstatus.com/

**For `deploy.yml`**:
- Usually completes in 5-10 minutes (with caching)
- First run may take longer (15-20 minutes)
- Uses Docker layer caching to speed up subsequent runs

---

## 📊 Workflow Status Badges

Add these badges to your README to show workflow status:

### Pages Workflow
```markdown
![GitHub Pages](https://github.com/v3ai2026/333/actions/workflows/pages.yml/badge.svg)
```

### Deploy Workflow
```markdown
![CI/CD](https://github.com/v3ai2026/333/actions/workflows/deploy.yml/badge.svg)
```

---

## 📖 Additional Resources

### Official Documentation
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Pages Actions](https://github.com/actions/deploy-pages)

### Project Documentation
- [GitHub Pages Setup Guide](../docs/GITHUB_PAGES_SETUP.md) - Enable and configure Pages
- [Deployment Guide](../docs/DEPLOYMENT_GUIDE.md) - All deployment options
- [Main README](../README.md) - Project overview

---

## 🔐 Security Notes

### Secrets Management

Both workflows use GitHub secrets for sensitive data:

- `GITHUB_TOKEN` - Automatically provided by GitHub
- API keys and credentials should be stored in repository Secrets

**To add secrets**:
1. Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add name and value
4. Click "Add secret"

### Best Practices

- ✅ Never commit secrets to code
- ✅ Use environment-specific secrets (dev, staging, prod)
- ✅ Regularly rotate API keys and tokens
- ✅ Use least-privilege access for workflow permissions

---

## 📞 Support

### Need Help?

1. **Check Workflow Logs**
   - Actions tab → Click workflow run → View detailed logs

2. **Review Documentation**
   - Read this README
   - Check [troubleshooting guides](../docs/GITHUB_PAGES_SETUP.md#troubleshooting)

3. **Create an Issue**
   - https://github.com/v3ai2026/333/issues
   - Include workflow run URL and error messages

4. **Community**
   - Check existing issues for similar problems
   - Search GitHub Discussions

---

## 📝 Summary

### Quick Reference

| Need | Use This | Branch | Result |
|------|----------|--------|---------|
| Update public site | `pages.yml` | `main` | Static site at github.io |
| Test full app | `deploy.yml` | `develop` | Docker containers locally |
| Stage for production | `deploy.yml` | `staging` | Staging environment |
| Deploy production | Manual/Different process | `main` | See deployment guides |

### Key Differences

| Feature | pages.yml | deploy.yml |
|---------|-----------|------------|
| **Purpose** | Static site hosting | Full stack deployment |
| **Branch** | `main` | `develop`, `staging` |
| **Runtime** | ~1-2 mins | ~5-10 mins |
| **Output** | Public website | Docker containers |
| **Backend** | ❌ No | ✅ Yes |
| **Database** | ❌ No | ✅ Yes |
| **Use Case** | Documentation, marketing | Development, testing |

---

**Last Updated**: 2026-01-14  
**Version**: MagicAI v9.9  
**Maintained by**: v3ai2026

# 🚀 GitHub Actions CI/CD Workflow Guide

## 📋 Overview

This repository includes a comprehensive GitHub Actions workflow that automatically checks, builds, tests, and deploys the MagicAI v9.9 application.

## 🔄 Workflow File

**Location**: `.github/workflows/deploy.yml`

## 🎯 What It Does

### Automated Checks
- ✅ Python code syntax validation (flake8)
- ✅ Docker configuration validation
- ✅ Environment variable setup

### Build & Deploy
- ✅ Builds Docker images (web + python-backend)
- ✅ Starts all services (MySQL, Redis, Web, Python Backend)
- ✅ Waits for services to be ready
- ✅ Runs database migrations
- ✅ Clears application caches
- ✅ Compiles frontend resources

### Testing & Verification
- ✅ Database connection tests
- ✅ Redis connection tests
- ✅ Web application health checks
- ✅ Python backend API tests
- ✅ Container status verification

## 🎬 Trigger Conditions

The workflow runs automatically on:

1. **Push to main/master branch**
   ```bash
   git push origin main
   ```

2. **Pull Request to main/master**
   ```bash
   # Automatically runs when PR is opened or updated
   ```

3. **Manual Trigger**
   - Go to Actions tab in GitHub
   - Select "🚀 自动检查和部署" workflow
   - Click "Run workflow"

## 📊 Workflow Steps

### 1. 📥 Code Checkout
Checks out the repository code using `actions/checkout@v4`.

### 2. 🐍 Python Syntax Check
- Sets up Python 3.11
- Installs flake8 and dependencies
- Runs syntax validation on all Python files
- Critical errors fail the build, warnings are reported

### 3. 🔨 Docker Validation
Validates `docker-compose.yml` configuration.

### 4. 📝 Environment Setup
- Creates `.env` from `.env.example`
- Sets testing environment variables
- Generates secure APP_KEY
- Creates backend-service `.env` if needed

### 5. 🏗️ Build Images
Builds Docker images for:
- Web application (Laravel)
- Python backend service

### 6. 🚀 Start Services
Starts all Docker containers:
- MySQL database
- Redis cache
- Web application
- Python backend

### 7. ⏳ Service Readiness
Waits for each service to be ready:
- Database: up to 60 seconds
- Redis: up to 30 seconds
- Web: up to 60 seconds
- Python Backend: up to 60 seconds

### 8. 🧪 Health Checks

**Database Tests:**
```bash
mysqladmin ping
mysql -e "SELECT 1"
```

**Redis Tests:**
```bash
redis-cli ping
redis-cli SET/GET
```

**Web Application:**
```bash
curl http://localhost:8000
```

**Python Backend:**
```bash
curl http://localhost:8080/health
curl http://localhost:8080/status
curl http://localhost:8080/api/status
```

### 9. 📊 Database Operations
- Generates Laravel application key
- Runs database migrations
- Clears configuration cache
- Clears route cache
- Clears view cache

### 10. 🎨 Frontend Build
- Checks for `package.json`
- Runs `npm install` if needed
- Runs `npm run build` for production assets

### 11. ✅ Deployment Verification
- Verifies all containers are running
- Checks endpoint accessibility
- Reports any issues

### 12. 📋 Deployment Summary
Displays comprehensive deployment information:
- Completion timestamp
- Container status
- Resource usage
- Accessible URLs
- Useful commands

### 13. 🧹 Cleanup
Stops services and cleans up resources.

## 📈 Viewing Results

### In GitHub UI

1. Go to your repository
2. Click on "Actions" tab
3. Select a workflow run
4. View detailed logs for each step

### Status Badge

Add this to your README.md to show workflow status:

```markdown
![Deploy Status](https://github.com/v3ai2026/333/actions/workflows/deploy.yml/badge.svg)
```

## 🔧 Configuration

### Environment Variables

The workflow uses test values by default:
- `MYSQL_ROOT_PASSWORD`: test_root_password
- `DB_PASSWORD`: test_password
- `APP_ENV`: testing
- `APP_DEBUG`: true

### Timeouts

Service wait times can be adjusted in the workflow:
- Database: 60 seconds (120 attempts × 2s)
- Redis: 30 seconds
- Web: 60 seconds (20 attempts × 3s)
- Backend: 60 seconds (20 attempts × 3s)

## 🐛 Troubleshooting

### Workflow Fails at Python Check
- Check Python syntax errors in logs
- Review flake8 output
- Fix syntax issues in Python files

### Docker Build Fails
- Check Dockerfile syntax
- Verify base images are available
- Review build context

### Services Not Ready
- Check Docker logs in workflow output
- Verify resource limits
- Increase timeout values if needed

### Health Check Failures
- Review service logs
- Check network configuration
- Verify endpoints are correct

## 🔐 Security

The workflow includes security best practices:
- ✅ Explicit GITHUB_TOKEN permissions (`contents: read`)
- ✅ No hardcoded secrets
- ✅ Test-only credentials (not production)
- ✅ CodeQL security scanning compatible

## 💡 Tips

### Local Testing

Before pushing, test locally:
```bash
# Run the deployment script
./deploy.sh

# Or use docker-compose directly
docker-compose up -d
```

### Debugging Failed Runs

1. Check the specific step that failed
2. Review the error message
3. Run the same commands locally
4. Check service logs: `docker-compose logs [service]`

### Optimizing Build Time

- Use Docker layer caching
- Consider splitting into multiple jobs
- Cache dependencies where possible

## 📚 Related Documentation

- [DEPLOYMENT.md](../DEPLOYMENT.md) - Full deployment guide
- [deploy.sh](../deploy.sh) - Local deployment script
- [docker-compose.yml](../docker-compose.yml) - Service configuration
- [.env.example](../.env.example) - Environment template

## 🆘 Support

If you encounter issues:
1. Check the workflow logs
2. Review this documentation
3. Check [GitHub Actions documentation](https://docs.github.com/en/actions)
4. Open an issue in the repository

## 📝 Maintenance

### Updating the Workflow

1. Edit `.github/workflows/deploy.yml`
2. Test changes locally if possible
3. Push to a feature branch first
4. Verify workflow runs successfully
5. Merge to main

### Version Updates

Update action versions regularly:
- `actions/checkout@v4` - Check for newer versions
- `actions/setup-python@v5` - Check for newer versions

---

**Last Updated**: 2026-01-10 | **Workflow Version**: 1.0

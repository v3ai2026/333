# 🚀 MagicAI v9.9 - Complete Deployment Guide

Comprehensive guide for deploying MagicAI v9.9 across different platforms and environments.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Deployment Options](#deployment-options)
3. [Prerequisites](#prerequisites)
4. [Deployment Methods](#deployment-methods)
   - [GitHub Pages (Static Site)](#1-github-pages-static-site)
   - [Docker Compose (Full Stack)](#2-docker-compose-full-stack)
   - [Local Development](#3-local-development)
   - [Vercel Deployment](#4-vercel-deployment)
   - [Traditional Hosting](#5-traditional-hosting)
5. [Environment Configuration](#environment-configuration)
6. [Testing Deployments](#testing-deployments)
7. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

MagicAI v9.9 is a full-stack Laravel application with Python backend services. Different deployment methods suit different use cases:

| Method | Best For | Complexity | Backend Support |
|--------|----------|------------|-----------------|
| **GitHub Pages** | Documentation, demos | ⭐ Easy | ❌ No |
| **Docker Compose** | Full features, dev/prod | ⭐⭐ Moderate | ✅ Yes |
| **Local Development** | Development, testing | ⭐⭐ Moderate | ✅ Yes |
| **Vercel** | Frontend, serverless | ⭐⭐ Moderate | ⚠️ Limited |
| **Traditional Hosting** | Shared/VPS hosting | ⭐⭐⭐ Complex | ✅ Yes |

---

## 🎨 Deployment Options

### Quick Decision Tree

```
What do you need?

📄 Just documentation/landing page?
   └─→ Use GitHub Pages

🚀 Full application with database?
   ├─→ Have Docker? → Use Docker Compose (Recommended)
   └─→ No Docker? → Use Local Development or Traditional Hosting

☁️ Want serverless/CDN?
   └─→ Use Vercel (Frontend only)

🧪 Development/Testing?
   └─→ Use Local Development or Docker Compose
```

---

## 📋 Prerequisites

### Common Requirements

- Git installed
- Basic command-line knowledge
- Admin access to deployment target

### Method-Specific Requirements

| Method | Requires |
|--------|----------|
| **GitHub Pages** | GitHub account with repo access |
| **Docker Compose** | Docker 20.10+, Docker Compose 2.0+ |
| **Local Development** | PHP 8.2+, Composer, Node.js 18+, MySQL 8.0+, Redis |
| **Vercel** | Vercel account, Vercel CLI (optional) |
| **Traditional Hosting** | cPanel/SSH access, PHP 8.2+, MySQL 8.0+ |

### System Requirements

#### Minimum
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 10GB
- **OS**: Linux, macOS, Windows (with WSL2 for Docker)

#### Recommended
- **CPU**: 4 cores
- **RAM**: 8GB
- **Storage**: 20GB
- **OS**: Ubuntu 20.04+ or similar

---

## 🚀 Deployment Methods

### 1. GitHub Pages (Static Site)

**Purpose**: Host static project documentation, landing pages, or demos.

**⚠️ Limitations**:
- Only static files (HTML/CSS/JS)
- No PHP/Laravel backend
- No database access
- No server-side processing

#### Setup Steps

1. **Enable GitHub Pages**
   ```
   Repository → Settings → Pages
   Source: GitHub Actions
   ```
   
2. **Verify Workflow**
   - Workflow file: `.github/workflows/pages.yml`
   - Triggers on push to `main` branch

3. **Deploy**
   ```bash
   # Option A: Push to main
   git push origin main
   
   # Option B: Manual trigger
   # Go to Actions → Deploy to GitHub Pages → Run workflow
   ```

4. **Access Site**
   - URL: https://v3ai2026.github.io/333/
   - Wait 1-2 minutes after deployment

#### Documentation
- 📖 [Detailed GitHub Pages Setup Guide](./GITHUB_PAGES_SETUP.md)

---

### 2. Docker Compose (Full Stack)

**Purpose**: Deploy complete application with all services (Laravel, MySQL, Redis, Python backend).

**✅ Advantages**:
- All dependencies included
- Consistent across environments
- Easy setup and teardown
- Production-ready

#### Quick Start

```bash
# 1. Clone repository
git clone https://github.com/v3ai2026/333.git
cd 333

# 2. Create environment file
cp .env.example .env

# 3. Edit .env (set database passwords, API keys, etc.)
nano .env

# 4. Start services
docker-compose up -d

# 5. Wait for services to start (30-60 seconds)
docker-compose ps

# 6. Access application
# Web: http://localhost:8000
# Backend API: http://localhost:8080
```

#### Detailed Setup

##### Step 1: Prepare Environment

```bash
# Copy environment files
cp .env.example .env
cp backend-service/.env.example backend-service/.env

# Generate Laravel app key
docker-compose run --rm web php artisan key:generate
```

##### Step 2: Configure Services

Edit `.env`:
```env
APP_NAME="MagicAI"
APP_ENV=production
APP_DEBUG=false
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=magicai
DB_USERNAME=magicai
DB_PASSWORD=your_secure_password

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

# Add your AI service API keys
OPENAI_API_KEY=your_key_here
```

##### Step 3: Build and Start

```bash
# Build images (first time only)
docker-compose build

# Start all services
docker-compose up -d

# Check status
docker-compose ps
```

##### Step 4: Initialize Database

```bash
# Run migrations
docker-compose exec web php artisan migrate --force

# Seed database (optional)
docker-compose exec web php artisan db:seed
```

##### Step 5: Verify Deployment

```bash
# Check logs
docker-compose logs -f web
docker-compose logs -f python-backend

# Test endpoints
curl http://localhost:8000  # Laravel app
curl http://localhost:8080/health  # Python backend
```

#### Docker Compose Files

The project includes multiple compose files for different scenarios:

- `docker-compose.yml` - Main compose file
- `docker-compose.local.yml` - Local development
- `docker-compose.prod.yml` - Production settings
- `docker-compose.full.yml` - Full stack with all services

#### Useful Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f [service_name]

# Restart service
docker-compose restart [service_name]

# Run commands in container
docker-compose exec web php artisan cache:clear

# Rebuild images
docker-compose build --no-cache

# Remove everything (including volumes)
docker-compose down -v
```

#### Documentation
- 📖 [Docker Compose Guide](./DOCKER-COMPOSE-GUIDE.md)

---

### 3. Local Development

**Purpose**: Development and testing without Docker.

**Requirements**:
- PHP 8.2+
- Composer 2.x
- Node.js 18+ and npm
- MySQL 8.0+
- Redis 7+

#### Setup Steps

##### Step 1: Install Dependencies

```bash
# Clone repository
git clone https://github.com/v3ai2026/333.git
cd 333

# Install PHP dependencies
composer install

# Install JavaScript dependencies
npm install
```

##### Step 2: Configure Environment

```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Edit .env with your database credentials
nano .env
```

##### Step 3: Setup Database

```bash
# Create database
mysql -u root -p -e "CREATE DATABASE magicai;"

# Run migrations
php artisan migrate

# Seed database (optional)
php artisan db:seed
```

##### Step 4: Start Development Servers

**Terminal 1 - Laravel**:
```bash
php artisan serve
# Runs at http://localhost:8000
```

**Terminal 2 - Python Backend**:
```bash
cd backend-service
pip install -r requirements.txt
python app.py
# Runs at http://localhost:8080
```

**Terminal 3 - Asset Compilation** (optional):
```bash
npm run dev
# Or for production: npm run build
```

##### Step 5: Access Application

- **Web**: http://localhost:8000
- **Backend API**: http://localhost:8080
- **API Docs**: http://localhost:8000/api/documentation

#### Documentation
- 📖 [Quick Start Guide](./QUICK_START.md)

---

### 4. Vercel Deployment

**Purpose**: Deploy frontend with serverless functions.

**⚠️ Limitations**:
- Laravel backend requires workarounds
- Database needs external service
- Not suitable for full Laravel apps

#### Setup Steps

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel

# Deploy to production
vercel --prod
```

#### Configuration

File: `vercel.json`
```json
{
  "version": 2,
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/public/$1"
    }
  ]
}
```

#### Documentation
- 📖 [Vercel Deployment Guide](./VERCEL_DEPLOY.md)

---

### 5. Traditional Hosting

**Purpose**: Deploy to shared hosting or VPS.

**Requirements**:
- PHP 8.2+ with required extensions
- MySQL 8.0+
- SSH/FTP access
- Composer access

#### Setup Steps

##### For VPS/Dedicated Server

```bash
# 1. Install dependencies
sudo apt update
sudo apt install php8.2 php8.2-{cli,fpm,mysql,xml,mbstring,curl,zip} \
                 mysql-server nginx composer

# 2. Clone and configure
cd /var/www
git clone https://github.com/v3ai2026/333.git magicai
cd magicai
composer install --no-dev --optimize-autoloader

# 3. Set permissions
sudo chown -R www-data:www-data /var/www/magicai
sudo chmod -R 755 /var/www/magicai
sudo chmod -R 775 /var/www/magicai/storage
sudo chmod -R 775 /var/www/magicai/bootstrap/cache

# 4. Configure web server (see nginx example below)

# 5. Setup environment
cp .env.example .env
php artisan key:generate
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

##### Nginx Configuration

```nginx
server {
    listen 80;
    server_name example.com;
    root /var/www/magicai/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

##### For Shared Hosting (cPanel)

1. **Upload Files**
   - Upload to `public_html` or subdirectory via FTP
   
2. **Move Laravel**
   ```bash
   # Via SSH or File Manager
   mv public/* ./
   mv public/.htaccess ./
   ```

3. **Update index.php**
   ```php
   // Change paths to point to correct locations
   require __DIR__.'/vendor/autoload.php';
   $app = require_once __DIR__.'/bootstrap/app.php';
   ```

4. **Set Permissions**
   - `storage/` → 775
   - `bootstrap/cache/` → 775

5. **Configure Database**
   - Create database in cPanel
   - Update `.env` with credentials

---

## ⚙️ Environment Configuration

### Required Environment Variables

```env
# Application
APP_NAME="MagicAI"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=magicai
DB_USERNAME=magicai_user
DB_PASSWORD=secure_password_here

# Cache & Queue
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Mail (choose provider)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_username
MAIL_PASSWORD=your_password
MAIL_ENCRYPTION=tls

# AI Services
OPENAI_API_KEY=your_openai_key
# Add other AI service keys as needed
```

### Security Best Practices

1. **Generate Strong Keys**
   ```bash
   php artisan key:generate
   ```

2. **Use Environment-Specific Settings**
   - Development: `APP_DEBUG=true`
   - Production: `APP_DEBUG=false`

3. **Secure Database Credentials**
   - Use strong passwords
   - Limit database user permissions
   - Use separate credentials per environment

4. **Configure HTTPS**
   ```env
   APP_URL=https://your-domain.com
   SESSION_SECURE_COOKIE=true
   ```

---

## 🧪 Testing Deployments

### Health Checks

```bash
# Laravel application
curl http://your-domain.com

# Python backend
curl http://your-domain.com:8080/health

# Database connection
docker-compose exec web php artisan tinker
>>> DB::connection()->getPdo();
```

### Verify Services

```bash
# Check all containers
docker-compose ps

# Test database
mysql -h localhost -u magicai -p magicai

# Test Redis
redis-cli ping
```

### Load Testing (Optional)

```bash
# Install Apache Bench
sudo apt install apache2-utils

# Run test
ab -n 1000 -c 10 http://localhost:8000/
```

---

## 🔧 Troubleshooting

### Common Issues

#### Issue: 500 Internal Server Error

**Causes**:
- Permissions issues
- Missing `.env` file
- Configuration cache

**Solutions**:
```bash
# Fix permissions
sudo chmod -R 775 storage bootstrap/cache

# Clear cache
php artisan config:clear
php artisan cache:clear
php artisan view:clear

# Regenerate cache
php artisan config:cache
php artisan route:cache
```

#### Issue: Database Connection Failed

**Solutions**:
```bash
# Verify credentials in .env
DB_HOST=127.0.0.1  # or 'db' for Docker
DB_DATABASE=magicai
DB_USERNAME=magicai
DB_PASSWORD=your_password

# Test connection
php artisan tinker
>>> DB::connection()->getPdo();

# Check database is running
# For Docker:
docker-compose exec db mysql -u root -p
```

#### Issue: Assets Not Loading

**Solutions**:
```bash
# Rebuild assets
npm install
npm run build

# For Laravel Mix:
php artisan storage:link

# Clear browser cache
# Use incognito/private mode to test
```

#### Issue: Docker Containers Won't Start

**Solutions**:
```bash
# Check logs
docker-compose logs

# Remove old containers
docker-compose down -v

# Rebuild images
docker-compose build --no-cache

# Start again
docker-compose up -d
```

---

## 📚 Additional Resources

### Documentation
- [GitHub Pages Setup](./GITHUB_PAGES_SETUP.md)
- [Docker Compose Guide](./DOCKER-COMPOSE-GUIDE.md)
- [Vercel Deployment](./VERCEL_DEPLOY.md)
- [Quick Start](./QUICK_START.md)
- [Workflow Documentation](../.github/workflows/README.md)

### External Resources
- [Laravel Deployment Docs](https://laravel.com/docs/deployment)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Configuration](https://nginx.org/en/docs/)

---

## 🆘 Getting Help

### Support Channels

1. **Check Documentation**
   - Review guides in `docs/` directory
   - Check troubleshooting sections

2. **Review Logs**
   - Application: `storage/logs/laravel.log`
   - Docker: `docker-compose logs`
   - Web server: `/var/log/nginx/error.log`

3. **Create an Issue**
   - Go to: https://github.com/v3ai2026/333/issues
   - Include:
     - Deployment method used
     - Error messages/logs
     - Steps to reproduce

4. **Community**
   - Search existing issues
   - Check discussions

---

## ✅ Deployment Checklist

### Pre-Deployment
- [ ] All requirements installed
- [ ] Environment variables configured
- [ ] Database credentials set
- [ ] API keys added to `.env`
- [ ] Tested locally

### Deployment
- [ ] Files uploaded/pulled
- [ ] Dependencies installed
- [ ] Database migrated
- [ ] Permissions set correctly
- [ ] Web server configured

### Post-Deployment
- [ ] Application accessible
- [ ] Health checks passing
- [ ] SSL certificate installed (production)
- [ ] Monitoring configured
- [ ] Backups scheduled

---

**Last Updated**: 2026-01-14  
**Version**: MagicAI v9.9  
**Maintained by**: v3ai2026

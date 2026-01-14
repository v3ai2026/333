#!/bin/bash
# ==============================================================================
# MagicAI v9.9 一键 Docker 部署脚本
# One-Click Docker Deployment Script
# ==============================================================================
# This script automates the entire deployment process for MagicAI v9.9
# It handles: Docker checks, environment setup, building, and health verification
# ==============================================================================

set -e  # Exit on error

# Color definitions for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Main deployment starts here
print_header "🚀 MagicAI v9.9 Docker Deployment"

# ==============================================================================
# Step 1: Check Prerequisites
# ==============================================================================
print_step "Step 1: Checking Prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker not installed!"
    echo ""
    echo "Please install Docker first:"
    echo "  • macOS: https://docs.docker.com/desktop/mac/install/"
    echo "  • Linux: https://docs.docker.com/engine/install/"
    echo "  • Windows: https://docs.docker.com/desktop/windows/install/"
    echo ""
    exit 1
fi
print_success "Docker is installed ($(docker --version | cut -d' ' -f3 | tr -d ','))"

# Check Docker Compose
if ! command -v docker compose &> /dev/null; then
    print_error "Docker Compose not installed!"
    echo ""
    echo "Please install Docker Compose v2:"
    echo "  • Usually bundled with Docker Desktop"
    echo "  • Linux: https://docs.docker.com/compose/install/"
    echo ""
    exit 1
fi
print_success "Docker Compose is installed"

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running!"
    echo ""
    echo "Please start Docker Desktop or Docker daemon first."
    echo ""
    exit 1
fi
print_success "Docker daemon is running"

# ==============================================================================
# Step 2: Environment Configuration
# ==============================================================================
print_step "Step 2: Setting Up Environment Configuration..."

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_info "Creating .env file from template..."
    cp .env.example .env
    
    # Generate APP_KEY using OpenSSL
    if command -v openssl &> /dev/null; then
        APP_KEY="base64:$(openssl rand -base64 32)"
        # Use appropriate sed syntax for macOS/Linux
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|APP_KEY=.*|APP_KEY=$APP_KEY|g" .env
        else
            sed -i "s|APP_KEY=.*|APP_KEY=$APP_KEY|g" .env
        fi
        print_success "Generated APP_KEY"
    else
        print_warning "OpenSSL not found, APP_KEY not generated. You may need to set it manually."
    fi
    
    print_success "Created .env file"
else
    print_info ".env file already exists, skipping..."
fi

# Create backend-service .env if needed
if [ -d backend-service ] && [ ! -f backend-service/.env ]; then
    if [ -f backend-service/.env.example ]; then
        cp backend-service/.env.example backend-service/.env
        print_success "Created backend-service/.env"
    else
        touch backend-service/.env
        print_info "Created empty backend-service/.env"
    fi
fi

# ==============================================================================
# Step 3: Stop Existing Containers
# ==============================================================================
print_step "Step 3: Stopping Existing Containers (if any)..."

if docker compose ps -q 2>/dev/null | grep -q .; then
    print_info "Found running containers, stopping them..."
    docker compose down --remove-orphans
    print_success "Stopped existing containers"
else
    print_info "No existing containers found"
fi

# ==============================================================================
# Step 4: Build Docker Images
# ==============================================================================
print_step "Step 4: Building Docker Images..."

print_info "This may take a few minutes on first run..."
if docker compose build --progress=plain; then
    print_success "Docker images built successfully"
else
    print_error "Failed to build Docker images"
    echo ""
    echo "Common issues:"
    echo "  • Check Dockerfile syntax in backend-service/"
    echo "  • Ensure requirements.txt is valid"
    echo "  • Check your internet connection"
    echo ""
    exit 1
fi

# ==============================================================================
# Step 5: Start Containers
# ==============================================================================
print_step "Step 5: Starting Docker Containers..."

if docker compose up -d; then
    print_success "Containers started successfully"
else
    print_error "Failed to start containers"
    echo ""
    echo "Try running: docker compose logs"
    echo ""
    exit 1
fi

# ==============================================================================
# Step 6: Wait for Services to Initialize
# ==============================================================================
print_step "Step 6: Waiting for Services to Initialize..."

# Wait for database
print_info "Waiting for MySQL database..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker compose exec -T db mysqladmin ping -h localhost --silent 2>/dev/null; then
        print_success "MySQL is ready"
        break
    fi
    echo -n "."
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    print_warning "MySQL didn't respond after ${max_attempts} attempts, but continuing..."
fi

# Wait for Redis
print_info "Waiting for Redis..."
sleep 3
if docker compose exec -T redis redis-cli ping &> /dev/null; then
    print_success "Redis is ready"
else
    print_warning "Redis not responding, but continuing..."
fi

# Wait for Python Backend
print_info "Waiting for Python Backend (this may take 30-40s)..."
max_attempts=40
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -f -s http://localhost:8080/health &> /dev/null; then
        print_success "Python Backend is healthy"
        break
    fi
    echo -n "."
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    print_warning "Python Backend didn't respond, check logs: docker compose logs python-backend"
fi

# ==============================================================================
# Step 7: Health Check
# ==============================================================================
print_step "Step 7: Performing Health Checks..."

echo ""
print_info "Container Status:"
docker compose ps

echo ""
print_info "Service Health Check Results:"

# Check Python Backend
echo -n "  • Python Backend (port 8080): "
if curl -f -s http://localhost:8080/health &> /dev/null; then
    echo -e "${GREEN}✓ Healthy${NC}"
else
    echo -e "${YELLOW}⚠ Not responding${NC}"
fi

# Check MySQL
echo -n "  • MySQL Database (port 3306): "
if docker compose exec -T db mysqladmin ping -h localhost --silent 2>/dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not responding${NC}"
fi

# Check Redis
echo -n "  • Redis Cache (port 6379): "
if docker compose exec -T redis redis-cli ping &> /dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not responding${NC}"
fi

# ==============================================================================
# Deployment Complete
# ==============================================================================
print_header "✅ Deployment Complete!"

echo -e "${GREEN}Your MagicAI v9.9 installation is ready!${NC}"
echo ""
echo -e "${CYAN}📍 Access URLs:${NC}"
echo "  🌐 API Backend:     http://localhost:8080"
echo "  🩺 Health Check:    http://localhost:8080/health"
echo "  💾 MySQL Database:  localhost:3306 (user: magicai, pass: password)"
echo "  🔴 Redis Cache:     localhost:6379"
echo ""
echo -e "${CYAN}📋 Useful Commands:${NC}"
echo "  • View logs:        docker compose logs -f"
echo "  • View backend logs: docker compose logs -f python-backend"
echo "  • Check status:     docker compose ps"
echo "  • Stop services:    docker compose down"
echo "  • Restart services: docker compose restart"
echo "  • Enter container:  docker compose exec python-backend bash"
echo ""
echo -e "${CYAN}🔧 Configuration:${NC}"
echo "  • Environment:      Edit .env file"
echo "  • Backend config:   Edit backend-service/.env"
echo "  • Docker config:    Edit docker-compose.yml"
echo ""
echo -e "${CYAN}🐛 Troubleshooting:${NC}"
echo "  • Port conflicts:   Check if ports 8080, 3306, 6379 are free"
echo "  • Build issues:     Run: docker compose build --no-cache"
echo "  • View all logs:    Run: docker compose logs"
echo ""
echo -e "${YELLOW}⚠️  Note: If services show as unhealthy, they may still be initializing.${NC}"
echo -e "${YELLOW}    Wait 1-2 minutes and check again with: docker compose ps${NC}"
echo ""

# Final check
if curl -f -s http://localhost:8080/health &> /dev/null; then
    echo -e "${GREEN}🎉 Success! Backend is responding at http://localhost:8080${NC}"
else
    echo -e "${YELLOW}⏳ Backend is still starting up. Check status in a minute.${NC}"
fi

echo ""

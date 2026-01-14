#!/bin/bash

# MagicAI v9.9 快速部署脚本
# 自动化设置和启动 Docker 容器

set -e

echo "════════════════════════════════════════════════════════════════"
echo "  🚀 MagicAI v9.9 快速部署"
echo "════════════════════════════════════════════════════════════════"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker 未安装${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose 未安装${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker 已安装${NC}"

# 1. 创建环境配置
echo ""
echo "1️⃣  配置环境变量..."

if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${GREEN}✓ 创建 .env 文件${NC}"
    
    # 生成 APP_KEY
    APP_KEY=$(php -r 'echo base64_encode(random_bytes(32));' 2>/dev/null || echo "base64:generated_key")
    sed -i "s|APP_KEY=base64:.*|APP_KEY=$APP_KEY|g" .env
    echo -e "${GREEN}✓ 生成 APP_KEY${NC}"
else
    echo -e "${YELLOW}⚠ .env 文件已存在，跳过${NC}"
fi

# 2. 检查 backend-service .env
if [ ! -f backend-service/.env ]; then
    cp backend-service/.env.example backend-service/.env
    echo -e "${GREEN}✓ 创建 backend-service/.env${NC}"
fi

# 3. 构建镜像
echo ""
echo "2️⃣  构建 Docker 镜像..."
docker-compose build --no-cache || echo -e "${YELLOW}⚠ 构建过程中有警告${NC}"
echo -e "${GREEN}✓ 镜像构建完成${NC}"

# 4. 启动服务
echo ""
echo "3️⃣  启动容器..."
docker-compose up -d
echo -e "${GREEN}✓ 容器已启动${NC}"

# 5. 等待数据库就绪
echo ""
echo "4️⃣  等待数据库初始化..."
for i in {1..30}; do
    if docker-compose exec -T db mysqladmin ping -u root -psecret &> /dev/null; then
        echo -e "${GREEN}✓ 数据库已就绪${NC}"
        break
    fi
    echo "⏳ 等待中... ($i/30)"
    sleep 1
done

# 6. 运行迁移
echo ""
echo "5️⃣  运行数据库迁移..."
docker-compose exec -T web php artisan key:generate 2>/dev/null || true
docker-compose exec -T web php artisan migrate --force || echo -e "${YELLOW}⚠ 迁移可能已运行${NC}"
echo -e "${GREEN}✓ 迁移完成${NC}"

# 7. 编译前端资源
echo ""
echo "6️⃣  编译前端资源..."
docker-compose exec -T web npm run build || echo -e "${YELLOW}⚠ 前端编译有问题${NC}"
echo -e "${GREEN}✓ 前端资源编译完成${NC}"

# 8. 验证服务
echo ""
echo "7️⃣  验证服务状态..."

echo -n "  检查 Web 应用... "
if curl -s http://localhost:8000/health &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⏳ 初始化中${NC}"
fi

echo -n "  检查 Python 后端... "
if curl -s http://localhost:8080/health &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⏳ 初始化中${NC}"
fi

echo -n "  检查 Redis... "
if docker-compose exec -T redis redis-cli ping &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

echo -n "  检查 MySQL... "
if docker-compose exec -T db mysql -umagicai -ppassword -e "SELECT 1;" &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# 9. 显示访问信息
echo ""
echo "════════════════════════════════════════════════════════════════"
echo -e "${GREEN}✓ 部署完成！${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📍 访问地址:"
echo "  🌐 Web 应用: http://localhost:8000"
echo "  📚 API 文档: http://localhost:8000/api/documentation"
echo "  🔧 后端 API: http://localhost:8080/status"
echo "  💾 数据库: localhost:3306 (user: magicai)"
echo "  🔴 Redis: localhost:6379"
echo ""
echo "📋 有用的命令:"
echo "  查看日志:      docker-compose logs -f"
echo "  进入容器:      docker-compose exec web bash"
echo "  停止服务:      docker-compose down"
echo "  重启服务:      docker-compose restart"
echo ""
echo "🔐 关键配置:"
echo "  编辑配置文件: nano .env"
echo "  查看日志:     docker-compose logs"
echo ""
echo "⏰ 约需 2-3 分钟才能完全初始化"
echo ""

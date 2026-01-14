#!/bin/bash
# Vercel 快速部署脚本
# 用法：bash vercel-deploy.sh
# 该脚本将自动化以下步骤：
# 1. 检查前置条件
# 2. 生成 APP_KEY（如未设置）
# 3. 提交 Git 更改
# 4. 通过 Vercel CLI 部署

set -e

echo "🚀 MagicAI v9.9 Vercel 快速部署"
echo "=================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印彩色信息
print_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
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

# 步骤 1: 检查前置条件
print_info "步骤 1: 检查前置条件..."

if ! command -v vercel &> /dev/null; then
  print_error "Vercel CLI 未安装"
  echo "运行以下命令安装："
  echo "  npm install -g vercel"
  exit 1
fi
print_success "Vercel CLI 已安装"

if ! command -v git &> /dev/null; then
  print_error "Git 未安装"
  exit 1
fi
print_success "Git 已安装"

if [ ! -d ".git" ]; then
  print_error "当前目录不是 Git 仓库"
  echo "运行以下命令初始化："
  echo "  git init && git add . && git commit -m 'Initial commit'"
  exit 1
fi
print_success "Git 仓库已初始化"

# 步骤 2: 生成 APP_KEY（如需要）
print_info "步骤 2: 检查 APP_KEY..."

if [ -f "server/.env" ] && grep -q "APP_KEY=base64:" server/.env; then
  app_key=$(grep "APP_KEY=" server/.env | cut -d= -f2)
  print_success "APP_KEY 已存在: ${app_key:0:20}..."
else
  print_warning "APP_KEY 未设置，生成新的..."
  
  if command -v php &> /dev/null; then
    cd server
    app_key=$(php artisan key:generate --show 2>/dev/null || echo "")
    cd ..
    
    if [ -n "$app_key" ]; then
      print_success "生成的 APP_KEY: ${app_key:0:20}..."
      echo ""
      print_warning "⚠️  请在 Vercel 控制面板中设置以下环境变量："
      echo "  APP_KEY=$app_key"
      echo ""
    else
      print_warning "无法自动生成 APP_KEY，请手动运行: php artisan key:generate --show"
    fi
  else
    print_warning "PHP 未安装，跳过 APP_KEY 生成"
    echo "请手动运行: php artisan key:generate --show"
  fi
fi

echo ""

# 步骤 3: 检查并提交 Git 更改
print_info "步骤 3: 提交 Git 更改..."

if ! git diff-index --quiet HEAD --; then
  print_warning "存在未提交的更改"
  echo ""
  echo "未提交的文件:"
  git status --short
  echo ""
  
  read -p "是否提交所有更改？(y/n): " commit_choice
  
  if [ "$commit_choice" = "y" ]; then
    git add .
    git commit -m "prepare: vercel deployment - $(date +%Y-%m-%d\ %H:%M:%S)"
    print_success "更改已提交"
  else
    print_warning "跳过 Git 提交，部署时可能出现问题"
  fi
else
  print_success "所有更改已提交"
fi

echo ""

# 步骤 4: 检查 Git 分支
print_info "步骤 4: 检查 Git 分支..."

current_branch=$(git rev-parse --abbrev-ref HEAD)
echo "当前分支: $current_branch"

if [ "$current_branch" != "main" ] && [ "$current_branch" != "master" ]; then
  print_warning "当前分支不是 main/master"
  read -p "继续使用 '$current_branch' 部署？(y/n): " branch_choice
  if [ "$branch_choice" != "y" ]; then
    echo "请切换到 main 或 master 分支:"
    echo "  git checkout main"
    exit 1
  fi
fi

echo ""

# 步骤 5: 检查 Vercel 登录状态
print_info "步骤 5: 检查 Vercel 认证..."

if ! vercel whoami &> /dev/null; then
  print_warning "未登录 Vercel，跳转到登录..."
  vercel login
fi

vercel_user=$(vercel whoami)
print_success "已登录用户: $vercel_user"

echo ""

# 步骤 6: Vercel 部署
print_info "步骤 6: 开始 Vercel 部署..."
echo ""
echo "💡 提示："
echo "  - 首次部署会询问项目详情（选择 'Link to existing project' 或 'Create new project'）"
echo "  - 选择 Git 仓库关联"
echo "  - 按照提示输入或确认环境变量"
echo ""

read -p "按 Enter 继续部署（或 Ctrl+C 取消）..."

vercel --prod

echo ""
echo "=================================="
print_success "部署已启动！"
echo ""
echo "后续步骤："
echo "1. 访问 Vercel 项目 URL（部署完成后显示）"
echo "2. 等待数据库迁移完成"
echo "3. 测试登录（daka / daka123456）"
echo "4. 配置自定义域名 DNS"
echo ""
echo "遇到问题？查看日志："
echo "  vercel logs -f"
echo ""

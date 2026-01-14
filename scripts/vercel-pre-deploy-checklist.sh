#!/bin/bash
# Vercel 部署前检查清单
# 运行：bash vercel-pre-deploy-checklist.sh

set -e

echo "🔍 MagicAI v9.9 Vercel 部署前检查清单"
echo "==========================================="
echo ""

# 检查 1: 文件存在
echo "✓ 检查文件完整性..."
files_to_check=(
  "vercel.json"
  "index.php"
  "server/artisan"
  "server/composer.json"
  "server/package.json"
  "server/public/index.php"
  "magicai.sql"
)

missing_files=0
for file in "${files_to_check[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✅ $file"
  else
    echo "  ❌ $file (缺失)"
    missing_files=$((missing_files + 1))
  fi
done

if [ $missing_files -gt 0 ]; then
  echo ""
  echo "⚠️  缺少 $missing_files 个文件，请检查项目结构。"
  exit 1
fi

echo ""
echo "✓ 检查构建依赖..."

# 检查 2: PHP 和 Composer
if command -v composer &> /dev/null; then
  composer_version=$(composer --version)
  echo "  ✅ Composer: $composer_version"
else
  echo "  ⚠️  Composer 未安装（Vercel 会自动安装）"
fi

# 检查 3: Node.js 和 npm
if command -v npm &> /dev/null; then
  npm_version=$(npm --version)
  echo "  ✅ npm: $npm_version"
else
  echo "  ❌ npm 未安装，需要手动安装"
  exit 1
fi

# 检查 4: Vercel CLI
if command -v vercel &> /dev/null; then
  vercel_version=$(vercel --version)
  echo "  ✅ Vercel CLI: $vercel_version"
else
  echo "  ℹ️  建议安装 Vercel CLI: npm install -g vercel"
fi

echo ""
echo "✓ 检查 Laravel 配置..."

# 检查 5: .env 文件
if [ -f "server/.env" ]; then
  echo "  ✅ server/.env 存在"
  if grep -q "APP_KEY=" server/.env && [ -n "$(grep APP_KEY server/.env | cut -d= -f2)" ]; then
    echo "  ✅ APP_KEY 已设置"
  else
    echo "  ⚠️  APP_KEY 未设置，请运行: php artisan key:generate"
  fi
else
  echo "  ℹ️  server/.env 未存在（Vercel 部署时需要环境变量）"
fi

# 检查 6: vercel.json 完整性
if grep -q "\"APP_KEY\"" vercel.json && \
   grep -q "\"DB_HOST\"" vercel.json && \
   grep -q "\"DB_DATABASE\"" vercel.json; then
  echo "  ✅ vercel.json 包含必要环境变量"
else
  echo "  ⚠️  vercel.json 缺少环境变量定义"
fi

echo ""
echo "✓ 检查数据库准备..."

# 检查 7: magicai.sql
if [ -f "magicai.sql" ]; then
  sql_size=$(wc -c < magicai.sql)
  echo "  ✅ magicai.sql ($((sql_size / 1024)) KB)"
  
  # 检查数据库结构
  if grep -q "CREATE TABLE.*users" magicai.sql; then
    echo "  ✅ 数据库模式包含 users 表"
  fi
else
  echo "  ❌ magicai.sql 缺失"
  exit 1
fi

echo ""
echo "✓ 检查 Git 状态..."

# 检查 8: Git 仓库
if [ -d ".git" ]; then
  echo "  ✅ Git 仓库已初始化"
  
  # 检查是否有未提交的更改
  if git diff-index --quiet HEAD --; then
    echo "  ✅ 所有更改已提交"
  else
    echo "  ⚠️  存在未提交的更改，建议提交后部署"
    echo "     运行: git add . && git commit -m 'prepare for vercel deployment'"
  fi
  
  # 检查分支
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  echo "  ℹ️  当前分支: $current_branch"
else
  echo "  ⚠️  未找到 Git 仓库，Vercel 部署需要 Git"
fi

echo ""
echo "✓ 检查清单..."

# 交互式检查清单
checklist_passed=0
checklist_total=8

echo ""
echo "请确认以下事项（输入 y/n）："
echo ""

read -p "1. 已设置 Vercel 账户并安装 CLI？ (y/n): " ans1
[ "$ans1" = "y" ] && ((checklist_passed++)) || echo "  ⚠️  请先注册 Vercel: https://vercel.com"

read -p "2. 已连接 GitHub/GitLab 账户？ (y/n): " ans2
[ "$ans2" = "y" ] && ((checklist_passed++)) || echo "  ⚠️  Vercel 需要 Git 访问权限"

read -p "3. 生产 MySQL 数据库已准备好？ (y/n): " ans3
[ "$ans3" = "y" ] && ((checklist_passed++)) || echo "  ⚠️  准备数据库并获取连接凭证"

read -p "4. 已生成 Laravel APP_KEY？ (y/n): " ans4
if [ "$ans4" = "y" ]; then
  ((checklist_passed++))
  read -p "   请粘贴 APP_KEY (base64:...): " app_key
  if [ -n "$app_key" ]; then
    echo "  ✅ 已记录：$app_key"
  fi
else
  echo "  ⚠️  运行: php artisan key:generate --show"
fi

read -p "5. 有可用的 Redis 实例？ (y/n): " ans5
[ "$ans5" = "y" ] && ((checklist_passed++)) || echo "  ℹ️  可选（使用 Vercel Redis）"

read -p "6. SMTP 邮件服务已配置？ (y/n): " ans6
[ "$ans6" = "y" ] && ((checklist_passed++)) || echo "  ℹ️  可选（部署后配置）"

read -p "7. 自定义域名 DNS 已指向 Vercel？ (y/n): " ans7
[ "$ans7" = "y" ] && ((checklist_passed++)) || echo "  ℹ️  可选（部署后配置）"

read -p "8. 已备份本地数据和配置？ (y/n): " ans8
[ "$ans8" = "y" ] && ((checklist_passed++)) || echo "  ⚠️  强烈建议备份"

echo ""
echo "==========================================="
echo "检查完成: $checklist_passed/$checklist_total 项通过"
echo "==========================================="
echo ""

if [ $checklist_passed -lt 5 ]; then
  echo "❌ 检查未通过。请完成上述步骤后重试。"
  exit 1
elif [ $checklist_passed -eq 8 ]; then
  echo "✅ 所有检查已通过！可以进行 Vercel 部署。"
  echo ""
  echo "后续步骤："
  echo "1. 登录 Vercel: vercel login"
  echo "2. 部署: vercel --prod"
  echo "3. 按照提示输入环境变量"
  echo "4. 等待部署完成（5-10 分钟）"
  exit 0
else
  echo "⚠️  大部分检查已通过，可以继续部署（某些步骤可选）。"
  echo ""
  echo "建议立即完成的步骤："
  echo "1. 确保 MySQL 和 Redis 可访问"
  echo "2. 获取 APP_KEY"
  echo "3. 提交所有 Git 更改"
  exit 0
fi

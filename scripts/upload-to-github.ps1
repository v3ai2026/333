# MagicAI v9.9 上传脚本
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MagicAI v9.9 自动上传到 GitHub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$projectPath = "C:\Users\Administrator\Desktop\333\MagicAI v9.9"

# 配置 Git
Write-Host "`n[1/6] 配置 Git..." -ForegroundColor Yellow
git config --global core.longpaths true
git config --global user.name "v3ai2026"
git config --global user.email "251017618+v3ai2026@users.noreply.github.com"

# 进入项目目录
Set-Location $projectPath
Write-Host "当前目录: $((Get-Location).Path)" -ForegroundColor Gray

# 创建 .gitignore
Write-Host "`n[2/6] 创建 .gitignore..." -ForegroundColor Yellow
@"
# IDE
.vscode/
.idea/
*.swp
*.swo

# Python
__pycache__/
*.py[cod]
*.egg-info/
dist/
build/
.Python
venv/
env/
ENV/
*.log

# Node
node_modules/
npm-debug.log
yarn-error.log
dist/
build/

# System
.DS_Store
Thumbs.db
.DS_Store?
._*
.Spotlight-V100
.Trashes

# Project specific
.env.local
.env.*.local
data/outputs/
storage/logs/
*.pid
.git/
"@ | Out-File -FilePath ".gitignore" -Encoding utf8 -Force

Write-Host "✓ .gitignore 已创建" -ForegroundColor Green

# 初始化仓库
Write-Host "`n[3/6] 初始化 Git 仓库..." -ForegroundColor Yellow
if (Test-Path ".git") {
    Write-Host "✓ Git 仓库已存在，跳过初始化" -ForegroundColor Gray
} else {
    git init
    Write-Host "✓ Git 仓库已初始化" -ForegroundColor Green
}

# 添加文件
Write-Host "`n[4/6] 添加文件到暂存区..." -ForegroundColor Yellow
git add .
Write-Host "✓ 文件已添加" -ForegroundColor Green

# 提交
Write-Host "`n[5/6] 提交更改..." -ForegroundColor Yellow
$commitCount = git rev-list --count HEAD 2>$null
if ($commitCount -eq 0) {
    git commit -m "Initial commit: MagicAI v9.9 - Enterprise AI Platform"
    Write-Host "✓ 初始提交已创建" -ForegroundColor Green
} else {
    git commit -m "Update: MagicAI v9.9" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 更新提交已创建" -ForegroundColor Green
    } else {
        Write-Host "⚠ 没有新的更改需要提交" -ForegroundColor Yellow
    }
}

# 推送
Write-Host "`n[6/6] 推送到 GitHub..." -ForegroundColor Yellow
git branch -M main
git remote remove origin 2>$null
git remote add origin https://github.com/v3ai2026/magicai.git
Write-Host "✓ 远程仓库已配置" -ForegroundColor Gray

Write-Host "推送代码到 GitHub (这可能需要几分钟)..." -ForegroundColor Yellow
git push -f -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "  ✓ 上传完成！" -ForegroundColor Green
    Write-Host "  访问: https://github.com/v3ai2026/magicai" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} else {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host "  ✗ 上传失败！" -ForegroundColor Red
    Write-Host "  请检查网络连接和 GitHub 权限" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
}

Write-Host "`n按回车键退出..." -ForegroundColor Gray
Read-Host

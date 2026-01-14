@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title MagicAI v9.9 - Upload to GitHub

echo ========================================
echo   MagicAI v9.9 Auto Upload to GitHub
echo ========================================
echo.

set "projectPath=C:\Users\Administrator\Desktop\333\MagicAI v9.9"

echo [1/6] Configuring Git...
git config --global core.longpaths true
git config --global user.name "v3ai2026"
git config --global user.email "251017618+v3ai2026@users.noreply.github.com"

cd /d "%projectPath%"
echo Current directory: %cd%
echo.

echo [2/6] Creating .gitignore...
(
echo .vscode/
echo .idea/
echo *.swp
echo *.swo
echo __pycache__/
echo *.pyc
echo *.pyo
echo *.egg-info/
echo dist/
echo build/
echo venv/
echo env/
echo ENV/
echo *.log
echo node_modules/
echo npm-debug.log
echo .DS_Store
echo Thumbs.db
echo .env.local
echo data/outputs/
echo storage/logs/
) > .gitignore

echo [3/6] Initializing Git repository...
if exist .git (
    echo Git repository already exists, skipping initialization
) else (
    git init
)

echo [4/6] Adding files...
git add .

echo [5/6] Committing changes...
git commit -m "Initial commit: MagicAI v9.9 - Enterprise AI Platform" 2>nul
if !errorlevel! equ 0 (
    echo Commit created successfully
) else (
    echo No new changes to commit or initial commit
)

echo [6/6] Pushing to GitHub...
git branch -M main
git remote remove origin 2>nul
git remote add origin https://github.com/v3ai2026/magicai.git

echo Pushing code to GitHub (may take a few minutes)...
git push -f -u origin main

if !errorlevel! equ 0 (
    echo.
    echo ========================================
    echo   Upload completed successfully!
    echo   Repository: https://github.com/v3ai2026/magicai
    echo ========================================
) else (
    echo.
    echo ========================================
    echo   Upload failed!
    echo   Check network connection and GitHub permissions
    echo ========================================
)

echo.
pause

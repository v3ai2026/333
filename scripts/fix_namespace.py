#!/usr/bin/env python3
import os
import glob

# 修复所有magicai-updater中的PHP命名空间
for file in glob.glob('Magicai-Server-Files/packages/magicai/magicai-updater/src/**/*.php', recursive=True):
    try:
        with open(file, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        # 尝试用latin-1编码
        with open(file, 'r', encoding='latin-1') as f:
            content = f.read()
    
    # 替换所有错误的双反斜杠为单反斜杠
    original = content
    content = content.replace('MagicAI\\\\Updater', 'MagicAI\\Updater')
    
    if original != content:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Fixed: {file}')
    else:
        print(f'No changes needed: {file}')


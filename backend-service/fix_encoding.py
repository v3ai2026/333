#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import re

with open('app.py', 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Replace all Chinese comments with English equivalents
replacements = {
    '处理客服对话请求': 'Handle customer service chat requests',
    '用户的问': 'User question',
    'AI的回': 'AI response',
    '对话历史': 'Chat history',
    '缓存命中': 'Cache hit',
    '?': '?',  # Replace any remaining broken chars
}

for cn, en in replacements.items():
    content = content.replace(cn, en)

# Remove any remaining non-ASCII that might be broken
content = re.sub(r'[^\x00-\x7F]+', '?', content)

with open('app.py', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed encoding issues")

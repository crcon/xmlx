#!/bin/bash
# 一键同步并推送到 GitHub Pages
set -e
cd "$(dirname "$0")"

# 同步 index.html
cp "上会材料生成系统.html" index.html

# 提交并推送
MSG=${1:-"更新 $(date '+%Y-%m-%d %H:%M')"}
git add "上会材料生成系统.html" index.html
git commit -m "$MSG" 2>/dev/null || echo "没有新变更需要提交"
git push

echo "✅ 已推送至 https://crcon.github.io/xmlx/"

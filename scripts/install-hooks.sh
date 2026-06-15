#!/bin/bash
# === 安装 git hooks ===
# 将 scripts/pre-commit 链接到 .git/hooks/pre-commit

set -e
cd "$(dirname "$0")/.."

HOOK_SOURCE="scripts/pre-commit"
HOOK_TARGET=".git/hooks/pre-commit"

if [ ! -f "$HOOK_SOURCE" ]; then
    echo "❌ 未找到 $HOOK_SOURCE"
    exit 1
fi

if [ ! -d ".git/hooks" ]; then
    echo "❌ 未找到 .git/hooks 目录（不在 git 仓库中？）"
    exit 1
fi

# 创建符号链接
ln -sf "../../$HOOK_SOURCE" "$HOOK_TARGET"
chmod +x "$HOOK_TARGET"

echo "✅ pre-commit hook 已安装"
echo "   源文件: $HOOK_SOURCE"
echo "   目标:   $HOOK_TARGET"
echo ""
echo "每次 git commit 前将自动运行 lint + self-check 检查"
echo "如需跳过: git commit --no-verify"

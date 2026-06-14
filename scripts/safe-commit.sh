#!/bin/bash
# === 知识库安全提交脚本 ===
# 自动 prepend [agent-标识] 前缀 + git add -A + commit + push
# 用法: bash scripts/safe-commit.sh "变更描述 — 变动文件列表"
# Agent 标识从 HERMES_MODEL 环境变量或 git config 自动推断

set -e
cd "$(dirname "$0")/.."

DESC="${1:-}"
if [[ -z "$DESC" ]]; then
  echo "用法: bash scripts/safe-commit.sh \"变更描述 — 变动文件列表\""
  exit 1
fi

# 推断 agent 标识
AGENT_ID="${HERMES_MODEL:-}"
if [[ -z "$AGENT_ID" ]]; then
  AGENT_ID=$(git config user.agent-id 2>/dev/null || echo "")
fi
if [[ -z "$AGENT_ID" ]]; then
  # Fallback: 用 git user.name
  AGENT_ID=$(git config user.name 2>/dev/null || echo "unknown-agent")
fi

# 构建 commit message
COMMIT_MSG="[${AGENT_ID}] ${DESC}"

echo "→ Agent 标识: ${AGENT_ID}"
echo "→ Commit: ${COMMIT_MSG}"
echo ""

# 查看变更
echo "--- 待提交文件 ---"
git status --short
echo ""

# 验证
echo "--- 运行 lint ---"
bash scripts/lint-knowledge-base.sh
echo ""

# 执行
git add -A
git commit -m "${COMMIT_MSG}"
git push origin main

echo ""
echo "✅ 已提交并推送"

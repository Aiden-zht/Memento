#!/bin/bash
# === 知识库变更检查 + 轻量搜索规则提示脚本 ===
# 用于 Agent session 初始化时：
#   1. 无感知获取其他 Agent 的变更
#   2. 注入轻量 KB 搜索规则，避免默认加载过多正文
# 用法: bash scripts/pull-and-check.sh

set -e
cd "$(dirname "$0")/.."

STATE_FILE=".last_seen_commit"

# 拉取最新
git pull origin main 2>/dev/null || true

# 读取上次记录的 commit
LAST_SEEN=$(cat "$STATE_FILE" 2>/dev/null || echo "")

# 展示变更
if [ -n "$LAST_SEEN" ] && git rev-parse --verify "$LAST_SEEN" >/dev/null 2>&1; then
    NEW_COUNT=$(git rev-list --count "$LAST_SEEN..HEAD" 2>/dev/null || echo 0)
    if [ "$NEW_COUNT" -gt 0 ]; then
        echo "===== 其他 Agent 的变更 (${NEW_COUNT} 个新提交) ====="
        git log --oneline "$LAST_SEEN..HEAD"
        echo ""
    fi
else
    echo "===== 首次拉取/无历史记录，展示最近 5 个提交 ====="
    git log --oneline -5
    echo ""
fi

# 保存当前 HEAD
git rev-parse HEAD > "$STATE_FILE"
echo "===== 当前 HEAD: $(cat $STATE_FILE | cut -c1-7) ====="

# ═══════════════════════════════════════════════════════════════
# 搜索规则（任务索引 + 全文搜索 + synopsis 筛选为主）
# ═══════════════════════════════════════════════════════════════
# provides 是辅助语义标签和 cron 固定依赖入口，不是唯一入口。
# 搜不到标签时必须使用任务关键词/规则名全文搜索兜底。
# ═══════════════════════════════════════════════════════════════
echo ""
echo "========== 搜索规则 =========="
echo "主路径："
echo "  1. 先读 规章制度/知识库管理/任务类型索引.md"
echo "  2. rg \"<任务关键词|规则名>\" --include=\"*.md\" -l"
echo "  3. 读候选文件 frontmatter，按 synopsis/load/status 筛选"
echo "  4. 只读取与当前任务相关的正文；README/初始化/行为约束按需加载"
echo ""
echo "辅助方式（已知 provides 标签或 cron 固定依赖时）："
echo "  python3 scripts/provides-search.py --synopsis <标签1> <标签2>"
echo ""
echo "禁止："
echo "  ❌ 只靠文件名猜规则"
echo "  ❌ 冷启动默认读取 README 或整目录正文"
echo "  ❌ provides 未命中就放弃搜索"
echo "  ❌ 读取 archive/deprecated 内容后不做状态判断"
echo ""
echo "示例："
echo "  找质量检查规则   → rg \"质量检查\" --include=\"*.md\" -l → 读 synopsis"
echo "  已知固定依赖     → python3 scripts/provides-search.py --synopsis 质量检查 图片治理"
echo ""
echo "详见：任务类型索引.md · 00-读取规范.md · 07-Agent行为约束.md"
echo "===================================="

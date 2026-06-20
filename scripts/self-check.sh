#!/bin/bash
# self-check.sh — KB 自主健康检查（8 维度，零 LLM token）
# 互补现有 lint/audit/provides-search，消化所有维度在 bash 层
# 用法: bash scripts/self-check.sh

set -euo pipefail
cd "$(dirname "$0")/.."

FAILS=0
TOTAL=8
FORMAL_ROOTS=(规章制度 产物规范 专业知识 素材库 项目知识 用户资料)

# ── S1: 黑名单违禁 ──────────────────────────────────────────────
S1_FILES=$(find . \( -name '*.html' -o -name '*.jpg' -o -name '*.png' -o -name '*.json' -o -path '*/output/*' \) \
    ! -path './.git/*' ! -path './scripts/*' ! -path './.obsidian/*' 2>/dev/null)
S1_COUNT=$(echo "$S1_FILES" | grep -c . || true)
if [ "$S1_COUNT" -eq 0 ]; then
    S1_MSG="PASS (0 违禁)"
else
    S1_MSG="FAIL: $(echo "$S1_FILES" | head -1 | xargs)"
    FAILS=$((FAILS + 1))
fi

# ── S2: 废弃残留 ──────────────────────────────────────────────────
S2_DEPRECATED=$(grep -rl 'status: deprecated' --include='*.md' . 2>/dev/null || true)
S2_ISSUES=0
if [ -n "$S2_DEPRECATED" ]; then
    while IFS= read -r df; do
        bname=$(basename "$df" .md)
        refs=$(grep -l "$bname" --include='*.md' . 2>/dev/null | grep -v "$df" | head -1 || true)
        if [ -n "$refs" ]; then
            S2_ISSUES=$((S2_ISSUES + 1))
        fi
    done <<< "$S2_DEPRECATED"
fi
if [ "$S2_ISSUES" -eq 0 ]; then
    S2_DEP_COUNT=$(echo "$S2_DEPRECATED" | grep -c . || true)
    S2_MSG="PASS ($S2_DEP_COUNT deprecated, 0 被引用)"
else
    S2_MSG="FAIL: $S2_ISSUES deprecated 文件仍被引用"
    FAILS=$((FAILS + 1))
fi

# ── S3: 正式目录索引完整性 ────────────────────────────────────────
S3_DIRS=$(
    for root in "${FORMAL_ROOTS[@]}"; do
        [ -d "$root" ] || continue
        find "$root" -name '*.md' -type f
    done | sed 's|/[^/]*\.md$||' | sort -u
)
S3_TOTAL=0
S3_MISSING=0
S3_LIST=""
while IFS= read -r dir; do
    [ -z "$dir" ] && continue
    S3_TOTAL=$((S3_TOTAL + 1))
    if [ ! -f "$dir/index.md" ]; then
        S3_MISSING=$((S3_MISSING + 1))
        S3_LIST="$S3_LIST $dir"
    fi
done <<< "$S3_DIRS"
if [ "$S3_MISSING" -eq 0 ]; then
    S3_MSG="PASS ($S3_TOTAL/$S3_TOTAL)"
else
    S3_MSG="FAIL: $S3_MISSING 正式目录缺索引 ($S3_TOTAL 总)"
    FAILS=$((FAILS + 1))
fi

# ── S4: 目录深度 ──────────────────────────────────────────────────
S4_VIOLATIONS=$(find . -type d ! -path './.git' ! -path './.git/*' ! -path './_templates' ! -path './_templates/*' \
    ! -path './scripts' ! -path './scripts/*' ! -path './.obsidian' ! -path './.obsidian/*' \
    | awk -F/ '{d=NF-1; if(d>5) print}' | wc -l)
if [ "$S4_VIOLATIONS" -eq 0 ]; then
    S4_MSG="PASS (0 超层)"
else
    S4_MSG="FAIL: $S4_VIOLATIONS 目录超 5 层"
    FAILS=$((FAILS + 1))
fi

# ── S5: Git 清洁度 ────────────────────────────────────────────────
S5_UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
UPSTREAM_REF=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || echo "")
if [ -n "$UPSTREAM_REF" ]; then
    S5_UNPUSHED=$(git log "${UPSTREAM_REF}"..HEAD --oneline 2>/dev/null | wc -l)
else
    S5_UNPUSHED=0
fi
if [ "$S5_UNCOMMITTED" -eq 0 ] && [ "$S5_UNPUSHED" -eq 0 ]; then
    S5_MSG="PASS (clean)"
elif [ "$S5_UNCOMMITTED" -gt 0 ] && [ "$S5_UNPUSHED" -eq 0 ]; then
    S5_MSG="FAIL: $S5_UNCOMMITTED 未提交"
    FAILS=$((FAILS + 1))
elif [ "$S5_UNCOMMITTED" -eq 0 ] && [ "$S5_UNPUSHED" -gt 0 ]; then
    S5_MSG="FAIL: $S5_UNPUSHED 未推送"
    FAILS=$((FAILS + 1))
else
    S5_MSG="FAIL: $S5_UNCOMMITTED 未提交 + $S5_UNPUSHED 未推送"
    FAILS=$((FAILS + 1))
fi

# ── S6: skills/provides 一致性 ────────────────────────────────────
S6_MISSING=""
S6_SKILL_COUNT=0
# Collect all KB provides tags
ALL_PROVIDES=$(python3 -c "
import yaml, os, glob
tags = set()
for md in glob.glob('**/*.md', recursive=True):
    if '/.git/' in md or '/_templates/' in md or '/scripts/' in md: continue
    try:
        content = open(md).read()
        if not content.startswith('---'): continue
        parts = content.split('---', 2)
        if len(parts) < 3: continue
        fm = yaml.safe_load(parts[1])
        p = fm.get('provides', [])
        if isinstance(p, str): p = [p]
        if isinstance(p, list):
            for t in p:
                if isinstance(t, str): tags.add(t)
    except: pass
for t in sorted(tags): print(t)
" 2>/dev/null)

# Check each skill
SKILL_DIR="$HOME/.hermes/skills"
if [ -d "$SKILL_DIR" ]; then
    for skill_md in "$SKILL_DIR"/*/SKILL.md; do
        [ -f "$skill_md" ] || continue
        requires=$(python3 -c "
import yaml
c = open('$skill_md').read()
p = c.split('---', 2)
if len(p) >= 3:
    d = yaml.safe_load(p[1])
    r = d.get('requires_provides', [])
    if r: print('\n'.join(r))
" 2>/dev/null)
        [ -z "$requires" ] && continue
        S6_SKILL_COUNT=$((S6_SKILL_COUNT + 1))
        name=$(basename "$(dirname "$skill_md")")
        while IFS= read -r tag; do
            [ -z "$tag" ] && continue
            if ! echo "$ALL_PROVIDES" | grep -qxF "$tag"; then
                S6_MISSING="$S6_MISSING${S6_MISSING:+, }$name:$tag"
            fi
        done <<< "$requires"
    done
fi
if [ -z "$S6_MISSING" ]; then
    if [ "$S6_SKILL_COUNT" -eq 0 ]; then
        S6_MSG="NOT_APPLICABLE (0 skills)"
    else
        S6_MSG="PASS ($S6_SKILL_COUNT/$S6_SKILL_COUNT)"
    fi
else
    S6_MSG="FAIL: $S6_MISSING"
    FAILS=$((FAILS + 1))
fi

# ── S7: 文件膨胀趋势 ──────────────────────────────────────────────
S7_TOTAL_FILES=$(find . -name '*.md' ! -path './.git/*' ! -path './_templates/*' ! -path './docs/superpowers/specs/*' | wc -l)
S7_TOTAL_LINES=$(find . -name '*.md' ! -path './.git/*' ! -path './_templates/*' ! -path './docs/superpowers/specs/*' -exec cat {} + 2>/dev/null | wc -l)
# 周新增: 排除首提交（避免新仓库把所有文件算作"本周新增"）
ROOT_COMMIT=$(git rev-list --max-parents=0 HEAD 2>/dev/null)
S7_WEEK_NEW=$(git log --diff-filter=A --name-only --since='7 days ago' --format='' -- '*.md' 2>/dev/null \
    | { grep -v '^$' || true; } | { grep -v '^_templates/' || true; } | sort -u | wc -l)
S7_WEEK_NEW_EXCL=$(git log --diff-filter=A --name-only --since='7 days ago' --format='' --not "$ROOT_COMMIT" -- '*.md' 2>/dev/null \
    | { grep -v '^$' || true; } | { grep -v '^_templates/' || true; } | sort -u | wc -l)
if [ "$S7_WEEK_NEW_EXCL" -lt "$S7_WEEK_NEW" ] && [ "$S7_WEEK_NEW_EXCL" -ge 0 ] 2>/dev/null; then
    S7_WEEK_NEW=$S7_WEEK_NEW_EXCL
fi
S7_MSG="OK ($S7_TOTAL_FILES files, +$S7_WEEK_NEW this week)"

# ── S8: 关键入口可达 ──────────────────────────────────────────────
# 复用 lint E04，仅关注关键入口文件
S8_BROKEN=0
for entry in AGENTS.md README.md 规章制度/知识库管理/任务类型索引.md; do
    [ ! -f "$entry" ] && continue
    # 检查该文件的 wikilink 是否能解析（用 lint 的 E04 逻辑子集）
    while IFS= read -r link; do
        link="${link//\[\[/}"
        link="${link//\]\]/}"
        link="${link%%#*}"      # 去掉锚点
        link="${link%%\|*}"     # 去掉别名
        [ -z "$link" ] && continue
        # 跳过纯 http 链接和模板变量
        [[ "$link" =~ ^https?:// ]] && continue
        # 尝试解析
        found=0
        # 1. 精确 .md
        [ -f "${link}.md" ] && found=1
        # 2. index.md
        [ -d "$link" ] && [ -f "${link}/index.md" ] && found=1
        # 3. 去掉 .md 后缀的文件
        [ -f "$link" ] && found=1
        if [ "$found" -eq 0 ]; then
            S8_BROKEN=$((S8_BROKEN + 1))
        fi
    done < <(grep -oP '\[\[[^]]+\]\]' "$entry" 2>/dev/null || true)
done
if [ "$S8_BROKEN" -eq 0 ]; then
    S8_MSG="PASS (0 断链)"
else
    S8_MSG="FAIL: $S8_BROKEN 断链"
    FAILS=$((FAILS + 1))
fi

# ── 输出 ───────────────────────────────────────────────────────────
PASSED=$((TOTAL - FAILS))
printf "%-30s %-30s\n" "S1 黑名单: $S1_MSG" "S2 废弃: $S2_MSG"
printf "%-30s %-30s\n" "S3 索引:   $S3_MSG" "S4 深度: $S4_MSG"
printf "%-30s %-30s\n" "S5 Git:    $S5_MSG" "S6 Skills: $S6_MSG"
printf "%-30s %-30s\n" "S7 膨胀:   $S7_MSG" "S8 入口: $S8_MSG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$FAILS" -eq 0 ]; then
    echo "KB 健康: $PASSED/$TOTAL ✅ 可放心使用"
else
    echo "KB 健康: $PASSED/$TOTAL ⚠️  $FAILS 项需关注"
fi

#!/bin/bash
# === 知识库内容治理 - 自动化检查脚本 ===
# 检查所有 .md 文件是否符合治理规范
# 用法: bash scripts/lint-knowledge-base.sh
# 退出码: 0 = 通过, 1 = 发现问题

set -e

cd "$(dirname "$0")/.."
ROOT=$(pwd)
EXIT_CODE=0
ERRORS=()
WARNINGS=()
TMPDIR=$(mktemp -d /tmp/lint.XXXXXX)

cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT

# ──────────────────────────────────────────────
# Phase 0: 收集文件清单 + 构建索引（一次性）
# ──────────────────────────────────────────────

ALL_FILES=()
IDX_PATH="$TMPDIR/idx_path"
IDX_BNAME="$TMPDIR/idx_bname"

while IFS= read -r f; do
  ALL_FILES+=("$f")
  rel="${f#$ROOT/}"
  echo "${rel%.md}" >> "$IDX_PATH"
done < <(
  find "$ROOT" -name '*.md' \
    -not -path "$ROOT/.git/*" \
    -not -path "$ROOT/.superpowers/*" \
    -not -path "$ROOT/docs/*" \
    -not -path "$ROOT/archive/*" \
    -not -path "$ROOT/_templates/*" \
  | sort
)

sort -u -o "$IDX_PATH" "$IDX_PATH"
while IFS= read -r p; do
  basename "$p" >> "$IDX_BNAME"
done < "$IDX_PATH"
sort -u -o "$IDX_BNAME" "$IDX_BNAME"

# git 变更列表（core.quotePath=false 避免非 ASCII 路径转义）
CHANGED_IDX="$TMPDIR/changed"
{
  git -c core.quotePath=false diff --name-only HEAD 2>/dev/null
  git -c core.quotePath=false diff --name-only --cached HEAD 2>/dev/null
} | sort -u > "$CHANGED_IDX"

# ──────────────────────────────────────────────
# 文件类型分级
# ──────────────────────────────────────────────
# 返回: core | ref | raw
#   core = 规章制度/（规范文件，全检）
#   ref  = 业务/ 知识/（参考文件，仅检 E01+E04）
#   raw  = 其余目录（原始资料，不检查）
file_grade() {
  local rel="$1"
  case "$rel" in
    规章制度/*)  echo "core" ;;
    业务/*|知识/*)  echo "ref" ;;
    *)           echo "raw" ;;
  esac
}

# ──────────────────────────────────────────────
# 检查函数
# ──────────────────────────────────────────────

# === 检查 1: frontmatter（全部纯 bash，零子进程） ===
check_frontmatter() {
  local file="$1"
  local rel="${file#$ROOT/}"
  local grade
  grade=$(file_grade "$rel")
  [[ "$grade" == "raw" ]] && return   # 原始资料跳过

  local content
  content=$(head -30 "$file")

  local title="" date="" tags="" category=""
  local load="" audience="" provides="" status=""
  local version="" changelog=""
  local has_versions=0
  local in_versions=0

  while IFS= read -r line; do
    case "$line" in
      "title: "*)      title="$line" ;;
      "date: "*)       date="$line" ;;
      "tags: "*)       tags="$line" ;;
      "category: "*)   category="$line" ;;
      "load: "*)       load="$line" ;;
      "audience: "*)   audience="$line" ;;
      "provides: "*)   provides="$line" ;;
      "status: "*)     status="$line" ;;
      "version: "*)    version="$line" ;;
      "changelog: "*)  changelog="$line" ;;
      "versions:"*)    has_versions=1; in_versions=1 ;;
      "  "*)
        if [[ $in_versions -eq 1 ]]; then
          # versions 子项值必须为正整数
          local val="${line##* }"
          case "$val" in
            ''|0|*[!0-9]*) ERRORS+=("E05|$rel|versions 值必须是正整数: $line") ;;
          esac
        fi
        ;;
      *)
        # 非缩进行退出 versions 块
        [[ $in_versions -eq 1 ]] && in_versions=0
        ;;
    esac
  done <<< "$content"

  # ── 必需字段 ──
  local missing_req=""
  [[ -z "$title" ]] && missing_req+=" title"
  [[ -z "$date" ]] && missing_req+=" date"
  [[ -z "$tags" ]] && missing_req+=" tags"
  [[ -z "$category" ]] && missing_req+=" category"

  if [[ -n "$missing_req" ]]; then
    # 检查是否有 frontmatter 标记
    local first_line
    IFS= read -r first_line <<< "$content"
    if [[ "$first_line" == "---" ]]; then
      ERRORS+=("E01|$rel|frontmatter 缺少必需字段:$missing_req")
    else
      ERRORS+=("E01|$rel|缺少 YAML frontmatter")
    fi
  fi

  # ── 推荐字段（仅 core） ──
  local missing_opt=""
  [[ -z "$load" ]] && missing_opt+=" load"
  [[ -z "$provides" ]] && missing_opt+=" provides"
  [[ -z "$status" ]] && missing_opt+=" status"
  [[ -n "$missing_opt" ]] && WARNINGS+=("W01|$rel|frontmatter 缺少推荐字段:$missing_opt")

  # ── tags 带 # ──
  [[ -n "$tags" && "$tags" == *"#"* ]] && WARNINGS+=("W02|$rel|tags 字段包含 # 符号: $tags")

  # ── provides 为空 ──
  [[ -n "$provides" && "$provides" == *"[]"* ]] && WARNINGS+=("W03|$rel|provides 为空列表，需补充语义标签")

  # ── E05: version / changelog / versions（仅 core） ──
  if [[ "$grade" == "core" ]] && [[ -n "$version" ]]; then
    local ver_val="${version#version: }"
    case "$ver_val" in
      ''|0|*[!0-9]*) ERRORS+=("E05|$rel|version 必须是正整数，当前值: $ver_val") ;;
    esac
    [[ -z "$changelog" ]] && ERRORS+=("E05|$rel|有 version 字段但缺少 changelog")
    # versions 为可选字段；仅当文件写了 versions 时检查子项格式。
  fi

  # ── E05-4: 版本漏改检查（仅对已变更文件，仅 core） ──
  if [[ "$grade" == "core" ]] && [[ -n "$version" ]] && grep -F -x "$rel" "$CHANGED_IDX" >/dev/null 2>&1; then
    if git cat-file -e HEAD:"$rel" 2>/dev/null; then
      local head_ver
      head_ver=$(git show HEAD:"$rel" 2>/dev/null | grep '^version: ' | head -1 | sed 's/^version: *//' || true)
      local cur_ver="${version#version: }"
      if [[ -n "$head_ver" ]] && [[ "$cur_ver" == "$head_ver" ]]; then
        # body 变更检测（排除 frontmatter-only 变更）
        local diff_out
        diff_out=$({
          git diff HEAD -- "$rel" 2>/dev/null
          git diff --cached HEAD -- "$rel" 2>/dev/null
        } | sort -u || true)

        local has_body=0 has_fm=0
        while IFS= read -r dline; do
          [[ -z "$dline" ]] && continue
          [[ "$dline" == ---* || "$dline" == +++* || "$dline" == @@* ]] && continue
          local first="${dline:0:1}"
          [[ "$first" != "+" && "$first" != "-" ]] && continue
          local rest="${dline:1}"
          case "$rest" in
            ---|"title:"*|"date:"*|"tags:"*|"category:"*|"load:"*|"audience:"*|"provides:"*|"status:"*|"version:"*|"changelog:"*|"versions:"*|" "*)
              has_fm=$((has_fm + 1)) ;;
            *)
              has_body=$((has_body + 1)) ;;
          esac
        done <<< "$diff_out"
        if [[ $has_body -gt $has_fm ]]; then
          ERRORS+=("E05|$rel|内容已变更但 version 未从 $head_ver 递增；改内容必须 +1 version 并更新 changelog/versions")
        fi
      fi
    fi
  fi
}

# === 检查 2: 文件行数 ===
check_line_count() {
  local file="$1"
  local rel="${file#$ROOT/}"
  local grade
  grade=$(file_grade "$rel")
  [[ "$grade" != "core" ]] && return

  local lines
  lines=$(wc -l < "$file")
  if [[ $lines -gt 600 ]]; then
    ERRORS+=("E02|$rel|文件 ${lines} 行，超过 600 行限制")
  elif [[ $lines -gt 500 ]]; then
    WARNINGS+=("W02|$rel|文件 ${lines} 行，接近 600 行限制，建议拆分")
  fi
}

# === 检查 3: 文件名规范 ===
check_filename() {
  local file="$1"
  local rel="${file#$ROOT/}"
  local grade
  grade=$(file_grade "$rel")
  [[ "$grade" != "core" ]] && return

  local bname="${file##*/}"

  case "$bname" in
    *[#\&*@!]*) ERRORS+=("E03|$rel|文件名包含特殊字符: $bname") ;;
  esac

  case "$bname" in
    *.md) ;;
    *) ERRORS+=("E03|$rel|文件名不是 .md 扩展名: $bname") ;;
  esac
}

# === 检查 4: wiki-link 有效性（批量 grep 索引查找） ===
check_wikilinks() {
  local file="$1"
  local rel="${file#$ROOT/}"
  local grade
  grade=$(file_grade "$rel")
  [[ "$grade" == "raw" ]] && return

  local targets
  targets=$(
    grep -oE '\[\[[^]]*\]\]' "$file" 2>/dev/null \
      | sed 's/^\[\[//;s/\]\]$//;s/[\\|].*//;s/|.*//;s/#.*//;s/\.md$//' \
      | grep -v '://' | grep -v '^#' || true
  )
  [[ -z "$targets" ]] && return

  # 跳过占位符/示例链接（常见模式：概念性引用、参数占位符）
  local filtered=""
  while IFS= read -r t; do
    [[ -z "$t" ]] && continue
    case "$t" in
      *链接*|*dir/*|*wiki-link*|*\{*\}*|*README*) continue ;;
    esac
    filtered+="$t"$'\n'
  done <<< "$targets"
  targets="$(echo "$filtered" | sed '/^$/d')"
  [[ -z "$targets" ]] && return

  # 批量检查：哪些 targets 不在路径索引中
  local missing
  missing=$(echo "$targets" | grep -F -x -v -f "$IDX_PATH" 2>/dev/null || true)
  [[ -z "$missing" ]] && return

  # 剩余缺失尝试 basename 匹配
  while IFS= read -r miss; do
    [[ -z "$miss" ]] && continue
    local bname="${miss##*/}"
    if ! grep -F -x "$bname" "$IDX_BNAME" >/dev/null 2>&1; then
      # 尝试目录级 wiki-link → dir/index.md 解析
      if grep -F -x "$miss/index" "$IDX_PATH" >/dev/null 2>&1; then
        :  # 目录级链接有效，跳过 E04
      else
        ERRORS+=("E04|$rel|wiki-link 无法解析: [[$miss]]")
      fi
    fi
  done <<< "$missing"
}


# ──────────────────────────────────────────────
# 主流程
# ──────────────────────────────────────────────

echo "========================================"
echo " 知识库内容治理 - 自动检查"
echo " 文件数: ${#ALL_FILES[@]}"
echo "========================================"
echo ""

echo "--- E01-E05 逐文件检查 ---"

for file in "${ALL_FILES[@]}"; do
  check_frontmatter "$file"
  check_line_count "$file"
  check_filename "$file"
  check_wikilinks "$file"
done

# ──────────────────────────────────────────────
# 输出
# ──────────────────────────────────────────────

echo ""
echo "========================================"
echo " 检查结果"
echo "========================================"

if [[ ${#ERRORS[@]} -eq 0 && ${#WARNINGS[@]} -eq 0 ]]; then
  echo " ✅ 全部通过，无问题"
  exit 0
fi

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo ""
  echo "--- 错误 (必须修复) ---"
  for e in "${ERRORS[@]}"; do
    IFS='|' read -r code file msg <<< "$e"
    echo "  [$code] $file"
    echo "         $msg"
  done
  EXIT_CODE=1
fi

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo ""
  echo "--- 警告 (建议修复) ---"
  for w in "${WARNINGS[@]}"; do
    IFS='|' read -r code file msg <<< "$w"
    echo "  [$code] $file"
    echo "         $msg"
  done
fi

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
  echo " ✅ 通过（仅有警告）"
else
  echo " ❌ 发现 ${#ERRORS[@]} 个错误，${#WARNINGS[@]} 个警告"
fi

exit $EXIT_CODE

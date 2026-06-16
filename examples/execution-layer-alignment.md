---
title: "Execution Layer Alignment Example"
date: "2026-06-16"
tags: [Memento, 示例, 执行层对齐, requires_provides, kb_refresh_policy]
category: "examples"
load: on-demand
status: active
synopsis: "公开版 KB→执行层闭环最小示例：展示 skill/cron 如何声明依赖 KB 规范、运行时加载策略和验收方法。"
version: 1
changelog: "initial"
---

# 执行层对齐示例

> 本示例展示如何让一个 skill（Agent 技能）声明它依赖哪些 KB 规范，以及在 KB 规则变更后如何验证旧规则不再运行。

## 背景

Memento README 承诺"改规则自动生效"。但要真的做到这一点，执行载体（skill、cron、脚本）需要：

1. **声明依赖** — 告诉 KB 它依赖哪些规范（`requires_provides`）
2. **运行时加载** — 每次执行读最新规范，不缓存旧版（`kb_refresh_policy: runtime`）
3. **可验收** — 规则变更后能确认执行载体不再按旧规则运行

## 最小 skill 声明

以下是一个虚构 skill `article-publisher` 的 SKILL.md 示例：

```yaml
---
name: article-publisher
description: 按 KB 写作规范发布文章
requires_provides:   # ← 声明依赖哪些 KB 规范
  - 写作流程通用规范
  - 质量检查通用标准
  - 合规通用红线
kb_refresh_policy: runtime  # ← 每次执行前读取最新 KB
---
```

关键字段：
- **`requires_provides`**：列出本 skill 依赖的 KB 规范对应的 `provides` 标签。KB 在验收时用 `python3 scripts/provides-search.py --synopsis <标签>` 确认规范是否存在。
- **`kb_refresh_policy: runtime`**：声明本 skill 在每次执行时重新读取 KB，不缓存过期版本。

## 最小 cron 声明

以下是一个虚构 cron 任务 `daily-digest` 的声明：

```yaml
job_name: "每日折扣发布"
schedule: "0 9 * * *"
requires_provides:
  - 发布流程
  - 图片治理规范
kb_refresh_policy: runtime
```

## 如何验收

当你修改了 KB 中某个规范后，Agent 应执行以下检查：

1. **检查入口一致性** — AGENTS.md、任务类型索引是否引用旧路径/旧规则名
2. **检查本地 skill/cron 声明** — 在 `~/.hermes/skills/*/` 和 `~/.hermes/cron/` 中搜索 `requires_provides`
3. **确认 `kb_refresh_policy`** — 依赖 KB 的执行载体必须声明 `kb_refresh_policy: runtime`
4. **旧词扫描** — 在本地脚本、prompt 中搜索被替换的旧规则名

详细协议见 [[规章制度/知识库管理/KB-执行层只读验收协议]]。

## 输出示例

```text
KB 规则变更只读验收报告
触发规则：写作流程通用规范 v3 → v4

1. KB 入口一致性 — PASS
2. skill/cron 依赖声明 — PASS (article-publisher, daily-digest 已声明 requires_provides + kb_refresh_policy)
3. 旧词扫描 — PASS (未发现旧规范名)
4. provides 命中 — PASS (写作流程通用规范, 质量检查通用标准 均存在)

综合结论：PASS
```

## 说明

- 本示例为教学用途，不包含真实 skill 代码或执行逻辑。
- 生产 skill 应放在 `~/.hermes/skills/` 下，不在 KB 仓库内。
- `requires_provides` 仅作声明标记，KB 不管理具体 skill 内容。

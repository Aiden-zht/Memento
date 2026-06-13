---
title: "Memento"
date: "2026-06-14"
tags: [知识库, Agent, README, Obsidian]
category: "索引"
load: index
status: active
synopsis: "Memento — AI 不会忘。AI-Native 知识底座 + Obsidian 即开即用。"
version: 9
changelog: "README 重构：整合 Obsidian 特性，精简架构"
---

# Memento

> AI 不会忘。

Memento 是一个**为 AI Agent 设计、人也能直接用的知识库**。它同时是一个完整的 [Obsidian](https://obsidian.md) Vault——用 Obsidian 打开就能浏览图谱、编辑笔记、管理知识。

---

## 双模使用

| 你用 | Agent 用 |
|------|---------|
| Obsidian 打开 → 图形化浏览知识图谱 | `AGENTS.md` → 冷启动入口 |
| 拖文章进 `inbox/` | 消化、归类、入索引 |
| 编辑 Markdown，wiki-link 自动关联 | `provides-search` 语义检索 |
| Graph View 看知识连接 | 读规范 → 建技能 → 自修复 |

所有文件都是标准 Markdown + YAML frontmatter。wiki-link（`[[...]]`）是 Obsidian 原生语法，也是 Agent 的导航语言。同一套文件，两个世界的工具都能完整使用。

---

## 你能得到什么

**不用管知识库。** 扔文章进 inbox，跟 AI 聊天建立规范，剩下的全自动——分类、格式化、索引、校验。你只负责说话和扔文件。

**不会阳奉阴违。** 跟 AI 说"发布前必须校验"——它真的会校验。BLOCKING 规则写在入口，pre-commit hook 拦在提交前，self-check 每次 commit 跑一遍。不是建议，是硬约束。

**换 Agent 不换脑子。** 换新模型、换新平台、换新机器——Agent 拿到这个仓库就能干活。技能自修复、规范自感知，不需要重新调教。

---

## 架构

```
memento/
├── AGENTS.md              ← Agent 冷启动入口
├── QUICKSTART.md           ← 人看这个就够了
├── inbox/                  ← 扔文章的地方
├── 规章制度/               ← Agent 必须遵守的规则
│   ├── Agent协作/          ← 多 Agent git 协作
│   ├── 知识库管理/         ← KB 自身治理（定位、格式、生命周期、回滚、inbox 消化）
│   └── Cron流水线运维规范/ ← 定时任务运维
├── 业务/                   ← 你的业务规范（按需创建）
├── 知识/                   ← 你的参考资料（Agent 自动归类）
└── scripts/                ← 工具链
    ├── self-check.sh       ← 8 维健康检查
    ├── lint-knowledge-base.sh ← 格式和链接检查
    ├── provides-search.py  ← 语义标签搜索
    └── pre-commit          ← git hook（lint + self-check）
```

**核心回路**：AGENTS.md → 任务类型索引 → 全文搜索/synopsis 筛选 → 规范正文 → 执行

---

## 特性

**🧭 零记忆接入** — 新 Agent 拿到仓库路径就能冷启动。实测：零上下文 Agent 跑通完整业务流水线。

**🔧 技能自举 + 自修复** — 规范通过 `requires_provides` 标签声明依赖。Agent 加载技能时自动读最新规范；规范改了，Agent 自主发现并修正过时引用。

**🛡️ 提交即检查** — 每次 `git commit` 自动触发 lint + self-check（违禁文件、废弃引用、索引完整性、目录深度、provides 漂移、入口断链）。违规直接拦截。

**📦 零门槛** — 人不需要懂目录结构。文章扔 `inbox/`，对 Agent 说"消化 inbox"。多主题自动拆分。

**🔮 Obsidian 原生** — 用 Obsidian 打开即用。wiki-link 双向链接、Graph View 知识图谱、YAML frontmatter 属性面板——全套 Obsidian 特性开箱即用。人用 Obsidian 浏览，Agent 用 git 协作，同一套文件，互不冲突。

**✅ 内置验收** — T1-T5 通用验收测试，测冷启动、工具发现、技能自举、自修复、多 Agent 隔离。

---

## 快速开始

见 [QUICKSTART.md](QUICKSTART.md) — 三件事：Fork → 扔文章 → 对 Agent 说话。

或者用 Obsidian：打开文件夹作为 Vault → 看到知识图谱 → 开始编辑。

---

## 工具链

| 工具 | 用途 |
|------|------|
| `self-check.sh` | 8 维健康检查，零 LLM token |
| `lint-knowledge-base.sh` | frontmatter、wikilink、version、文件名 |
| `audit-agent-usability.py` | 模板泄漏、草稿入口、占位双链 |
| `provides-search.py` | 语义标签辅助搜索 |
| `safe-commit.sh` | lint → add → commit → push |
| `install-hooks.sh` | 安装 pre-commit hook |

---

## 设计原则

1. **给 Agent 用，人也能读** — Markdown + Obsidian，不绑定任何平台
2. **任务入口优先** — 任务类型索引 + 全文搜索 > 目录导航
3. **简化优先** — 新增机制前先问：能减少 Agent 漏读/误读吗？
4. **BLOCKING 规则前置** — 硬性约束写在入口，Agent 不能跳过
5. **KB 是宪法，不是政府** — 只定义规则，不执行规则

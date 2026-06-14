---
title: "Memento"
date: "2026-06-14"
tags: [知识库, Agent, README, Obsidian]
category: "索引"
load: index
status: active
synopsis: "Memento — AI 不会忘。AI-Native 知识底座 + Obsidian 即开即用。"
version: 10
changelog: "[agent] 业务解耦更新：删除空业务/知识/目录，新增业务包通用设计，补充 LICENSE 和 CHANGELOG"
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

所有文件都是标准 Markdown + YAML frontmatter。wiki-link（`[[...]]`）是 Obsidian 原生语法，也是 Agent 的导航语言。

---

## 架构

```
memento/
├── AGENTS.md                     ← Agent 冷启动入口
├── QUICKSTART.md                 ← 人看这个就够了
├── inbox/                        ← 扔文章的地方
├── 规章制度/                     ← Agent 必须遵守的规则
│   ├── Agent协作/               ← 多 Agent git 协作
│   ├── 知识库管理/              ← KB 自身治理（定位、格式、生命周期、inbox 消化）
│   └── Cron流水线运维规范/      ← 定时任务运维
├── _templates/                   ← 通用模板
│   └── business-package/        ← 业务包骨架（Agent 创建业务时以此为模板）
└── scripts/                      ← 工具链
    ├── self-check.sh             ← 8 维健康检查
    ├── lint-knowledge-base.sh    ← 格式和链接检查
    ├── provides-search.py        ← 语义标签搜索
    └── pre-commit                ← git hook（lint + self-check）
```

> **业务和知识目录由 Agent 自动创建。** 你不需要手动建目录——对 Agent 说"创建写作业务"或"消化 inbox"，Agent 会按标准结构自动生成。

**核心回路**：AGENTS.md → 任务类型索引 → 全文搜索/synopsis 筛选 → 规范正文 → 执行

---

## 你能得到什么

**不用管知识库。** 扔文章进 inbox，跟 AI 聊天建立规范，剩下的全自动。

**不会阳奉阴违。** 跟 AI 说"发布前必须校验"——它真的会校验。BLOCKING 规则写在入口，pre-commit hook 拦在提交前。

**换 Agent 不换脑子。** 换新模型、换新平台——Agent 拿到这个仓库就能干活。技能自修复、规范自感知。

**业务无关。** 规范是通用的。具体业务（写作、开发、运维）由 Agent 按业务包标准自动创建，结构统一，Agent 自动识别。

---

## 特性

**🧭 零记忆接入** — 新 Agent 拿到仓库路径就能冷启动。

**📦 业务包通用设计** — 对 Agent 说"新建写作业务"，Agent 读模板 → 创建 `specs/` → 对话逐步完善规则。所有业务包结构统一，Agent 自动发现和加载。

**🔧 技能自举 + 自修复** — 规范通过标签声明依赖。Agent 加载技能时自动读最新规范；规范改了，Agent 自主发现并修正过时引用。

**🛡️ 提交即检查** — 每次 `git commit` 自动触发 lint + self-check。

**📦 零门槛** — 人不需要懂目录结构。文章扔 `inbox/`，对 Agent 说"消化 inbox"。

**🔮 Obsidian 原生** — 用 Obsidian 打开即用。wiki-link 双向链接、Graph View 知识图谱。

---

## 快速开始

见 [QUICKSTART.md](QUICKSTART.md) — Fork → 扔文章 → 对 Agent 说话。

---

## 工具链

| 工具 | 用途 |
|------|------|
| `self-check.sh` | 8 维健康检查，零 LLM token |
| `lint-knowledge-base.sh` | frontmatter、wikilink、version、文件名 |
| `provides-search.py` | 语义标签辅助搜索 |
| `safe-commit.sh` | lint → add → commit → push |
| `install-hooks.sh` | 安装 pre-commit hook |

---

## 设计原则

1. **给 Agent 用，人也能读** — Markdown + Obsidian
2. **任务入口优先** — 任务类型索引 + 全文搜索 > 目录导航
3. **简化优先** — 新增机制前先问：能减少 Agent 漏读/误读吗？
4. **BLOCKING 规则前置** — 硬性约束写在入口
5. **KB 是宪法，不是政府** — 只定义规则，不执行规则
6. **品牌无关** — 不绑定任何平台或产品

---

## 许可证

MIT License — 详见 [LICENSE](LICENSE)

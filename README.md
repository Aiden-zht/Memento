---
title: "Memento"
date: "2026-06-14"
tags: [知识库, Agent, README, 设计理念]
category: "索引"
load: index
status: active
synopsis: "Memento 知识库首页：AI-Native 知识底座 + Obsidian 即开即用，让任何 Agent 零记忆接入，自主读规范、建技能、修错误、验产出。"
version: 10
changelog: "[Agent自修] 圆桌审计后降级 README 为人类入口，补齐七类正式目录与 Agent 权威链"
---

# Memento

> AI 不会忘。

---

## 这是什么

Memento 不是文档仓库。它是一个**自描述、自修复、自验收**的 AI 知识底座。

把文章扔进来，Agent 先评审再消化归类。改了规范，依赖它的技能自动感知更新。新 Agent 拿到仓库路径，不需要任何上下文就能跑通完整任务。

```
人 → inbox/（扔文章）        Agent → 评审 → 消化 → 归类 → 入索引
人 → 对话建立规范             Agent → 写 frontmatter → lint → commit
人 → 改规范                   Agent → 感知变更 → 自修 skill
新 Agent → git clone          Agent → AGENTS.md → 索引 → 规范 → 执行
```

---

## 你能得到什么

**不用管知识库。** 扔文章进 inbox，跟 AI 聊天建立规范，Agent 会先评审是否值得长期入库，再自动分类、格式化、索引、校验。你只负责说话和扔文件。

**不会阳奉阴违。** 跟 AI 说"发布前必须校验"——它真的会校验。BLOCKING 规则写在入口，pre-commit hook 拦在提交前，self-check 每次 commit 跑一遍。不是建议，是硬约束。

**换 Agent 不换脑子。** 换新模型、换新平台、换新机器——Agent 拿到这个仓库就能干活。技能自修复、规范自感知，不需要重新调教。

**业务无关。** Memento 只管规范和通用知识。内容发布、数据处理——那些是业务项目 `项目知识/` 的事。Memento 定义项目任务知识标准，各项目按标准创建，Agent 自动识别。

---

## 架构

```
agent_mem/
├── AGENTS.md                          ← Agent 冷启动入口
├── inbox/                             ← 人的投递口（扔文章就行）
├── 规章制度/                          ← Agent 必须遵守的规则
│   ├── Agent协作/                    ← 多 Agent git 协作规范
│   ├── 知识库管理/                   ← KB 自身治理（定位、格式、生命周期、回滚）
│   └── Cron流水线运维规范/           ← 定时任务运维
├── 产物规范/                          ← 各类产物的制作与验收标准
├── 专业知识/                          ← 领域/技术/行业判断参考，非规则源
├── 素材库/                            ← 案例、故事、金句、片段、失败案例
├── 项目知识/                          ← 私有项目长期事实、契约、测试策略
├── 用户资料/                          ← 用户投喂后消化的来源层资料
├── _templates/                        ← 结构模板，非规则源
├── scripts/                           ← 维护工具，非知识权威源
│   ├── self-check.sh                 ← 8 维健康检查
│   ├── lint-knowledge-base.sh        ← 格式和链接检查
│   ├── provides-search.py            ← 语义标签搜索
│   └── pre-commit                    ← git hook（lint + self-check）
└── .gitignore                        ← 违禁文件网关
```

**Agent 权威链**：AGENTS.md → 任务能力索引 → 任务类型索引 → index/synopsis → 按需正文 → 执行。README 只是人类介绍和 Quickstart，不承载规则权威。

**业务解耦**：业务规则由各项目 `项目知识/` 独立维护，通过 [[规章制度/知识库管理/知识库内容治理规范/12-项目任务知识接入设计]] 的标准结构接入。Agent 执行任务时自动检查项目 `项目知识/` 目录并加载。

---

## 特性

### 🧭 零记忆接入
新 Agent 只知道仓库路径，就能通过 `AGENTS.md` → `任务类型索引` → 规范 完成冷启动。实测：零上下文 Agent 跑通完整业务流水线。

### 📦 项目任务知识接入设计
Memento 定义项目任务知识标准结构（`项目知识/`），但不存放任何业务内容。用户说"新建写作业务"，Agent 读模板 → 创建 项目知识/ → 对话逐步完善规则。见 `12-项目任务知识接入设计`。

### 🔧 技能自举
KB 规范通过 `requires_provides` 标签声明依赖。Agent 加载技能时自动 `git pull` → `provides-search` → 读最新规范，不需要人手动同步。

### 🩹 技能自修复
规范改了，Agent 能自主发现技能中的过时引用并修正。已通过验收测试验证。

### 🛡️ 提交即检查
每次 `git commit` 自动触发 lint + self-check（8 维度：违禁文件、废弃引用、索引完整性、目录深度、入口断链……）。违规直接拦截。

### 📦 零门槛使用
人不需要懂目录结构。文章扔进 `inbox/`，对 Agent 说"消化 inbox"。Agent 先评审价值和质量，再按需补格式、入索引。

### ✅ 内置验收
`09-新Agent初始化` 包含通用验收测试，测冷启动、工具发现、技能自举、自修复、多 Agent 隔离。

### 🔄 回滚 SOP
改错了？`06-文件生命周期` §6.7 有完整回滚流程：时机判断 → `git revert` → 连带检查（入链/索引/provides/下游通知）。

### 📐 职责边界清晰
`01-知识库定位` 明确：KB 是宪法，不是政府。不管 skill 备份、cron 调度、影响分析、通知告警——那些是 Agent 运行时的事。

---

## 快速开始

### 给人

```bash
# 1. git clone https://gitee.com/aidenzht/agent_mem.git
# 2. 把文章扔进 inbox/
# 3. 对 Agent 说：消化 inbox
# 4. 通过对话建立规范，Agent 自己整理
```

### 给 Agent

```bash
cd /path/to/agent_mem
git pull origin master
```

然后读 `AGENTS.md`，它指向任务能力索引和任务类型索引，剩下的自动走。

### 验收测试

```bash
# 结构健康（30秒）
bash scripts/self-check.sh

# 格式审计
bash scripts/lint-knowledge-base.sh
python3 scripts/audit-agent-usability.py
```

---

## 工具链

| 工具 | 用途 |
|------|------|
| `self-check.sh` | 8 维健康检查，零 LLM token |
| `lint-knowledge-base.sh` | frontmatter、wikilink、version、文件名 |
| `audit-agent-usability.py` | 模板泄漏、草稿入口、占位双链 |
| `provides-search.py` | 语义标签辅助搜索 |
| `safe-commit.sh` | lint → add → commit → push，自动加 Agent 标识 |
| `install-hooks.sh` | 安装 pre-commit hook |
| `pre-commit` | 每次 commit 自动 lint + self-check |

---

## 设计原则

1. **给 Agent 用，不是给人浏览** — 文档优先服务检索和执行
2. **任务入口优先** — 任务能力索引 + 任务类型索引 + 全文搜索 > 目录导航
3. **用 Agent 原生能力** — 不造受控词表、不建集中式 manifest
4. **简化优先** — 新增机制前先问：能减少 Agent 漏读/误读吗？
5. **BLOCKING 规则前置** — 硬性约束写在入口，Agent 不能跳过
6. **KB 是宪法，不是政府** — 只定义规则，不执行规则
7. **品牌无关** — 不出现任何平台或产品特定名称

---

## 许可证

MIT License — 详见 [[LICENSE]]

---

## 目录

- [[AGENTS]]
- [[index]]
- [[规章制度/知识库管理/任务类型索引]]
- [[规章制度/知识库管理/知识库内容治理规范/index]]
- [[规章制度/知识库管理/知识库内容治理规范/12-项目任务知识接入设计]]

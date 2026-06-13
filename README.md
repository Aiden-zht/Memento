---
title: "Memento"
date: "2026-06-14"
tags: [知识库, Agent, README, 设计理念]
category: "索引"
load: index
status: active
synopsis: "Memento 知识库首页：AI-Native 知识底座，让任何 Agent 零记忆接入，自主读规范、建技能、修错误、验产出。"
version: 8
changelog: "[Agent自修] 项目更名：Agent Mem → Memento"
---

# Memento

> AI 不会忘。

---

## 这是什么

Memento 不是文档仓库。它是一个**自描述、自修复、自验收**的 AI 知识底座。

把文章扔进来，Agent 自己消化归类。改了规范，依赖它的技能自动感知更新。新 Agent 拿到仓库路径，不需要任何上下文就能跑通完整任务。

```
人 → inbox/（扔文章）        Agent → 消化 → 归类 → 入索引
人 → 对话建立规范             Agent → 写 frontmatter → lint → commit
人 → 改规范                   Agent → 感知变更 → 自修 skill
新 Agent → git clone          Agent → AGENTS.md → 索引 → 规范 → 执行
```

---

## 你能得到什么

**不用管知识库。** 扔文章进 inbox，跟 AI 聊天建立规范，剩下的全自动——分类、格式化、索引、校验。你只负责说话和扔文件。

**不会阳奉阴违。** 跟 AI 说"发布前必须校验"——它真的会校验。BLOCKING 规则写在入口，pre-commit hook 拦在提交前，self-check 每次 commit 跑一遍。不是建议，是硬约束。

**换 Agent 不换脑子。** 换新模型、换新平台、换新机器——Agent 拿到这个仓库就能干活。技能自修复、规范自感知，不需要重新调教。

---

## 架构

```
memento/
+-- AGENTS.md                 ← Agent 冷启动入口
+-- inbox/                    ← 人的投递口（扔文章就行）
+-- 规章制度/                  ← Agent 必须遵守的规则
|   +-- Agent协作/            ← 多 Agent git 协作规范
|   +-- 知识库管理/            ← KB 自身治理（定位、格式、生命周期、回滚）
|   +-- Cron流水线运维规范/   ← 定时任务运维
+-- 业务/                     ← 业务规范和工作流
|   +-- 写作/                 ← 公众号、博客、小红书等平台
+-- 知识/                     ← 可复用参考资料
+-- scripts/                  ← 工具链（零 token 消耗）
|   +-- self-check.sh         ← 8 维健康检查
|   +-- lint-knowledge-base.sh← 格式和链接检查
|   +-- provides-search.py    ← 语义标签搜索
|   +-- pre-commit            ← git hook（lint + self-check）
+-- .gitignore                ← 违禁文件网关
```

**核心回路**：AGENTS.md → 任务类型索引 → 全文搜索/synopsis 筛选 → 规范正文 → 执行

---

## 特性

### 🧭 零记忆接入
新 Agent 只知道仓库路径，就能通过 `AGENTS.md` → `任务类型索引` → 规范 完成冷启动。实测：零上下文 Agent 跑通完整业务流水线。

### 🔧 技能自举
KB 规范通过 `requires_provides` 标签声明依赖。Agent 加载技能时自动 `git pull` → `provides-search` → 读最新规范，不需要人手动同步。

### 🩹 技能自修复
规范改了，Agent 能自主发现技能中的过时引用并修正。已通过 T4 验收测试验证。

### 🛡️ 提交即检查
每次 `git commit` 自动触发 lint + self-check（8 维度：违禁文件、废弃引用、索引完整性、目录深度、provides 漂移、入口断链……）。违规直接拦截。

### 📦 零门槛使用
人不需要懂目录结构。文章扔进 `inbox/`，对 Agent 说"消化 inbox"。通过对话建立规范，Agent 自己补格式、入索引。

### ✅ 内置验收
`09-新Agent初始化` 包含 T1-T5 通用验收测试，测冷启动、工具发现、技能自举、自修复、多 Agent 隔离。5/5 通过 = KB 可用。

### 🔄 回滚 SOP
改错了？`06-文件生命周期` §6.7 有完整回滚流程：时机判断 → `git revert` → 连带检查（入链/索引/provides/下游通知）。

### 📐 职责边界清晰
`01-知识库定位` 明确：KB 是宪法，不是政府。不管 skill 备份、cron 调度、影响分析、通知告警——那些是 Agent 运行时的事。

---

## 快速开始

### 给人

```bash
# 1. 把文章扔进 inbox/
# 2. 对 Agent 说：消化 inbox
# 3. 通过对话建立规范，Agent 自己整理
```

### 给 Agent

```bash
cd /path/to/memento
git pull origin master
```

然后读 `AGENTS.md`，它指向 `任务类型索引`，剩下的自动走。

### 验收测试

```bash
# 结构健康（30秒）
bash scripts/self-check.sh

# 格式审计
bash scripts/lint-knowledge-base.sh
python3 scripts/audit-agent-usability.py

# 功能验证：发 T1-T5 prompt 给零上下文 Agent（见 09-新Agent初始化#第七步）
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
2. **任务入口优先** — 任务类型索引 + 全文搜索 > 目录导航
3. **用 Agent 原生能力** — 不造受控词表、不建集中式 manifest
4. **简化优先** — 新增机制前先问：能减少 Agent 漏读/误读吗？
5. **BLOCKING 规则前置** — 硬性约束写在入口，Agent 不能跳过
6. **KB 是宪法，不是政府** — 只定义规则，不执行规则

---

## 目录

- [[AGENTS]]
- [[index]]
- [[规章制度/知识库管理/任务类型索引]]
- [[规章制度/知识库管理/知识库内容治理规范/index]]

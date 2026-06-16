---
title: "多Agent知识库协作规范"
date: "2026-06-15"
tags: [协作, git, 多Agent, 知识库]
category: "规章制度/Agent协作"
load: on-demand
audience: [all]
provides: [多Agent协作, git协作规范, 冲突处理, Agent标识]
status: active
synopsis: "多 Agent 共享 Memento 时的通用协作规范：启动先同步、修改前检查状态、提交标识、冲突处理、按需加载，避免并行覆盖。"
version: 11
changelog: "[Agent自修] 通用化协作规范，剥离平台/项目/业务示例并统一 no-rebase 策略"
versions:
  多Agent协作: 9
  git协作规范: 5
  session启动检查: 5
  commit规范: 5
  冲突处理: 5
---

# 多 Agent 知识库协作规范

> 适用范围：多个 Agent、多个会话或人机共同维护同一个 Git 知识库时使用。本文只规定协作纪律，不规定具体业务分工。

## 1. 核心原则

1. 知识库以 Git 远端为共享事实源；修改前先同步，修改后必须提交并推送。
2. commit message 是 Agent 之间的变更通知；必须写清谁改了什么、为什么改。
3. 冲突时先理解对方提交意图，再合并；不要用本地记忆覆盖远端新规则。
4. “必须遵守”不等于“每次全文加载”；普通任务从任务入口开始，涉及协作、写库、冲突时再加载本文正文。

## 2. Session 启动检查

每个 Agent 在操作知识库前执行：

```bash
cd <memento-repo>
git pull --no-rebase origin <default-branch>
git status --short
git log --oneline -5
```

如果仓库维护了 `.last_seen_commit`，可用它查看其他 Agent 自上次以来的变更；该文件只是本地辅助状态，不是知识内容。

## 3. 知识库加载策略

默认冷启动入口：

```text
AGENTS.md → 任务类型索引 → index/synopsis → 按需正文
```

加载规则：

| 场景 | 加载 |
|------|------|
| 普通任务 | 任务类型索引 + 任务相关规范 |
| 写入/修改 KB | 知识库治理规范 + 本文 |
| 多 Agent 并行或冲突 | 本文 + 相关文件 diff/log |
| 新 Agent 初始化 | 新 Agent 初始化规范 + 本文 |

不要把整个 `规章制度/` 当作每次必读全文；按任务需要加载正文即可。

## 4. Commit Message 规范

推荐格式：

```text
[agent:<标识>] <动作和目的> — <关键文件或范围>
```

示例：

```bash
git commit -m "[agent:reviewer] 修复目录索引断链 — 规章制度/index.md"
```

要求：

1. 标识稳定，能区分不同 Agent / profile / 人工维护者。
2. 描述使用结果导向，不写“更新一下”这类无信息文本。
3. 涉及规范裁定时，说明裁定对象；涉及大范围迁移时，说明范围。

## 5. 冲突处理

当 push 被拒绝或 pull 后出现冲突：

```bash
git pull --no-rebase origin <default-branch>
git status --short
git log --oneline -5
```

处理原则：

1. 先读对方最新 commit 和冲突段上下文，再编辑。
2. 优先向前合并，保留双方有效规则；不要为了线性历史强行 rebase。
3. 冲突解决后运行知识库验证，再 commit + push。
4. 如果冲突涉及治理裁定、入口权威链或目录模型，必要时追加治理复盘。

## 6. 长编辑协作

如果某个 Agent 会长时间编辑同一批文件，先提交一个小的意图性 commit 或在当前协作渠道说明范围：

```text
[agent:<标识>] 开始整理 <范围>，预计影响 <文件/目录>
```

其他 Agent 看到后应避免同时修改同一范围；完成后提交最终变更并说明结果。

## 7. 与业务流水线的边界

本文只管“多个 Agent 如何共用知识库和 Git”。具体业务中的审核者、发布者、评分者等角色分工，属于对应的产物规范或项目知识，不写入本文。

## 8. 相关文档

- [[规章制度/知识库管理/知识库内容治理规范/index]] — 知识库内容边界和文件规范
- [[规章制度/知识库管理/任务类型索引]] — 任务路由入口
- [[index]] — 知识库目录入口

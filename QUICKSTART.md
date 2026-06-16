---
title: "Memento Quickstart"
date: "2026-06-15"
tags: [memento, quickstart, guide]
category: "索引"
load: index
status: active
synopsis: "5 分钟上手：克隆 → 安装 hook → 对 Agent 说'消化 inbox'"
version: 2
changelog: "fix: convert literal \\n to actual newlines"
---

# Memento Quickstart

> 你不需要懂 git、linux 或目录结构。一切通过对话完成。

## 前置条件

- 一个能访问本地文件系统的 AI Agent（如 Hermes、Claude Code、Codex CLI 等）
- 能跑 bash 和 Python 的环境（Windows 可用 WSL 或 Git Bash）

## 快速上手

### 第一步：拿到知识库

```bash
git clone https://github.com/Aiden-zht/Memento.git
cd Memento
bash scripts/install-hooks.sh
```

### 第二步：告诉 Agent

对你的 Agent 说：

> 接入 `/path/to/Memento` 知识库，读 `AGENTS.md` 开始工作。

### 第三步：开始使用

| 你想做什么 | 对 Agent 说 |
|-----------|-------------|
| 把文章加入知识库 | "消化 inbox"（先把文章放进 `inbox/` 文件夹） |
| 加个规则 | "以后发布前必须做校验" |
| 改规则 | "把折扣门槛从 10% 改成 15%" |
| 检查知识库状态 | "检查知识库健康" |
| 换新 Agent | "接入 Memento 知识库"（给路径就行） |

> Agent 会自动读规范、按规则执行、改完后验证提交。人不需要手动操作 git。

## 健康检查

任何时候对 Agent 说 "检查知识库健康"，Agent 会跑完整的结构、格式和可用性检查。

## 更多

- [[AGENTS]] — Agent 冷启动入口
- [[README]] — 完整介绍和设计理念
- [[规章制度/知识库管理/任务类型索引]] — Agent 执行的任务路由
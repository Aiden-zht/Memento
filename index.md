---
title: "Memento 索引"
date: "2026-06-15"
tags: [索引, 知识库, Memento]
category: "索引"
load: index
audience: [all]
provides: [知识库索引, 导航目录]
status: active
synopsis: "Memento 总入口：指向 AGENTS、Quickstart、FAQ、贡献说明、公开示例、任务索引、知识库治理和规章制度。Agent 冷启动后的导航页。"
version: 12
changelog: "[agent] 开源版清理：统一公开入口并移除私有知识域索引"
versions:
  知识库索引: 8
  导航目录: 3
---

# Memento 索引

> Git: https://github.com/Aiden-zht/Memento.git
> **冷启动入口**：[[AGENTS]]
> **快速开始**：[[QUICKSTART]]
> **常见问题**：[[FAQ]]
> **贡献说明**：[[CONTRIBUTING]]
> **公开示例**：[[examples/index]]

---

## 入口

| 文件 | 用途 |
|------|------|
| [[AGENTS]] | Agent 冷启动入口 |
| [[README]] | 项目介绍 |
| [[QUICKSTART]] | 人和 Agent 的最短上手流程 |
- [[FAQ]] — 面向使用者的常见问题
| [[CONTRIBUTING]] | 贡献规则与 PR 前检查 |
| [[examples/index]] | 公开脱敏示例 |

## 规章制度

| 目录 | 用途 |
|------|------|
| [[规章制度/index]] | 规章制度总索引 |
| [[规章制度/知识库管理/index]] | Memento 自身治理 |
| [[规章制度/知识库管理/任务类型索引]] | 任务类型到规范的路由入口 |
| [[规章制度/知识库管理/知识库内容治理规范/index]] | 内容边界、文件规范、生命周期、业务包设计 |
| [[规章制度/Agent协作/index]] | 多 Agent git 协作规范 |
| [[规章制度/Cron流水线运维规范/index]] | 定时流水线通用运维规范 |

## 业务包

Memento 核心仓库不保存具体业务规则。具体业务在项目自己的 `specs/` 中维护。

业务包标准见：[[规章制度/知识库管理/知识库内容治理规范/12-业务包通用设计]]

最小示例见：[[examples/minimal-business-specs/index]]

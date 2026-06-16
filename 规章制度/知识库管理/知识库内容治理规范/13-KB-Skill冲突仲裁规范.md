---
title: "KB-Skill 冲突仲裁规范"
date: "2026-06-16"
tags: [知识库, 治理, 规范, Skill, 冲突仲裁]
category: "规章制度/知识库管理/知识库内容治理规范"
load: on-demand
audience: [all]
provides: [KB-Skill冲突仲裁]
status: active
synopsis: "KB 规范与 Skill 规范的冲突仲裁原则：KB 高于 skill；skill 首次进入执行路径前必须检查 KB 冲突；hash 变化使旧结论失效；cron/离线任务不得等待人工仲裁。"
version: 1
changelog: "[圆桌落地] 依据 2026-06-16 governance roundtable 裁定创建"
versions:
  KB-Skill冲突仲裁: 1
---

# KB-Skill 冲突仲裁规范

> 本规范定义 KB（Memento 知识库）与 Hermes Agent skill 之间发生规范冲突时的仲裁原则和行为规定。

## 原则

1. **KB 高于 skill。** 当 KB 规范与 skill 指令发生实质性冲突（不可同时遵守）时，KB 规范优先。Agent 不得执行违反 KB 约束的 skill 指令。

2. **首次执行前检查。** 每个 skill（无论自建或外部安装）在首次进入执行路径前，Agent 必须自动检查其内容是否与 KB 核心约束存在冲突，并向用户报告。

3. **哈希检测失效。** KB 规范变更（内容 hash 变化）或 skill 内容更新后，已有的冲突扫描结论视为失效，必须在下次执行前重新扫描。

4. **离线任务守则。** Cron/背景/离线任务执行中遇到未裁定的 KB-skill 冲突，不得暂停等待人工仲裁。必须按以下默认值执行：
   - 遵循 KB 规范、跳过冲突 skill 指令
   - 或在冲突不可回避时标记 `BLOCKED` 并输出错误报告
   - 以本次执行失败/降级为代价，不得静默继续

## Agent 执行要求

- 交互式任务中首次检测到冲突，Agent 应向用户报告冲突双方原文，由用户裁定（改 KB / 改 skill / 挂白名单 / 忽略）。
- 用户裁定结果记入执行层缓存（fact_store 等），不作为 KB 法规正文。
- 白名单 / 忽略等例外仅在当前 skill + 当前 KB 版本下有效；KB 或 skill 更新后失效，须重新裁定。

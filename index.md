---
title: "Memento 索引"
date: "2026-06-14"
tags: [索引]
category: "索引"
load: index
audience: [all]
provides: [知识库索引]
status: active
synopsis: "Memento 总入口：指向 AGENTS、任务索引、知识库治理、业务包通用设计，是 Agent 冷启动后的导航页。"
version: 2
changelog: "[agent] 业务解耦：删除空业务/知识目录引用，新增业务包通用设计入口"
---

# Memento 索引

> **冷启动入口**：[[AGENTS]]
> **内容治理**：[[规章制度/知识库管理/知识库内容治理规范/index]]
> **Agent 协作**：[[规章制度/Agent协作/多Agent知识库协作规范]]
> **业务包通用设计**：[[规章制度/知识库管理/知识库内容治理规范/12-业务包通用设计]]

---

## 规章制度

Agent 必须遵守的规则。按任务按需加载。

| 规范 | 说明 |
|------|------|
| [[规章制度/Agent协作/多Agent知识库协作规范]] | git 协作、commit 格式、冲突处理 |
| [[规章制度/知识库管理/知识库内容治理规范/index]] | KB 宪法：定位、格式、生命周期、inbox 消化 |
| [[规章制度/知识库管理/任务类型索引]] | 任务 → 规范映射，Agent 任务分发入口 |
| [[规章制度/知识库管理/知识库内容治理规范/12-业务包通用设计]] | 业务包标准结构和 Agent 创建流程 |

---

## 创建业务

对 Agent 说"新建写作业务"，Agent 按 `12-业务包通用设计` 在项目目录创建 `specs/`。不需要在本仓库手动建目录。

---

## 维护

```bash
# 每次操作前
git pull origin main

# 健康检查
bash scripts/self-check.sh

# 提交
bash scripts/safe-commit.sh "描述"
```

---
title: "Memento 索引"
date: "2026-06-14"
tags: [索引]
category: "索引"
load: index
audience: [all]
provides: [知识库索引]
status: active
synopsis: "Memento 总入口：指向 AGENTS、任务索引、知识库治理、业务域和知识域，是 Agent 冷启动后的导航页。"
version: 1
changelog: "public release"
---

# Memento 索引

> **冷启动入口**：[[AGENTS]]
> **内容治理**：[[规章制度/知识库管理/知识库内容治理规范/index]]
> **Agent 协作**：[[规章制度/Agent协作/多Agent知识库协作规范]]

---

## 规章制度

Agent 必须遵守的规则。按任务按需加载。

| 规范 | 说明 |
|------|------|
| [[规章制度/Agent协作/多Agent知识库协作规范]] | git 协作、commit 格式、冲突处理 |
| [[规章制度/知识库管理/知识库内容治理规范/index]] | KB 宪法：定位、格式、生命周期、回滚、inbox 消化 |
| [[规章制度/知识库管理/任务类型索引]] | 任务 → 规范映射，Agent 任务分发入口 |

---

## 业务

你的业务规范放这里。按 `业务/{领域}/{平台}/` 组织。

```
业务/
+-- 你的领域/
    +-- 创作规范/
    +-- 项目文档/
```

---

## 知识

你的参考资料放这里。扔进 inbox/ 让 Agent 自己归类也行。

```
知识/
+-- 你的主题/
```

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

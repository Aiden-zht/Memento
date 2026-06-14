---
title: "业务包骨架模板"
date: "2026-06-14"
tags: [模板, 业务包, specs]
category: "_templates/business-package"
load: template
audience: [agent]
provides: [业务包模板]
status: scaffold
synopsis: "业务包 index.md 骨架模板：用于 Agent 在项目 specs/ 下创建独立业务包入口。"
version: 1
changelog: "[Agent自修] 补齐模板 frontmatter，满足 Agent 可用性审计"
business: ""
domain: []
description: ""
depends_on: []
kb_refresh_policy: runtime
created: ""
---

# 业务名称

业务描述。

## 任务类型

<!-- 列出本业务包支持的任务类型 -->

## 依赖的 Memento 规范

<!-- 从 depends_on 标签展开，列出依赖的规范文件 -->

## 目录

- `rules/` — 业务规则（流程、质量、合规）
- `references/` — 技术参考（API 手册、模板、风格参考）

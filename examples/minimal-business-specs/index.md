---
title: "示例业务规格入口"
date: "2026-06-15"
tags: [业务包, 示例, specs]
category: "specs"
load: index
status: active
synopsis: "最小业务包入口示例：声明业务范围、依赖的 Memento 通用规范、运行时刷新策略和本业务文件结构。"
version: 2
changelog: "[agent] 移除面向人的脚本命令块，简化为 Agent 操作描述"
depends_on: [业务包通用设计, Agent行为约束, 文件规范]
kb_refresh_policy: runtime
business_scope: "示例内容处理业务，仅用于展示 specs 结构。"
---

# 示例业务规格入口

## 业务边界

本业务包只描述当前项目自己的业务规则，不修改 Memento 核心规范。

示例任务：

- 整理用户投递的内容材料
- 按本项目的质量规则生成输出
- 在发布前运行最小校验

## 依赖的 Memento 通用规范

执行前读取 Memento 中这些通用规范：

- `业务包通用设计`
- `Agent行为约束`
- `文件规范`

执行时用 provides-search 定位这些规范，标签未命中时全文搜索兜底。

## 本业务文件结构

```text
specs/
├── index.md
├── rules/
│   └── content-quality.md
└── references/
    └── platform-api-notes.md
```

## 最低验证

Agent 完成本业务任务前，应确认：

1. 已读取本文件。
2. 已加载 `depends_on` 对应的 Memento 通用规范。
3. 已读取 `rules/content-quality.md`。
4. 没有把业务规则写回 Memento 核心仓库。

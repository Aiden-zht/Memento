---
title: "最小业务包示例"
date: "2026-06-15"
tags: [Memento, 示例, 业务包]
category: "examples"
load: template
status: active
synopsis: "公开版最小业务包示例：展示项目 specs/index.md 如何声明业务边界、依赖的 Memento 规范、运行时刷新策略和验证方式。"
version: 1
changelog: "initial public example"
---

# 最小业务包示例

这个目录演示一个具体项目如何接入 Memento。

Memento 核心仓库只定义通用治理规则。具体业务规则放在项目自己的 `specs/` 目录中。

```text
your-project/
└── specs/
    ├── index.md
    ├── rules/
    │   └── content-quality.md
    └── references/
        └── platform-api-notes.md
```

## 使用方式

1. 复制本目录到你的项目：

```bash
cp -R examples/minimal-business-specs /path/to/your-project/specs
```

2. 按你的业务改写 `specs/index.md`。
3. 让 Agent 执行业务任务前先读项目的 `specs/index.md`。
4. Agent 根据 `depends_on` 回到 Memento 加载通用规范。

## 关键字段

- `depends_on`：本业务依赖的 Memento 通用规范标签。
- `kb_refresh_policy: runtime`：每次执行前读取最新 Memento，不复制规则正文。
- `business_scope`：声明业务边界，避免把业务内容写回 Memento 核心仓库。

---
title: "最小业务包示例"
date: "2026-06-15"
tags: [Memento, 示例, 业务包]
category: "examples"
load: template
status: active
synopsis: "公开版最小业务包示例：展示项目 specs/index.md 如何声明业务边界、依赖的 Memento 规范、运行时刷新策略和验证方式。"
version: 3
changelog: "[agent] 贯彻人只对话不操作的思路：使用方式统一为对 Agent 说话"
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

对你的 Agent 说：

```text
帮我创建一个新的业务包，结构参考 examples/minimal-business-specs。
```

Agent 会根据 `_templates/business-package/` 创建 `specs/` 结构，并按你的业务改写 `specs/index.md`。业务包创建后，Agent 自动通过 `depends_on` 回到 Memento 加载通用规范。

## 关键字段

- `depends_on`：本业务依赖的 Memento 通用规范标签。
- `kb_refresh_policy: runtime`：每次执行前读取最新 Memento，不复制规则正文。
- `business_scope`：声明业务边界，避免把业务内容写回 Memento 核心仓库。
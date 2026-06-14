---
title: "Agent 首次运行示例"
date: "2026-06-15"
tags: [Memento, 示例, Agent初始化]
category: "examples"
load: on-demand
status: active
synopsis: "公开版 Agent 首次运行示例：展示新 Agent clone Memento 后如何读入口、跑检查、定位规范和加载最小业务包。"
version: 1
changelog: "initial public example"
---

# Agent 首次运行示例

把下面这段发给一个新 Agent：

```text
你只知道一个知识库路径：/path/to/memento。
请按以下步骤完成首次接入：
1. 读取 AGENTS.md。
2. 读取 规章制度/知识库管理/任务类型索引.md。
3. 运行 bash scripts/self-check.sh。
4. 运行 bash scripts/lint-knowledge-base.sh。
5. 用 python3 scripts/provides-search.py --synopsis 业务包通用设计 Agent行为约束 查找相关规范。
6. 读取 examples/minimal-business-specs/index.md，说明一个项目如何接入业务包。
7. 输出 PASS/FAIL 和原因，不要修改文件。
```

预期结果：

- Agent 能找到入口文件。
- self-check 能运行。
- lint 能运行。
- provides-search 能返回相关规范。
- Agent 能说明业务规则应放在项目 `specs/`，不是 Memento 核心仓库。

---
title: "Agent 首次运行示例"
date: "2026-06-15"
tags: [Memento, 示例, Agent初始化]
category: "examples"
load: on-demand
status: active
synopsis: "公开版 Agent 验收示例：发给新 Agent 的标准验收 prompt，验证其能完成冷启动全流程。"
version: 2
changelog: "[agent] 面向使用者的提示全部移除，只保留发给 Agent 的验收命令"
---

# Agent 首次运行示例

这是一个验收测试——发给你自己的 Agent，验证它能否完成 Memento 冷启动。

发给 Agent：

```text
你只知道一个知识库路径：/path/to/memento。
请按以下步骤完成首次接入：
1. 读取 AGENTS.md。
2. 读取 规章制度/知识库管理/任务类型索引.md。
3. 运行 bash scripts/self-check.sh。
4. 运行 bash scripts/lint-knowledge-base.sh。
5. 用 python3 scripts/provides-search.py --synopsis 业务包通用设计 Agent行为约束 查找相关规范。
6. 读取 examples/index.md，浏览现有示例文件。说明它们的作用和是否能作为生产规范。
7. 输出 PASS/FAIL 和原因，不要修改文件。
```

预期结果：

- Agent 能找到入口文件。
- self-check 能运行。
- lint 能运行。
- provides-search 能返回相关规范。
- Agent 能找到入口文件，按职责读取规范。

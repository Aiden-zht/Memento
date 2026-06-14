# Changelog

本文件只记录面向用户的重大变更。详细提交历史见 `git log`。

## 2026-06-14 — 业务解耦（v2）

- **BREAKING**：`业务/` 和 `知识/` 空目录移除。业务内容由 Agent 按业务包标准自动创建。
- **新增**：`12-业务包通用设计` — 定义独立业务包标准结构和 Agent 创建流程。
- **新增**：`_templates/business-package/` — 业务包骨架模板。
- **新增**：`LICENSE`（MIT）、`CHANGELOG.md`。
- **修改**：README、AGENTS.md、index.md、QUICKSTART.md 适配业务解耦。

## 2026-06-14 — 首次公开

- 项目更名为 Memento（拉丁语"记住"）。标语："AI 不会忘。"
- 首个公开版本：治理规范 00-11、工具链、冷启动入口、Obsidian 双模支持。
- GitHub 仓库：[Aiden-zht/memento](https://github.com/Aiden-zht/memento)

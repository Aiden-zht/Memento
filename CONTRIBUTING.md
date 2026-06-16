# Contributing to Memento

Memento 是 Agent 执行的知识库框架。贡献应让新使用者和新 Agent 更容易 clone、验证和使用。

## 贡献什么

适合放入：

- `规章制度/` 下的治理规则
- `AGENTS.md`、`README.md`、`QUICKSTART.md` 的入口改进
- `scripts/` 下的验证脚本
- `_templates/` 下的通用模板
- `examples/` 下的公开脱敏示例
- 本文档本身

不适合放入：

- 私有业务内容
- 真实生成产物
- JSON 日志、缓存、评分、会话追踪等运行时状态文件
- 二进制资源（除非是有意记录的示例）
- 密钥、token、本地 IP、私有路径、供应商或帐号特定内容

## 修改前

告诉你的 Agent：

```text
我要改 Memento 的 X 规则/脚本/模板。先按 AGENTS.md 和规范检查我的改动是否合规，再帮我验证。
```

Agent 会自己读取相关规范、跑检查、确认无误后提交。

## Markdown 文件要求

每份托管 Markdown 文件必须有 YAML frontmatter，至少包含：

```yaml
title: "..."
date: "YYYY-MM-DD"
tags: [...]
category: "..."
load: on-demand
status: active
synopsis: "..."
version: 1
changelog: "initial"
```

`规章制度/` 下的核心规则，实质性内容变更需递增 `version` 并更新 `changelog`。

## 提交前验证

告诉你的 Agent：

```text
改动完了，按 CONTRIBUTING.md 的要求跑验证，确认无误后提交。
```

Agent 会自动运行 lint、audit、self-check，确认零 ERROR 后提交并推送。

## Commit 风格

```text
docs: improve quickstart
ci: add validation workflow
governance: clarify business package discovery
scripts: make self-check branch agnostic
```

## 公开安全检查

告诉你的 Agent：

```text
提交前检查这个仓库有没有残留的私有内容（路径、IP、token、真实项目名）。
```

Agent 会扫描并移除所有私有残留。

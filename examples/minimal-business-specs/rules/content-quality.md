---
title: "示例内容质量规则"
date: "2026-06-15"
tags: [业务包, 示例, 质量规则]
category: "specs/rules"
load: on-demand
status: active
synopsis: "最小业务包的内容质量规则示例，展示业务规则应放在项目 specs/rules 中，而不是 Memento 核心仓库。"
version: 1
changelog: "initial public example"
---

# 示例内容质量规则

## BLOCKING

- 不编造事实。
- 不输出未验证的外部数据。
- 不包含私有路径、账号、token、真实用户信息。

## 建议质量标准

- 先说明输入来源。
- 区分事实、推断和建议。
- 输出应包含可执行的下一步。

## 验证

任务结束前，Agent 应报告：

- 读取了哪些业务规则。
- 运行了哪些检查。
- 是否存在无法验证的断言。

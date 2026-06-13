---
title: "Cron 流水线运维规范索引"
date: "2026-06-13"
tags: [索引, 导航]
category: "规章制度/Cron流水线运维规范"
load: index
audience: [all]
provides: [Cron运维索引]
status: active
synopsis: "Cron 流水线运维入口：汇总定时任务架构、超时重试、链路追踪、异常处理和脚本引用规则。"
version: 6
changelog: "[Agent自修] 优化 synopsis 以提升 Agent 检索判断质量"
versions:
  Cron运维索引: 6
---

# Cron 流水线运维规范索引

Cron流水线的架构设计、超时策略、链路追踪和异常处理规范。

| 文件 | 内容 |
|------|------|
| [[规章制度/Cron流水线运维规范/01-架构设计原则]] | Cron架构选型、no_agent vs LLM-driven、脚本包装 |
| [[规章制度/Cron流水线运维规范/02-超时与重试策略]] | 超时分层、代理超时配置、失败降级 |
| [[规章制度/Cron流水线运维规范/03-链路追踪与日志]] | 输出格式、状态文件、链路完整性 |
| [[规章制度/Cron流水线运维规范/04-异常处理与紧急停止]] | 常见异常、紧急停止、恢复流程 |

## 相关文档

- 业务域定时任务（参考 `业务/` 下的任务定义）
- [[规章制度/Agent协作/多Agent知识库协作规范]] — Git 协作

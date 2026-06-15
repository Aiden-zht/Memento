---
title: "Memento 索引"
type: index
status: active
load: default
source: agent_synthesis
confidence: high
last_reviewed: "2026-06-15"
synopsis: "Memento 总入口：按 Agent 使用方式导航规章制度、产物规范、专业知识、素材库、项目知识、用户资料和 inbox。"
provides: [知识库索引, 导航目录]
version: 13
changelog: "[Agent自修] git 副作用口径统一引用任务类型索引，删除重复约束"
versions:
  知识库索引: 9
  导航目录: 3
---

# Memento 索引

> Git: https://github.com/your-username/memento.git
> 冷启动入口：[[AGENTS]]
> 内容治理：[[规章制度/知识库管理/知识库内容治理规范/index]]

## 顶层目录

| 目录 | 用途 | 加载 |
|------|------|------|
| [[规章制度/index]] | KB 和 Agent 自身怎么运行 | 按任务加载 |
| [[产物规范/index]] | 各类产物怎么做、怎么验收 | 生成/验收对应产物时加载 |
| [[专业知识/index]] | 领域/技术/行业判断依据 | 按需加载 |
| [[素材库/index]] | 案例、故事、金句、片段、失败案例 | 按需加载 |
| [[项目知识/index]] | 具体项目/repo/系统长期事实 | 相关项目任务加载 |
| [[用户资料/index]] | 用户投喂并消化后的来源资料 | 按需引用 |
| `inbox/` | 原始材料投递口 | 仅消化任务读取 |

`scripts/` 和 `_templates/` 是维护设施，不是知识权威源。

## 使用规则

- 先判定任务模式，再按任务类型索引和全文搜索加载相关文件。
- 使用目录/文件前检查 `status`、`load`、`source`、`confidence`、`load_when`。
- 没有合格 `index.md` 的目录，不视为正式知识源。
- KB 维护模式下的推送约束以 [[规章制度/知识库管理/任务类型索引]] 为准。

---

相关：[[规章制度/知识库管理/知识库内容治理规范/04-目录分类]] · [[规章制度/知识库管理/知识库内容治理规范/05-文件规范]] · [[规章制度/知识库管理/知识库内容治理规范/07-Agent行为约束]]

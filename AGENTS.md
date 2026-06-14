---
title: "AGENTS.md — Memento 冷启动入口"
date: "2026-06-14"
tags: [知识库, Agent, 初始化, 冷启动, 入口]
category: "规章制度/知识库管理"
load: always
status: active
synopsis: "新 Agent 冷启动入口——Memento 零记忆接入的第一步：git pull → 任务模式判定 → 任务类型索引 → 全文搜索 → 按需加载。"
version: 6
changelog: "[agent] 新增任务模式判定硬规则：默认普通产出，明确维护才写 KB"

# AGENTS.md — Memento 冷启动入口

任何无记忆 Agent 进入本仓库后，先执行：

```bash
cd /path/to/memento
git pull origin master
```

然后先阅读：

1. `规章制度/知识库管理/任务类型索引.md`

仅在任务涉及 KB 写入、Agent 初始化、skill/cron/脚本同步或行为边界判断时，再按需读取：

- `规章制度/知识库管理/知识库内容治理规范/00-读取规范.md`
- `规章制度/知识库管理/知识库内容治理规范/09-新Agent初始化.md`
- `规章制度/知识库管理/知识库内容治理规范/07-Agent行为约束.md`

执行任务时使用固定流程：

```text
任务模式判定（普通产出 / KB 使用 / KB 维护）→ 任务类型索引 → 关键词全文搜索 → 读候选 frontmatter → 按 synopsis/load/status 筛选 → 按需读取正文 → 执行 → 必要时 lint/commit/push
```

## 业务任务

执行业务任务（如"发布文章"）时，额外执行：

1. 检查当前项目目录是否有 `specs/index.md`
2. 若存在 → 读 `depends_on` → 加载 Memento 对应规范 → 加载 `specs/rules/` 和 `specs/references/`
3. 若不存在 → 按 `规章制度/知识库管理/知识库内容治理规范/12-业务包通用设计` 引导用户创建

## 创建新业务

用户说"新建业务"时，Agent 按 `12-业务包通用设计` 创建独立项目 `specs/`，不在本仓库中创建业务目录。模板骨架在 `_templates/business-package/index.md`。

完成后（或首次进入），运行验收测试确认 KB 可用：参考 `09-新Agent初始化#第七步`。

硬规则：

- 执行前先判定任务模式：默认普通产出；只有明确 KB 维护意图才允许修改 Memento。
- 不靠记忆猜规范；先查 KB。
- `provides` 只是辅助标签；搜不到时用全文搜索兜底。
- 新增或修改 `.md` 必须有 frontmatter、`synopsis`、`version`、`changelog`。
- 改 KB 后必须运行 `bash scripts/lint-knowledge-base.sh`。
- KB 改动必须 `git add -A` → `git commit` → `git push`；普通产出模式和 KB 使用模式禁止 git 副作用。
- 中间状态、生成产物、日志、图片二进制不入 KB。
- 业务规则不入本仓库，放入对应项目 `specs/` 目录。

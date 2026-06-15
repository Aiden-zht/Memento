---
title: "inbox 消化规范"
date: "2026-06-15"
tags: [知识库, inbox, 消化, 分类, 拆分]
category: "规章制度/知识库管理/知识库内容治理规范"
load: on-demand
audience: [agent]
provides: [inbox消化, 内容拆分, 自动分类, 用户资料, 二次晋升]
status: active
synopsis: "Agent 消化 inbox 的标准流程：原始材料先评审，默认进入用户资料或不入库；只有经二次判断才晋升正式目录。"
version: 4
changelog: "[Agent自修] 圆桌审计后统一七类正式目录命名，清理旧目录命名残留"
versions:
  inbox消化: 3
  内容拆分: 2
  自动分类: 3
  用户资料: 1
  二次晋升: 1
---

# inbox 消化规范

Agent 发现 `inbox/` 中有文件时，按此流程处理。

## 0. 核心原则

- `inbox/` 是原始入口，不是知识源。
- 用户资料是来源层，不自动成为规则。
- 正式目录才是权威层；晋升必须经过 Agent 判断。
- 用户说“以后参考”只表示入库候选，不自动升格为规则。
- 用户不手工维护目录；Agent 负责分类、审计、清理。

默认路径：`inbox/` → `用户资料/` 或不入库 → 必要时二次晋升到正式目录。

## 1. 扫描输入

扫描 `inbox/` 下除 `README.md` 外的全部文件，不限于 `.md`：

```bash
find inbox -maxdepth 1 -type f ! -name README.md -print
```

按文件名、扩展名、大小先做输入清单。

## 2. 对话提示

当材料可能不入库、需要转换、来源不明或分类会新增目录时，Agent 先给极短提示：

```text
我先做 inbox 评审：这些文件不一定全部入库。低置信度、临时材料、运行产物不会自动写入 KB。
```

普通、低风险、高质量 Markdown 可继续自动消化，不需要反复打断用户。

## 3. 格式处理

| 类型 | 处理方式 |
|------|----------|
| `.md` / `.txt` | 直接读取并评审 |
| `.doc` / `.docx` / `.wps` / `.pdf` | 先转换临时文本，再验收 |
| 图片、音视频、压缩包 | 默认不入 KB，除非用户给出文本化目标 |
| 未知格式 | 先报告，不自动入库 |

转换出的临时文本不直接入库，必须验收可读性、完整性、低乱码率。

## 4. 入库价值判断

| 判定 | 动作 |
|------|------|
| 无长期价值 | 不入库，只在会话内处理 |
| 有来源价值但未形成规则/知识 | 进入 `用户资料/` |
| 稳定判断依据 | 晋升 `专业知识/` |
| 可复用表达/案例/片段 | 晋升 `素材库/` |
| 项目长期事实/契约 | 晋升 `项目知识/` |
| 产物制作或验收标准 | 晋升 `产物规范/` |
| KB/Agent 自身规则 | 晋升 `规章制度/` |

## 5. 二次晋升规则

从 `用户资料/` 晋升正式目录前，必须确认：

- 是否多 Agent 长期共享；
- 是否有明确 source；
- 是否能说明 load_when；
- 是否不是一次性任务产物；
- 是否不触犯 [[规章制度/知识库管理/知识库内容治理规范/03-不存什么]]；
- 目标目录 index 是否允许收录。

不满足则留在用户资料、标记 stale，或不入库。

## 6. 补 frontmatter

新建文件按 [[规章制度/知识库管理/知识库内容治理规范/05-文件规范]] 使用最小字段。

来源/参考类文件至少包含：

```yaml
---
title: "标题"
type: user_source | domain_knowledge | material | project_knowledge
status: active
load: conditional
source: user | conversation | external_article | official_doc | project_repo | agent_synthesis
confidence: high | medium | low
last_reviewed: "YYYY-MM-DD"
load_when: ["何种任务场景加载"]
synopsis: "一句话说明内容和使用场景。"
---
```

## 7. 创建文件 + 更新索引

- 创建 `.md` 文件到目标目录。
- 目标目录必须有合格 `index.md`；没有则先创建 index。
- 更新目标目录、上级目录和根索引的必要链接。
- 不新建无治理说明的空目录。

## 8. 清理策略

删除 inbox 原始文件前必须满足：已完成入库或明确不入库、用户不要求保留、提取结果已验收、lint/self-check 通过、git commit + push 成功。

如果只是“提取给用户看”，默认不删除原始文件，除非用户明确说不需要。

## 9. 提交与验证

```bash
bash scripts/lint-knowledge-base.sh
python3 scripts/audit-agent-usability.py
bash scripts/self-check.sh
bash scripts/safe-commit.sh "消化 inbox: <简述>"
```

完成后确认 `git status --short` 为空，且远端已 push。

---

相关：[[规章制度/知识库管理/知识库内容治理规范/02-存什么]] · [[规章制度/知识库管理/知识库内容治理规范/03-不存什么]] · [[规章制度/知识库管理/知识库内容治理规范/04-目录分类]]

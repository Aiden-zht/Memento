---
title: "inbox 消化规范"
date: "2026-06-14"
tags: [知识库, inbox, 消化, 分类, 拆分]
category: "规章制度/知识库管理/知识库内容治理规范"
load: on-demand
audience: [agent]
provides: [inbox消化, 内容拆分, 自动分类]
status: active
synopsis: "Agent 消化 inbox 的标准流程：读文件→判断是否拆分→逐段分类→补 frontmatter→创建文件→更新索引→清理 inbox。"
version: 1
changelog: "initial"
versions:
  inbox消化: 1
  内容拆分: 1
  自动分类: 1
---

# inbox 消化规范

Agent 发现 `inbox/` 中有 `.md` 文件时，按此流程处理。

## 1. 扫描

```bash
ls inbox/*.md
```

跳过 `inbox/README.md`。

## 2. 判断是否拆分

读每个文件。如果包含多个毫不相关的主题（不同领域、不同受众、独立性强的段落），**必须拆分为多个独立文件**。

判断标准：
- 两个段落的标题没有层级关系 → 拆
- 放在同一个 KB 文件里会让搜索命中时产生噪音 → 拆
- 一个段落可以独立被引用、独立被更新 → 拆

不要把 CAD 规范和 Python 打包塞进同一个文件。

## 3. 逐段分类

对每个独立主题，按 [[规章制度/知识库管理/知识库内容治理规范/04-目录分类]] 判断归宿：

| 内容类型 | 归入 |
|---------|------|
| Agent 必须遵守的规则 | `规章制度/` |
| 业务域工作流 | `业务/写作/{平台}/` 等 |
| 技术参考、知识 | `知识/{主题}/` |
| 项目文档 | 对应项目目录 |

如果该主题在 KB 中已有相关目录，**并入已有目录**，不要新建。

## 4. 补 frontmatter

每个新建文件必须包含：

```yaml
---
title: "标题"
date: "YYYY-MM-DD"
tags: [标签1, 标签2]
category: "路径"
load: on-demand
provides: [可搜索标签]
status: active
synopsis: "一句话描述，帮助 Agent 快速判断是否该读。"
version: 1
changelog: "从 inbox 消化入库"
---
```

## 5. 创建文件 + 更新索引

- 创建 `.md` 文件到目标目录
- 如果目标目录没有 `index.md`，新建
- 更新目标目录 `index.md`
- 更新上级目录 `index.md`（如果新增了目录）
- 更新根 `index.md`（如果新增了二级目录）

## 6. 清理 + 提交

```bash
# 删除已消化的原始文件
rm inbox/<原始文件>.md

# 提交
bash scripts/safe-commit.sh "消化 inbox: <简述>"

# 验证 inbox 清空
ls inbox/  # 只剩 README.md
```

## 7. 完成后

运行 `bash scripts/self-check.sh` 确认 8/8。

---

相关：[[规章制度/知识库管理/知识库内容治理规范/02-存什么]] · [[规章制度/知识库管理/知识库内容治理规范/04-目录分类]]

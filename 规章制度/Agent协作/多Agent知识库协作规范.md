---
title: "多Agent知识库协作规范"
date: "2026-06-10"
tags: [Agent协作, 知识库, git, 规范]
category: "规章制度/Agent协作"
load: on-demand
audience: [all]
provides: [多Agent协作, git协作规范, session启动检查, commit规范, 冲突处理]
status: active
synopsis: "多Agent知识库协作规范：多个 Agent/会话共用 Git 知识库时的变更感知、commit 格式、冲突处理；涉及 KB 协作时按需加载。"
version: 9
changelog: "[Agent自修] 开源版脱敏：将具体项目路径改为通用项目占位"
versions:
  多Agent协作: 8
  git协作规范: 4
  session启动检查: 4
  commit规范: 4
  冲突处理: 4
---

# 多 Agent 知识库协作规范

> **适用范围**：基础设施层 — 所有使用本知识库的 Agent 必须遵守；涉及 KB 写入、commit/push、冲突处理或多 Agent 协作时按需加载正文。
> 定义多个 Agent/会话共用一个 Git 知识库时的变更感知、commit 格式、冲突处理。
>
> ⚠️ 本文档与「公众号发布流程与质量规范」中的 Agent A/B 流水线是不同维度的概念：
> - 本文档 = Agent 之间如何协作（git 层面）
> - 发布流程 = Agent 之间如何分工完成特定任务（业务层面）

---

## 1. 核心原则

**git commit message = 变更通知**。Agent 写清楚 commit，其他 Agent 看一眼 `git log` 就知道发生了什么。

---

## 2. Session 启动检查清单

每个 Agent 在操作知识库前，必须执行三步：

```bash
cd {{WORKSPACE}}/references/agent_mem

# Step 1: 拉取最新
git pull origin master

# Step 2: 查看新增 commit（只展示自上次以来的变更）
LAST_SEEN=$(cat .last_seen_commit 2>/dev/null || echo "")
if [ -n "$LAST_SEEN" ] && git rev-parse --verify "$LAST_SEEN" >/dev/null 2>&1; then
    echo "===== 其他 Agent 的变更 ====="
    git log --oneline "$LAST_SEEN..HEAD" 2>/dev/null
else
    git log --oneline -5
fi

# Step 3: 保存当前 HEAD
git rev-parse HEAD > .last_seen_commit
```

**或直接运行**：`bash scripts/pull-and-check.sh`
**注意 ，本质是共用一个git仓库内的知识库 ，路径视当前模型对接的该仓库目录**

---

## 3. 知识库加载策略

Agent 启动时按以下优先级选择性加载知识库内容：

| 层级 | 目录 | 加载规则 |
|------|------|----------|
| L1 - 必读 | `规章制度/` | 仅加载以下 4 个核心文件，其他按 `on-demand` |
| L2 - 按需 | `知识/` | 按任务领域选择加载（GPU、面试等） |
| L3 - 业务 | `业务/{领域}/` | 仅当任务属于该领域时加载 |
| L4 - 项目 | `业务/{领域}/项目文档/` | 按项目选择加载 |

> **默认加载路径**：`AGENTS.md` + `规章制度/知识库管理/任务类型索引.md`。
> 其他治理正文按任务需要加载：涉及 KB 写入/协作/冲突时加载本文；涉及 Agent 初始化时加载 `09-新Agent初始化.md`；涉及行为边界或本地实现同步时加载 `07-Agent行为约束.md`。
>
> Hermes Agent 的 system prompt 已包含 git pull、git add+commit+push、唯一信源等核心约束，Agent 可从任务类型索引起步，不必每次全量加载 5 个 L1 文件。
>
> `规章制度/` 下其他文件（知识库定位、存什么、目录分类、文件规范等）按 `load: on-demand` 对待，仅当涉及知识库写入/创建/治理时按需加载。

**示例**：
- 公众号发文 Agent → 任务索引 + 公众号相关规范；仅在改 KB 时加载协作规范
- 面试准备 Agent → 任务索引 + `知识/面试经验/` 相关文件
- 抖音新业务 Agent → 任务索引 + 新业务接入/写作通用规范；需要创建 KB 文件时再加载治理规范

---

## 4. Commit Message 格式规范

```
[agent-标识] 简短描述 — 变动文件列表
```

### 格式说明

| 字段 | 说明 | 示例 |
|------|------|------|
| `[agent-标识]` | 谁做的修改 | `[写作-AgentA]`, `[大钱-主控]`, `[deepseek-chat]` |
| 简短描述 | 一句话说清做了什么 | `修复 freepublish 说明` |
| 变动文件 | 逗号分隔受影响文件（可选但推荐） | `— API开发手册.md, 面试经验.md` |

### 完整示例

```bash
git add .
git commit -m "[写作-AgentA] 修复公众号API手册 freepublish 说明 + 扩展面试tags — 公众号API开发手册.md, 面试经验.md"
git push origin master
```

### 命名约定

- 用 agent 标识或模型名（如 `写作-AgentA`, `deepseek-chat`, `qwen`）
- 固定使用一个名称，方便追溯
- 不建议用 `agent-A` / `agent-B`，因为不明确

---

## 5. 冲突处理

### 如果 push 被拒绝（其他 Agent 已推送）

```bash
# 1. 先拉取
git pull origin master --rebase

# 2. 如果有冲突，解决后
# 3. 重新推送
git push origin master
```

### 防止覆盖

- **永远在修改前 pull**
- **永远用 `--rebase` 而非 merge，保持历史线性**
- 如果 pull 后发现自己在同一个文件有冲突，先看对方的 commit message 了解其意图

---

## 6. 文件锁约定（可选，用于长文档编辑）

如果某个 Agent 将花费 10+ 分钟编辑同一文件，可以在 commit message 中附加：

```
[写作-AgentA] 正在编辑GPU分享.md - 预计30分钟完成
```

其他 Agent 看到这条 commit 后，暂不修改该文件。完成后再提交并注明 `— 完成GPU分享.md`。

---

## 7. 相关文档

- 业务 Agent — 项目协作（项目文档在 `{{WORKSPACE}}/tools/<your-project>/`）

---

## 附录：pull-and-check.sh 脚本

脚本位置：`scripts/pull-and-check.sh`

Agent 调用方式：
```bash
bash {{WORKSPACE}}/references/agent_mem/scripts/pull-and-check.sh
```

输出示例：
```
===== 其他 Agent 的变更 =====
c9eb934 [deepseek-chat] 新增字节跳动大模型SRE面经 — 面试经验.md
41e8d34 [写作-AgentA] 补充公众号运营策略文档 — 公众号运营策略.md
===== 当前 HEAD: 1559c08 =====
```

---

## 相关文档

- [[规章制度/知识库管理/知识库内容治理规范/index]] — 定义知识库的内容边界和文件规范
- [[index]] — 知识库目录和索引

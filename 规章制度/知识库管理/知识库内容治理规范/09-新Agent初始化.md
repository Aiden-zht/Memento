---
title: "Agent 初始化与规范加载"
date: "2026-06-13"
tags: [知识库, Agent, 初始化, 规范加载]
category: "规章制度/知识库管理/知识库内容治理规范"
load: on-demand
audience: [all]
provides: [Agent初始化, 规范加载, Agent引导, 本地实现同步]
status: active
synopsis: "新 Agent 启动时如何拉取 KB、读任务索引、按全文搜索+synopsis 加载规范，并处理 skill/cron 的 requires_provides。"
version: 19
changelog: "[Agent自修] 公开版脱敏路径并同步任务能力入口"
versions:
  Agent初始化: 14
  规范加载: 3
  Agent引导: 4
  本地实现同步: 3
---

# Agent 初始化与规范加载

> 所有 Agent，不论新老，读完这篇就知道如何使用 KB：先拉最新，再按任务类型找规范，最后执行任务。

## 第〇步：安装 pre-commit hook（仅新 clone 后执行一次）

```bash
bash scripts/install-hooks.sh
```

**此步骤是强制的。** 未安装 hook 则 `python3 scripts/audit-agent-usability.py` 会报 `E_AGENT_HOOK_MISSING`，lint 通过也无法保证 commit 前自动检查。安装后每次 `git commit` 自动运行 `lint-knowledge-base.sh`，lint 不通过则阻止提交。

如果 hook 已安装，跳过此步。

## 第一步：拉取最新版本

```bash
cd /path/to/memento
git pull origin master
```

详细操作见 [[规章制度/知识库管理/知识库内容治理规范/00-读取规范]]。

## 第二步：读任务能力索引和任务类型索引

先读：

1. [[规章制度/知识库管理/任务能力索引]]
2. [[规章制度/知识库管理/任务类型索引]]

目的：
- 判断当前任务属于哪一类
- 获取关键词、核心规范、强制规则摘要
- 避免 Agent 自己猜路径导致漏读规范

## 第三步：按需加载规范

推荐路径：

```text
任务能力索引 → 任务类型索引 → 关键词/核心规则 → 全文搜索 → 读候选 frontmatter → synopsis 筛选 → 读取正文
```

工具选择：

| 场景 | 工具 |
|------|------|
| 不知道文件在哪 | `search_files(pattern="关键词", target="content")` 或 `rg "关键词" --include="*.md" -l` |
| 已知 provides 标签 | `python3 scripts/provides-search.py --synopsis 标签1 标签2` |
| 命中多个候选 | 读前 20 行，看 `synopsis`、`load`、`status` |
| workflow 文件 | 读取同目录下相关 workflow 文件 |

`provides` 是辅助语义标签，不是唯一入口。搜不到标签时必须用全文搜索兜底。

## 第四步：加载 skill 时检查 requires_provides

当加载一个 skill 后，检查其 frontmatter：

```yaml
requires_provides: [内容平台发布流程, 质量检查, 图片治理]
kb_refresh_policy: runtime
```

处理规则：

| 情况 | 动作 |
|------|------|
| 有 `requires_provides` | 按标签搜索 KB 文件，读取 synopsis/changelog/正文 |
| 有 `kb_refresh_policy: runtime` | 每次执行前读取最新 KB，不复制规范正文 |
| 有 `spec_versions` | 仅在硬编码实现中对比版本，判断是否需要更新本地逻辑 |
| 无 `requires_provides` 且任务明显依赖 KB | 用全文搜索自行发现规范；必要时补充 skill frontmatter |
| 纯工具 skill | 不需要 KB 对齐 |

### 什么情况下 skill 必须声明 requires_provides

满足任一条件就必须声明：

1. 该 skill 被用于 cron 任务
2. 该 skill 依赖 KB 特定规范才能正确执行
3. 该 skill 的输出质量由 KB 检查项、流程、模板约束

## 第五步：cron prompt 的 Step 0

任何加载了有 `requires_provides` skill 的 cron prompt，必须在 prompt 开头写明 KB 加载步骤：

```markdown
## Step 0: 加载 KB 知识

本 job 加载了 <skill_name> skill（requires_provides: [标签1, 标签2, ...]）。
先加载 KB 中对应规范：

```bash
cd /path/to/memento
git pull origin master
python3 scripts/provides-search.py --synopsis 标签1 标签2 ...
```

阅读返回文件的 synopsis/changelog，并加载与本任务相关的正文。
```

如果 provides 标签命中为空，cron prompt 必须要求 Agent 用全文搜索关键词兜底，不能跳过规范。

## 第六步：本地实现运行时对齐

如果任务涉及自建 skill、cron、脚本，需要按 [[规章制度/知识库管理/知识库内容治理规范/07-Agent行为约束#7.6-本地实现运行时规范对齐契约]] 执行：

1. 声明依赖：`requires_provides`
2. 执行前加载：`git pull` + `provides-search.py --synopsis` 或全文搜索兜底
3. 阅读规范：查看 synopsis/changelog/version 和必要正文
4. 影响判断：区分文字澄清、参考资料、阈值变化、流程变化、检查项变化、接口变化、废弃规则
5. 必要时修改：更新 skill prompt、cron prompt、脚本逻辑
6. 验证通过：再执行任务；只有硬编码实现才按需推进 `spec_versions` 或旁路状态文件

## 下一步

读完这篇后，按任务继续读：

1. [[规章制度/Agent协作/多Agent知识库协作规范]] — git 协作细节
2. [[规章制度/知识库管理/知识库内容治理规范/07-Agent行为约束]] — 行为规则和运行时规范对齐契约
3. 对应项目项目任务知识 `项目知识/<项目>/index.md` 声明的 workflow 与质量规范

---

## 第七步：KB 可用性验收测试

新 Agent 完成初始化后，按以下流程验证 KB 架构是否完整可用。以下测试不依赖任何具体业务——只测 KB 自身机制是否运转。

### 7.1 结构健康（30 秒，零 token）

```bash
bash scripts/self-check.sh
```

要求：8/8 PASS。

### 7.2 格式与可用性审计

```bash
bash scripts/lint-knowledge-base.sh
python3 scripts/audit-agent-usability.py
```

要求：lint 零错误，audit 零 ERROR。

### 7.3 功能验证（一次性子 Agent，约 5 分钟）

将以下 prompt 原样发给一个**新会话、零上下文、零技能的 Agent**：

---

> 你是一个全新 Agent。你只知道知识库路径：`<KB_PATH>`
>
> 请依次完成以下 5 项验收测试，每项完成后报告 PASS/FAIL 和原因。
>
> **T1 — 冷启动路由**
> 读 AGENTS.md → 读任务类型索引 → 从索引中任选一个任务类型，列出它指向的必读规范文件路径。确认这些文件全部存在（用 read_file 验证）。
>
> **T2 — 工具发现**
> 用 `bash scripts/self-check.sh` 运行健康检查。用 `python3 scripts/provides-search.py --synopsis <任意索引中出现的关键词>` 验证搜索工具可用。
>
> **T3 — 技能自举**
> KB 规范描述了 Agent 应该具备的技能（对应 `~/.hermes/skills/` 下的 SKILL.md）。从任务类型索引中选一个声明了依赖规范（requires_provides）的任务，加载对应的 skill，验证该 skill 的 requires_provides 标签全部能被 provides-search 命中。
>
> **T4 — 技能自修复**
> 在 T3 加载的 skill 中，故意找一处与 KB 规范不一致的地方（如过时的路径、错误的约束），用 patch 修复它，更新 version 和 changelog。报告修复了什么。
>
> **T5 — 多 Agent 隔离**
> 在 KB 仓库的 `tmp/` 目录下创建一个文件 `acceptance-test-<随机ID>.txt`，写入当前时间戳。然后用另一个子 Agent（delegate_task）也创建一个类似文件。确认两个文件共存、内容不同、互不覆盖。
>
> 所有测试通过后，清理 T5 创建的临时文件。

---

**通过标准**：

| 测试项 | 验证的能力 | 通过条件 |
|--------|-----------|---------|
| T1 | 冷启动 + 任务路由 | 正确导航 AGENTS.md → 索引 → 规范，所有文件存在 |
| T2 | 工具发现 | self-check 返回结果，provides-search 命中 |
| T3 | 技能自举 | 找到 skill，requires_provides 全命中 |
| T4 | 技能自修复 | Agent 自主发现并修复了不一致 |
| T5 | 多 Agent 隔离 | 两个文件共存，内容不同 |

### 7.4 判断标准

| 结果 | 含义 |
|------|------|
| 5/5 PASS | KB 架构完全可用，可以交给任何 Agent |
| T1/T2 FAIL | 入口或工具损坏，KB 无法冷启动 |
| T3 FAIL | 技能索引或 provides 机制有断链 |
| T4 FAIL | 技能自修复闭环不工作——KB 改了但技能不跟 |
| T5 FAIL | 多 Agent 存在文件冲突风险 |

### 7.5 首次验收后

验收通过后，日常只需跑 7.1 + 7.2（30 秒）。仅在以下情况重新跑完整 7.3：

- 新机器/新 Agent 首次接入
- KB 目录结构大改
- 新增或删除了任务类型
- 怀疑 KB 损坏

---

相关：[[规章制度/知识库管理/知识库内容治理规范/index]] · [[规章制度/Agent协作/多Agent知识库协作规范]]

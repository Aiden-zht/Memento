---
title: "Agent 行为约束"
date: "2026-06-15"
tags: [知识库, 治理, 规范, Agent]
category: "规章制度/知识库管理/知识库内容治理规范"
load: on-demand
audience: [all]
provides: [Agent行为约束, 读取优先级, 写入检查, 禁止行为, 内容寻址, 规范优化反馈, 职责边界, KB-memory仲裁, 本地实现同步, 项目任务知识发现, 推送纪律, 用户产物优先, 任务模式判定, 使用前检查, 目录审计]
status: active
synopsis: "规定 Agent 读写 KB、按需检索、使用前检查、规范反馈、KB-memory 仲裁，以及 KB 规范变更后本地 skill/cron/脚本如何同步实现。"
version: 19
changelog: "[Agent自修] 圆桌审计后统一七类正式目录命名，并补规则变更时执行层最小只读验收"
versions:
  Agent行为约束: 14
  读取优先级: 4
  写入检查: 3
  禁止行为: 6
  内容寻址: 5
  规范优化反馈: 4
  职责边界: 2
  KB-memory仲裁: 1
  本地实现同步: 3
  用户产物优先: 1
  任务模式判定: 1
  使用前检查: 1
  目录审计: 1
---

# Agent 行为约束

## 7.0 用户产物优先与任务模式边界

默认情况下，用户请求生成的内容属于用户产物，而不是 Memento 知识库资产。Agent 必须先按用户意图、目标路径、是否明确要求固化来判断任务模式，再决定是否读取或修改 KB。

### 7.0.1 用户产物优先原则

- 内容“关于知识库 / Agent / 规范 / 治理 / Memento / SOUL / 角色”不等于内容“属于知识库”。
- 内容“可复用”不等于需要立即固化。
- 读取 Memento 作为执行参考，不等于允许修改 Memento。
- 修改 Memento 不等于自动获得 `git add / commit / push` 授权。

默认按普通用户产物交付的对象包括：文章、SOUL、角色、提示词、配置、方案、模板、草稿、普通文件。若用户指定外部 profile、普通文件路径或项目路径，Agent 应按指定路径交付，不得自行改写为 Memento 知识库落点。

### 7.0.2 三种任务模式

| 模式 | 触发条件 | 允许动作 | 禁止动作 |
|------|----------|----------|----------|
| 普通产出模式 | 用户要求生成、撰写、设计、创建、整理、输出或保存普通产物；这是默认模式 | 输出给用户，或写入用户明确指定路径 | 修改 Memento、移动到 inbox、固化为规范、`git add / commit / push` |
| KB 使用模式 | 用户要求参考、遵守、依据、检查 Memento / KB 规则，但未要求修改 KB | 只读 Memento，按已有规则完成用户任务 | 新增、移动、修改、固化 KB 资产；`git add / commit / push` |
| KB 维护模式 | 用户明确要求写入知识库、纳入 Memento、固化规范、更新 KB、维护 agent_mem、消化 inbox、修改规章制度、整理知识库或提交知识库变更 | 在授权范围内按 KB 维护流程修改 Memento | 超出授权范围修改；未获提交授权时执行 `git add / commit / push` |

BLOCKING：不得仅凭“知识库、规范、Agent、治理、Memento、SOUL、角色”等关键词进入 KB 维护模式；不得仅凭“可复用”“其他 Agent 可能有用”自动固化到 KB。

### 7.0.3 git 副作用门禁

`git add / commit / push` 是独立高副作用动作。只有以下情况允许执行：

1. 用户明确要求提交、推送或完成 KB 维护闭环；或
2. 当前任务已经明确进入 KB 维护模式，且对应 KB 维护流程明文要求提交推送。

普通产出模式和 KB 使用模式下，禁止执行 `git add / commit / push`。

## 7.1 写入前检查

Agent **每次对 KB 文件做完改动后、声明完成前**，必须运行 lint 验证：

```bash
bash scripts/lint-knowledge-base.sh
```

未运行 lint 直接宣布完成 → 视为违规。lint 未通过就提交 → pre-commit hook 会阻止。

### 7.1.1 自检内容

Agent 在执行 `git add` 前，还需自检：

- 禁止添加：中间状态文件（`state.json`）、生成产物（`output/`、`.html`）、编译产物（`.pyc`）
- 文件规范：所有 `.md` 文件必须包含 YAML frontmatter
- 文件名规则：中文、无空格、无特殊字符
- 内容变更：更新 `version` + `changelog`；如该文件维护 `versions`，同步更新相关 tag 版本号

### 7.1.2 lint 拦截的典型错误

| lint 错误码 | 场景 |
|------------|------|
| E05-4 | 改文件内容后忘记 `version +1` |
| E04 | wiki-link 指向不存在路径 |
| E01 | 新建文件忘加 frontmatter |

lint 通过是“声明完成”的前置条件。如果 lint 报 E 类错误，必须先修复再继续。

## 7.2 读取优先级

Agent 读取知识库时，按以下优先级：

| 优先级 | 类型 | 说明 |
|--------|------|------|
| 1 | `规章制度/` | 必须遵守；KB 和 Agent 自身运行规则 |
| 2 | `产物规范/` | 生成或验收对应产物时必须遵守 |
| 3 | `项目知识/` 中的项目契约 | 仅在对应项目内有约束力 |
| 4 | `专业知识/` | 判断参考，不是规则源 |
| 5 | `素材库/`、`用户资料/` | 表达/案例/来源参考，不是事实或规则权威 |
| 6 | `inbox/` | 仅消化任务读取，不作为正式知识 |

### 内容寻址：如何精准加载

正确路径：

1. **任务入口**：先读 `规章制度/知识库管理/任务类型索引.md`，确认任务类型、关键词、强制规则摘要。
2. **发现候选**：用全文搜索定位候选文件。
   - Hermes Agent：`search_files(pattern="关键词", target="content")`
   - Shell：`rg "关键词" --include="*.md" -l`
3. **筛选候选**：读候选文件 frontmatter，优先看 `type`、`status`、`load`、`synopsis`、`source`、`confidence`、`load_when`。
4. **使用前检查**：确认目录 index 和文件 frontmatter 允许在当前任务使用。
5. **辅助确认**：`provides/requires` 用于确认语义标签和执行层依赖，但不是唯一入口。
6. **跟随链接**：业务流程文件中的 wiki-link 是依赖链，必要时继续加载。

### 7.2.1 使用前检查

Agent 使用任何 KB 目录或文件前，必须做最小检查：

- 目录：正式知识目录必须有 `index.md`，且写明定位、收录范围、禁止内容、加载条件、维护方式、审计规则、清理规则。
- 状态：`status: active` 才能直接作为生产依据；`draft/stale/deprecated/archived` 只能参考或需复核。
- 加载：`load` 必须匹配当前任务；`conditional/manual` 必须检查 `load_when`。
- 来源：专业知识、素材库、项目知识、用户资料必须可追溯 `source`。
- 置信度：事实或判断类内容必须检查 `confidence`；低置信度不得写成确定结论。
- 闭环：被 skill、cron、script、AGENTS.md 或任务入口依赖的文件，必须检查 `provides/requires` 和运行时加载机制。

无合格 index 的目录、不满足加载条件的文件、无来源的判断类内容，不得作为正式依据。

## 7.3 禁止行为

| 禁止 | 原因 |
|------|------|
| 将 `state.json` 加入 git | 中间状态不是知识 |
| 将 `output/` 目录加入 git | 生成产物可重新生成 |
| 创建无 frontmatter 的文件 | 无法被索引 |
| 在文件名中使用特殊字符 | 影响链接和引用 |
| 创建超过 600 行的单文件 | 应拆分为多个文件；超限仅 WARNING |
| 存入过时信息而不标记 | 会误导其他 Agent |
| 只靠文件名猜规则 | 容易漏读真正规范；必须读任务索引和候选文件 synopsis |
| 只靠 provides 搜索且搜不到就放弃 | provides 是辅助标签；搜不到时必须用全文搜索兜底 |
| 用 KB 机制替代 Agent 原生搜索/语义理解/git history | 属于过度设计；KB 只补 Agent 短板，不重造原生能力 |
| 忽略项目 项目知识/ 项目任务知识 | 执行业务任务前必须检查当前项目是否有 `项目知识/<项目>/index.md`，按 [[规章制度/知识库管理/知识库内容治理规范/12-项目任务知识接入设计]] 的发现机制加载 |
| **项目任务知识/规范改动后不 push** | **任何对 KB 项目任务知识（`项目知识/`）或规范文件的修改，必须在声明完成前执行 `git add -A → commit → push`。遗漏推送视为违规** | 本次事故：修改 `content_generator.py` 逻辑后未推送 KB，导致规范与实现脱节 |

## 7.4 规范优化反馈

Agent 发现治理规范缺陷、有项目功能改进建议、或 Agent 行为可优化时：

### P0/P1（阻塞/重要）— Agent 可直接修改

适用场景：
- 规范缺陷导致每次执行都出错
- 规则矛盾使 Agent 无法工作
- lint 脚本报错但规范要求不合理
- 缺失关键流程步骤导致产出质量事故

Agent 修改后：改内容 → 更新 version/changelog/versions（如适用）→ lint → commit → push。
commit message 标注 `[Agent自修]` 或 `[agent]` 前缀即可追溯。

### P2（锦上添花）+ 项目建议 — 走工单流程

P2 建议先在当前会话内评估；只有被用户采纳、且会影响多 Agent 执行的内容，才落地到对应规范文件。未采纳的历史建议不入 KB，必要时从 git history 追溯。

## 7.5 职责边界：知识库只存通用内容

知识库存「多 Agent 共用且持久有效」的内容。Agent 自己的事情自己维护，不入库。

### 7.5.1 反过度设计原则

KB 的职责是补 Agent 的短板，而不是替代 Agent 原生能力。新增治理机制前，必须先判断是否已经可由 Agent 原生能力解决：

| Agent 原生能力 | KB 不应重复建设 | KB 应该提供 |
|---------------|----------------|------------|
| 全文搜索 / 语义理解 | 受控词表、强制标签覆盖率、人肉索引 | 高质量 `synopsis`、自然语言关键词、任务入口 |
| 上下文推理 | 复杂语义 lint、E10/E11 类标签一致性管制 | 少量明确 BLOCKING 规则 |
| git history / changelog | 全库 tag 级版本数据库 | 核心规范 `version/changelog`，长期实现按需 `spec_versions` |
| 工具调用与验证 | 把执行过程写成重型 schema | 最低验证命令、失败兜底、禁止跳过项 |

判断标准：如果某机制只是让 KB 更像数据库，但不能明显降低 Agent 漏读、误读、跳过规范的概率，就不要新增；已有机制应降级、删除或转为历史参考。

| 不入库类别 | 示例 | 存放位置 |
|------|------|----------|
| Agent 运行状态 | KPI 积分、会话日志、调试输出 | Agent 各自工作区，不入 git |
| 生成产物 | 文章 HTML、摘要、封面图 | 输出目录，用完即弃 |
| Agent 专属配置 | 单 Agent 的 prompt 片段、shell 别名 | Agent 工作区或 dotfiles |
| 临时分析 | 一次性调研、调试记录 | 会话内消化，不入库 |

例外：项目 `项目知识/` 中的流程、模板、质量标准，在用户明确创建项目知识或固化项目长期规则时，属于项目知识，应进入对应项目目录，不进入 Memento 核心规章制度。

判断标准：只有“多 Agent 长期共享 + 用户明确要求固化”的内容才进入 KB 或项目知识；如果只是本次任务产物、候选提示词、SOUL、角色草稿、一次性方案，默认按用户产物交付，不因“其他 Agent 可能有用”自动入库。

## 7.6 本地实现运行时规范对齐契约

目标：本地自建 skill、cron job、脚本在执行时读取最新 KB 规范，并在发现规范变更影响实现时先更新实现、验证，再继续执行。

核心原则：

- KB 是规则源，本地实现只保存任务骨架和依赖入口，不复制完整规范。
- `requires_provides` 是依赖声明，必须保留。
- `spec_versions` 是可选状态，不是默认要求；只有硬编码脚本、长期 cron 状态追踪、无法运行时加载 KB 的实现才需要。
- 默认同步方式不是"版本记账"，而是"运行时读取最新 KB + Agent 判断是否影响实现"。
- 闭环只在规则、目录结构、任务入口、Agent 行为、frontmatter/provides/requires、`kb_refresh_policy`、产物规范、项目契约，或被 skill/cron/script/AGENTS.md/任务入口依赖时触发；普通素材、用户资料、参考知识不强制声明 `requires_provides`。

### 7.6.0 规则变更后的最小只读验收

KB 仍然只颁布规则，不管理执行层实现；但规则变更完成前，Agent 必须做最小只读验收，防止旧规则仍在生产执行层运行。

触发条件：修改 KB 规则、目录结构、任务入口、Agent 行为、frontmatter/provides/requires、`kb_refresh_policy`、产物规范或项目契约。

检查范围：

1. AGENTS.md、README、任务能力索引、任务类型索引、强制规则索引是否仍引用旧入口、旧目录名或旧规则口径。
2. 依赖 KB 的 skill frontmatter 是否声明 `requires_provides` 与 `kb_refresh_policy: runtime`。
3. cron prompt 是否有 Step 0 加载 KB，且未硬编码旧路径或旧目录名。
4. 本地 scripts / role SOUL / prompt 中是否存在会影响执行的旧词、旧路径、旧规则。

验收输出必须说明：已检查范围、跳过范围、不可访问范围、未发现依赖、旧词/旧路径命中。不得把具体 skill、cron、script、prompt 的私有内容写进 KB 当法律；只记录通用检查要求。

**闭环保证：任何自建 skill，只需在 frontmatter 声明两行——`requires_provides` + `kb_refresh_policy: runtime`。不需要硬编码 KB 文件路径、不需要写桥接代码、不需要手动同步。KB 规范改了内容（阈值、流程、检查项），下次执行自动读最新版。KB 改了目录结构，provides-search 搜索定位，不受路径变化影响。**

### 7.6.1 适用范围

必须执行运行时规范对齐的本地实现：

> **项目任务知识**：除 skill/cron/脚本外，项目 `项目知识/` 项目任务知识的 `index.md` 也必须声明 `depends_on`（等价于 `requires_provides`）和 `kb_refresh_policy: runtime`，执行前读取最新 KB 并判断变更影响。详见 [[规章制度/知识库管理/知识库内容治理规范/12-项目任务知识接入设计]]。



| 类型 | 条件 | 示例 |
|------|------|------|
| 生产 skill | 依赖 KB 规范才能正确执行 | example-agent、validator-agent、kpi-agent |
| cron job | 定时执行业务流程或规范校验 | 每日示例内容流水线 |
| 本地脚本 | 代码中硬编码了 KB 规则、阈值、流程 | content_generator.py、validator 脚本 |

不需要接入：纯工具封装、一次性临时脚本、不依赖 KB 规范的 API 调用。

### 7.6.2 生产 skill 必须声明依赖

每个依赖 KB 的生产 skill 必须在 frontmatter 声明：

```yaml
requires_provides: [内容平台发布流程, 质量检查, 图片治理]
kb_refresh_policy: runtime
```

要求：

- `requires_provides`：声明这个 skill 执行时必须加载哪些 KB 规范。
- `kb_refresh_policy: runtime`：表示每次执行时从 KB 读取最新规范，不把规范正文复制进 skill。
- `spec_versions`：可选；只有该 skill 维护硬编码检查项、阈值、固定 prompt 状态时才记录。

可选状态示例：

```yaml
spec_versions:
  内容平台发布流程: 3
  图片治理: 2
```

### 7.6.3 运行时对齐流程

依赖 KB 的 skill、cron、脚本在执行前必须执行：

```bash
cd /path/to/memento
git pull origin master
python3 scripts/provides-search.py --synopsis 标签1 标签2 ...
```

如果 `provides-search.py` 未命中，必须用任务关键词 / 规则名全文搜索兜底，不能跳过 KB 规范。

执行顺序：

1. 读取本地实现的 `requires_provides`。
2. `git pull` 获取最新 KB。
3. 用 `provides-search.py --synopsis` 或全文搜索定位规范文件。
4. 阅读 `synopsis`、`version`、`changelog` 和必要正文。
5. 判断 KB 变更是否影响本地实现。
6. 无影响：继续执行任务。
7. 有影响：先更新 skill prompt、cron prompt 或脚本逻辑，验证通过后再执行任务。

### 7.6.4 影响判断规则

不允许因为 KB changelog 变化就盲改本地实现。必须按变更类型判断：

| 变更类型 | 判断 | 本地动作 |
|----------|------|----------|
| 文字澄清 | 不改变流程、阈值、检查项 | 不改实现，继续执行 |
| 新增参考资料 | 只增加背景说明或示例 | 不改实现，按需阅读 |
| 阈值变化 | 分数、数量、时间、过滤条件变化 | 修改 skill prompt 或脚本常量 |
| 流程变化 | 步骤新增、顺序调整、强制环节变化 | 修改 cron prompt、skill workflow、脚本编排 |
| 检查项变化 | validator 规则新增/删除/改名 | 修改校验逻辑和测试样例 |
| 接口变化 | API 参数、输出格式、发布流程变化 | 修改调用代码并跑 dry-run |
| 废弃规则 | KB 标记 deprecated 或删除旧规范 | 移除本地旧逻辑 |

### 7.6.5 需要 `spec_versions` 的场景

默认不要求 `spec_versions`。只有以下情况需要：

- cron job 长期无人值守，且 prompt/脚本无法每次完整读取 KB 正文。
- 本地脚本硬编码了 KB 中的阈值、检查项、字段名、流程顺序。
- 需要审计“某个实现上次按哪个 KB 版本验证过”。

使用 `spec_versions` 时，规则是：验证通过后才推进版本；验证失败时不得更新版本记录。

### 7.6.6 修改后的验证要求

| 改动对象 | 最低验证 |
|----------|----------|
| skill | frontmatter 可解析；`requires_provides` 能命中 KB；确认执行前会加载最新 KB；主 `SKILL.md` 能直接暴露 BLOCKING 规则或明确指向必须读取的 reference |
| cron prompt | 手动 `cronjob run` 或 dry-run；确认 Step 0 加载 KB；确认 deliver 目标正确 |
| Python/JS 脚本 | 跑最小单元测试或 dry-run；不能只改不跑 |
| KB 文件 | `bash scripts/lint-knowledge-base.sh`；commit + push |

### 7.6.7 Skill 自更新闭环

Agent 修改 skill 时，必须先判断新增内容属于“工具执行经验”还是“多 Agent 共用业务规则”。

| 内容类型 | 存放位置 | 必须动作 |
|----------|----------|----------|
| 工具命令、参数、环境依赖、单工具坑点 | skill 主文档或 `专业知识/`、`素材库/` 或 `用户资料/` | 主 `SKILL.md` 必须能发现；必要时引用 reference |
| 多 Agent 共用的业务流程、质量标准、发布要求、BLOCKING 规则 | KB 对应产物规范/项目知识/规章制度文件 | 先落 KB，再让 skill 通过 `requires_provides` / 明确引用加载 |
| 临时会话经验、一次性调试状态 | 不入 KB，不入 skill | 当前会话消化；必要时转成通用规则后再入库 |

强制规则：

- 不得把业务规则只藏在 skill reference 里；如果另一个 Agent 也需要知道，必须同步进入 KB。
- 如果 reference 中有“必须读”“BLOCKING”“禁止”等执行性要求，主 `SKILL.md` 必须显式提示，并说明何时读取该 reference。
- 修改 skill 后必须按正常加载路径自测：只加载主 `SKILL.md` 时，Agent 是否能发现关键规则；需要 reference 时，主文档是否明确指向。
- 依赖 KB 的 production skill 必须在 frontmatter 声明 `requires_provides` 和 `kb_refresh_policy: runtime`。

### 7.6.8 场景差异

| 场景 | 对齐方式 |
|------|----------|
| 对话 Agent | 每次 `git pull` 后读最新 KB；不维护长期版本表 |
| Cron Agent | prompt Step 0 固定加载 KB；必要时记录 `spec_versions` |
| 自建 skill | 声明 `requires_provides`；执行时动态加载 KB；只在硬编码实现中维护 `spec_versions` |
| 本地脚本 | 能运行时读 KB 就读 KB；不能读 KB 时用旁路状态记录依赖和已验证版本 |

## 7.7 KB-memory 仲裁

KB 与 memory 同时存在时：

| 冲突类型 | 权威源 |
|----------|--------|
| 多 Agent 共用的业务规则、流程、质量标准 | KB |
| 单机环境状态、代理端口、GPU 驱动、本机路径 | memory |
| 用户长期偏好 | memory |
| 当前任务临时状态 | 不入 KB，不入 memory |

判断标准：另一个 Agent 也需要知道吗？需要 → 写 KB；只对当前机器/当前用户有效 → 写 memory。

---

相关：[[规章制度/知识库管理/知识库内容治理规范/index]] · [[规章制度/知识库管理/任务类型索引]]
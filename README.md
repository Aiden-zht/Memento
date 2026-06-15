# Memento

> AI 不会忘。

---

## 这是什么

Memento 不是文档仓库。它是一个**自描述、自修复、自验收**的 AI 知识底座。

你只需要做一件事：把文章扔进 `inbox/`。剩下的——分类、格式化、索引、校验、提交——Agent 自己完成。

有了想法就对 Agent 说："以后 X 前必须先 Y"。Agent 会创建规范、补 frontmatter、跑 lint、commit、push。

```text
人 → 把文档扔进 inbox/         Agent → 评审 → 消化 → 归类 → 入索引
人 → 对 Agent 说一个想法         Agent → 创建/修改规范 → lint → commit
人 → 对 Agent 说创建业务包       Agent → 读模板 → 创建 specs/ → 完善规则
新 Agent → 拿到仓库路径          Agent → AGENTS.md → 索引 → 规范 → 执行
```

---

## 你能得到什么

**不用管知识库。** 扔文章进 inbox，跟 AI 聊天说想法，Agent 会先评审是否值得长期入库，再自动分类、格式化、索引、校验。你只负责说话和扔文件。

**不会阳奉阴违。** 跟 AI 说"发布前必须校验"——它真的会校验。BLOCKING 规则写在入口，pre-commit hook 拦在提交前，self-check 每次 commit 跑一遍。不是建议，是硬约束。

**换 Agent 不换脑子。** 换新模型、换新平台、换新机器——Agent 拿到这个仓库就能干活。技能自修复、规范自感知，不需要重新调教。

**业务无关。** Memento 只管规范和通用知识。内容发布写作、示例业务处理——那些是业务项目 `specs/` 的事。Memento 定义业务包标准，各项目按标准创建，Agent 自动识别。

---

## 架构

```text
memento/
├── AGENTS.md                          ← Agent 冷启动入口
├── inbox/                             ← 你的投递口（扔文章就行）
├── 规章制度/                          ← Agent 必须遵守的规则
│   ├── Agent协作/                    ← 多 Agent git 协作规范
│   ├── 知识库管理/                   ← KB 自身治理（定位、格式、生命周期、回滚）
│   └── Cron流水线运维规范/           ← 定时任务运维
├── 知识/                             ← 跨领域通用知识（公开版默认不内置）
├── _templates/                        ← 通用模板
│   └── business-package/             ← 业务包骨架（Agent 创建新业务时以此为模板）
├── scripts/                          ← 工具链（Agent 自动调用）
│   ├── self-check.sh                 ← 8 维健康检查
│   ├── lint-knowledge-base.sh        ← 格式和链接检查
│   ├── provides-search.py            ← 语义标签搜索
│   └── pre-commit                    ← git hook（lint + self-check）
└── .gitignore                        ← 违禁文件网关
```

**核心回路**：AGENTS.md → 任务类型索引 → 全文搜索/synopsis 筛选 → 规范正文 → 执行

**业务解耦**：业务规则由各项目 `specs/` 独立维护，通过 [[规章制度/知识库管理/知识库内容治理规范/12-业务包通用设计]] 的标准结构接入。Agent 执行任务时自动检查项目 `specs/` 目录并加载。

---

## 特性

### 🧭 零记忆接入
新 Agent 只知道仓库路径，就能通过 `AGENTS.md` → `任务类型索引` → 规范 完成冷启动。实测：零上下文 Agent 跑通完整业务流水线。

### 📦 业务包通用设计
Memento 定义业务包标准结构（`specs/`），但不存放任何业务内容。你对 Agent 说"新建写作业务"，Agent 读模板 → 创建 specs/ → 对话逐步完善规则。见 `12-业务包通用设计`。

### 🔧 技能自举
KB 规范通过 `requires_provides` 标签声明依赖。Agent 加载技能时自动 `git pull` → `provides-search` → 读最新规范，不需要你手动同步。

### 🩹 技能自修复
规范改了，Agent 能自主发现技能中的过时引用并修正。已通过验收测试验证。

### 🛡️ 提交即检查
每次 `git commit` 自动触发 lint + self-check（8 维度：违禁文件、废弃引用、索引完整性、目录深度、入口断链……）。违规直接拦截。

### 📦 零门槛使用
你不需要懂目录结构。文章扔进 `inbox/`，对 Agent 说"消化 inbox"。Agent 先评审价值和质量，再按需补格式、入索引。

### ✅ 内置验收
`09-新Agent初始化` 包含通用验收测试，测冷启动、工具发现、技能自举、自修复、多 Agent 隔离。

### 🔄 回滚 SOP
改错了？`06-文件生命周期` §6.7 有完整回滚流程：时机判断 → `git revert` → 连带检查（入链/索引/provides/下游通知）。

### 📐 职责边界清晰
`01-知识库定位` 明确：KB 是宪法，不是政府。不管 skill 备份、cron 调度、影响分析、通知告警——那些是 Agent 运行时的事。

---

## 快速开始

把仓库交给你的 Agent：

```text
这是我的 Memento 仓库：/path/to/memento。请读取 AGENTS.md，以后按这里的规范工作。
```

然后你只需要做一件事：把文档扔进 `inbox/`，说"消化 inbox"。有了想法就说"以后 X 前必须先 Y"或"帮我创建一个 Z 业务包"。Agent 会按仓库规范完成一切。

更多见 [[QUICKSTART]]，常见问题见 [[FAQ]]，贡献说明见 [[CONTRIBUTING]]。

## 公开示例

- [[examples/index]] — 公开脱敏示例入口。
- [[examples/agent-first-run]] — 新 Agent 验收测试示例。
- [[examples/minimal-business-specs/index]] — 最小业务包示例。

---

## 工具链

| 工具 | 用途 |
|------|------|
| `self-check.sh` | 8 维健康检查，零 LLM token |
| `lint-knowledge-base.sh` | frontmatter、wikilink、version、文件名 |
| `audit-agent-usability.py` | 模板泄漏、草稿入口、占位双链 |
| `provides-search.py` | 语义标签辅助搜索 |
| `safe-commit.sh` | lint → add → commit → push，自动加 Agent 标识 |
| `install-hooks.sh` | 安装 pre-commit hook |
| `pre-commit` | 每次 commit 自动 lint + self-check |

---

## 设计原则

1. **给 Agent 用，不是给人浏览** — 文档优先服务检索和执行
2. **任务入口优先** — 任务类型索引 + 全文搜索 > 目录导航
3. **用 Agent 原生能力** — 不造受控词表、不建集中式 manifest
4. **简化优先** — 新增机制前先问：能减少 Agent 漏读/误读吗？
5. **BLOCKING 规则前置** — 硬性约束写在入口，Agent 不能跳过
6. **KB 是宪法，不是政府** — 只定义规则，不执行规则
7. **品牌无关** — 不出现任何平台或产品特定名称

---

## 许可证

MIT License — 详见 [[LICENSE]]

---

## 目录

- [[AGENTS]]
- [[index]]
- [[规章制度/知识库管理/任务类型索引]]
- [[规章制度/知识库管理/知识库内容治理规范/index]]
- [[规章制度/知识库管理/知识库内容治理规范/12-业务包通用设计]]
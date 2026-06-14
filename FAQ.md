# FAQ / Troubleshooting

## 我 clone 后第一步做什么？

```bash
cd /path/to/memento
bash scripts/install-hooks.sh
bash scripts/self-check.sh
```

然后让 Agent 读取 `AGENTS.md`。

## lint 报 E01 frontmatter 缺字段怎么办？

给 Markdown 文件补 YAML frontmatter。托管型 `.md` 文件至少需要 `title/date/tags/category`，核心规范还应有 `load/status/synopsis/version/changelog`。

## lint 报 E04 wiki-link 无法解析怎么办？

保守写法：完整路径 wikilink，不使用别名。示例：

```text
完整路径
目录/index
```

实际使用时再加双方括号；避免使用别名形式。

## audit 报 E_AGENT_HOOK_MISSING 怎么办？

运行：

```bash
bash scripts/install-hooks.sh
```

该 hook 会在 commit 前运行 lint 和 self-check。

## self-check 的 S5 Git 失败怎么办？

常见原因：

- 有未提交文件：先确认变更，再 commit。
- 有未推送提交：`git push origin main`。
- 远端分支未设置：`git branch --set-upstream-to=origin/main main`。

## self-check 的 S3 索引失败怎么办？

每个包含 `.md` 内容的目录都需要 `index.md`。新增目录时同步创建目录索引，并在上级索引中链接它。

## provides-search 找不到标签怎么办？

`provides` 是辅助标签，不是唯一入口。先全文搜索关键词：

```bash
rg "关键词" --include='*.md'
```

再读取候选文件 frontmatter 的 `synopsis/load/status` 判断是否相关。

## 我想接入一个具体业务，业务规则放哪里？

不要放进 Memento 核心仓库。按业务包标准放在你的项目中：

```text
your-project/
└── specs/
    ├── index.md
    ├── rules/
    └── references/
```

可参考 `examples/minimal-business-specs/`。

## 为什么公开仓库不放真实业务样例？

Memento 是通用框架。真实业务规范、平台 API、账号规则、生成产物都属于具体项目，公开仓库只保留模板、通用规则和脱敏示例。

## GitHub Actions 失败怎么本地复现？

```bash
bash scripts/install-hooks.sh
bash scripts/lint-knowledge-base.sh
python3 scripts/audit-agent-usability.py
bash scripts/self-check.sh
```

CI 与本地验证保持一致。

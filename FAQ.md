# FAQ

## 我 clone 后第一步做什么？

把仓库路径交给 Agent，让它读取 `AGENTS.md`。

```text
这是我的 Memento 仓库：/path/to/memento。请读取 AGENTS.md，以后按这里的规范维护知识库。
```

你不需要先学目录结构、frontmatter、索引或脚本。

## 我平时怎么用？

常见用法只有三类：

```text
消化 inbox
```

```text
以后发布内容前必须先校验
```

```text
帮我创建一个新的业务包
```

剩下的分类、补格式、建索引、校验、提交，由 Agent 按仓库规范处理。

## 具体业务规则放哪里？

不要放进 Memento 核心仓库。Memento 只保存通用治理规则。

具体业务放到你的项目里：

```text
your-project/
└── specs/
    ├── index.md
    ├── rules/
    └── references/
```

可参考 `examples/minimal-business-specs/`。

## 为什么公开仓库不放真实业务样例？

Memento 是通用框架。真实业务规范、平台 API、账号规则、生成产物都属于具体项目。

公开仓库只保留模板、通用规则和脱敏示例，避免把某个人的业务流程误当成框架本身。

## 我需要自己修 lint、frontmatter、wikilink 吗？

通常不需要。

如果 Agent 报这些问题，把报错原文交给 Agent，让它按 `AGENTS.md` 和 `规章制度/知识库管理/知识库内容治理规范/` 修复并验证。

## 我需要自己运行检查脚本吗？

日常使用不需要。

只有在你提交 PR、调试框架本身，或想确认仓库健康状态时，才需要看 `CONTRIBUTING.md` 里的验证步骤。

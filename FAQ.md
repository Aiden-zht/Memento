# FAQ

## 我 clone 后第一步做什么？

告诉你的 Agent：

```text
这是我的 Memento 仓库：/path/to/memento。请读取 AGENTS.md，以后按这里的规范工作。
```

你不需要先学目录结构、frontmatter、索引或脚本。

## 我平时怎么用？

只有三句话：

```text
消化 inbox
```

```text
以后 X 前必须先 Y
```

```text
帮我创建一个 Z 业务包
```

剩下的分类、补格式、建索引、校验、提交，由 Agent 按仓库规范处理。

有了新想法就对 Agent 说。Agent 会按仓库规范修改知识库、创建业务包、更新相关实现。

## 具体业务规则放哪里？

不要放进 Memento 核心仓库。Memento 只保存通用治理规则。

告诉 Agent "帮我创建一个 X 业务包"，Agent 会在你的项目中创建 `specs/` 结构。可参考 `examples/minimal-business-specs/`。

## 为什么公开仓库不放真实业务样例？

Memento 是通用框架。真实业务规范、平台 API、账号规则、生成产物都属于具体项目。

公开仓库只保留模板、通用规则和脱敏示例，避免把某个人的业务流程误当成框架本身。

## 我需要自己修问题吗？

不需要。遇到任何问题——lint 报错、断链、索引缺失——把报错原文交给 Agent，让它按 `AGENTS.md` 和规范修复。

## 我需要自己跑检查脚本吗？

不需要。Agent 会自己跑。

只有在你提交 PR 时才需要看 `CONTRIBUTING.md` 里的验证步骤。日常使用完全不需要。

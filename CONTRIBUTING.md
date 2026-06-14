# Contributing to Memento

Memento is an Agent-executable knowledge-base framework. Contributions should make the framework easier for a new human or Agent to clone, validate, and use.

## What belongs here

Good contributions:

- Governance rules under `规章制度/`
- Agent onboarding improvements in `AGENTS.md`, `README.md`, or `QUICKSTART.md`
- Validation scripts under `scripts/`
- Generic templates under `_templates/`
- Public-safe examples under `examples/`
- Troubleshooting and contributor documentation

Do not contribute:

- Private business content
- Real generated outputs
- Runtime state files such as JSON logs, caches, scores, or session traces
- Binary assets unless they are intentionally documented examples
- Secrets, tokens, local IPs, private paths, or vendor/account-specific material

## Before changing files

1. Read `AGENTS.md`.
2. Read `规章制度/知识库管理/任务类型索引.md`.
3. For governance changes, read the relevant file under `规章制度/知识库管理/知识库内容治理规范/`.

## Markdown file requirements

Every managed Markdown file must have YAML frontmatter with at least:

```yaml
title: "..."
date: "YYYY-MM-DD"
tags: [...]
category: "..."
load: on-demand
status: active
synopsis: "..."
version: 1
changelog: "initial"
```

For core rules under `规章制度/`, substantive content changes must increment `version` and update `changelog`.

## Validation

Run these before opening a pull request:

```bash
bash scripts/install-hooks.sh
bash scripts/lint-knowledge-base.sh
python3 scripts/audit-agent-usability.py
bash scripts/self-check.sh
```

Expected result:

- lint: zero errors
- audit: zero errors
- self-check: 8/8 after your changes are committed

Before commit, self-check may report Git dirty state. That is expected while files are still modified.

## Commit style

Use clear, scoped messages:

```text
docs: improve quickstart
ci: add validation workflow
governance: clarify business package discovery
scripts: make self-check branch agnostic
```

## Public-safety checklist

Before submitting, search for private residue:

```bash
rg "agent_mem|gitee|origin/master|/mnt/data|192\.168|真实平台名|私有项目名|token|secret" . --glob '! .git/**'
```

Any match must either be removed, generalized, or intentionally explained as a generic example.

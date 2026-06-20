#!/usr/bin/env python3
"""Audit whether the KB is safe and useful for Agent runtime loading.

This complements lint-knowledge-base.sh and self-check.sh. Lint checks
document hygiene; self-check checks structural health of formal
knowledge roots; this script checks runtime failure modes in formal
knowledge and entry documents.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FORMAL_ROOTS = {"规章制度", "产物规范", "专业知识", "素材库", "项目知识", "用户资料"}
ENTRY_DOCS = {
    Path("AGENTS.md"),
    Path("README.md"),
    Path("index.md"),
    Path("规章制度/知识库管理/任务类型索引.md"),
}
IGNORED_PREFIXES = (
    Path("_templates"),
    Path("docs/superpowers/specs"),
)
MD_FILES = []
for p in ROOT.rglob("*.md"):
    if ".git" in p.parts:
        continue
    relp = p.relative_to(ROOT)
    if any(relp == prefix or prefix in relp.parents for prefix in IGNORED_PREFIXES):
        continue
    if relp in ENTRY_DOCS or (relp.parts and relp.parts[0] in FORMAL_ROOTS):
        MD_FILES.append(p)

WIKI_RE = re.compile(r"\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]")
FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\n", re.S)


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def parse_frontmatter(text: str) -> dict[str, str]:
    match = FRONTMATTER_RE.match(text)
    if not match:
        return {}
    result: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if not line or line.startswith(" ") or line.startswith("-") or ":" not in line:
            continue
        key, value = line.split(":", 1)
        result[key.strip()] = value.strip().strip('"')
    return result


def line_no(text: str, needle: str) -> int:
    idx = text.find(needle)
    if idx < 0:
        return 1
    return text[:idx].count("\n") + 1


def target_path(raw_target: str) -> Path:
    target = raw_target.strip().lstrip("/")
    if target.endswith(".md"):
        return ROOT / target
    return ROOT / f"{target}.md"


def main() -> int:
    errors: list[str] = []
    warnings: list[str] = []

    frontmatter: dict[str, dict[str, str]] = {}
    texts: dict[str, str] = {}

    for path in MD_FILES:
        text = path.read_text(encoding="utf-8")
        key = rel(path)
        texts[key] = text
        frontmatter[key] = parse_frontmatter(text)

    for key, fm in frontmatter.items():
        path = ROOT / key
        text = texts[key]
        load = fm.get("load", "")
        status = fm.get("status", "")

        if status in {"draft", "scaffold", "deprecated"} and load in {"index", "always"}:
            warnings.append(f"W_AGENT_NONACTIVE_ENTRY {key}: {status} file uses load: {load}; only load explicitly for construction/maintenance tasks")

        for marker in ["[[完整路径]]", "[[路径]]", "[[链接]]", "[[wiki-link]]"]:
            if marker in text:
                errors.append(f"E_AGENT_PLACEHOLDER_LINK {key}:{line_no(text, marker)} placeholder wikilink must be plain text, not a real link")

    runtime_entries = {"AGENTS.md", "README.md", "index.md", "规章制度/知识库管理/任务类型索引.md"}
    for key, text in texts.items():
        fm = frontmatter[key]
        if key not in runtime_entries and not (fm.get("status") == "active" and fm.get("load") in {"default", "index"}):
            continue
        for raw_target in WIKI_RE.findall(text):
            target = target_path(raw_target)
            target_key = rel(target) if target.exists() else ""
            target_status = frontmatter.get(target_key, {}).get("status")
            if target_status in {"draft", "scaffold", "deprecated"}:
                warning_present = any(word in text for word in ["骨架", "不可用于生产", "默认不加载", "draft", "scaffold", "deprecated"])
                if not warning_present:
                    errors.append(
                        f"E_AGENT_ACTIVE_INDEX_TO_NONACTIVE {key}:{line_no(text, raw_target)} links {target_key} ({target_status}) without explicit non-production warning"
                    )

    print("Agent usability audit")
    print(f"ROOT {ROOT}")
    print(f"FILES {len(MD_FILES)}")
    print(f"ERRORS {len(errors)}")
    print(f"WARNINGS {len(warnings)}")
    for item in errors:
        print(item)
    for item in warnings:
        print(item)

    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())

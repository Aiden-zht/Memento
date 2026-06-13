#!/usr/bin/env python3
"""Audit whether the KB is safe and useful for Agent runtime loading.

This complements lint-knowledge-base.sh. Lint checks document hygiene;
this script checks common Agent-use failure modes: template leakage,
scaffold indexes pretending to be active, draft files linked from active
indexes without an explicit warning, and placeholder wiki-links.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MD_FILES = [p for p in ROOT.rglob("*.md") if ".git" not in p.parts]

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

    # ── E_AGENT_HOOK_MISSING: pre-commit hook not installed ──
    hook_path = ROOT / ".git" / "hooks" / "pre-commit"
    if not hook_path.is_file():
        errors.append(
            f"E_AGENT_HOOK_MISSING .git/hooks/pre-commit: pre-commit hook not installed; "
            f"run: bash scripts/install-hooks.sh"
        )

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

        if key.startswith("_templates/"):
            if load != "template":
                errors.append(f"E_AGENT_TEMPLATE_LOAD {key}: template file must use load: template")
            if status != "scaffold":
                errors.append(f"E_AGENT_TEMPLATE_STATUS {key}: template file must use status: scaffold")
            for required in ["synopsis", "version", "changelog"]:
                if not fm.get(required):
                    errors.append(f"E_AGENT_TEMPLATE_META {key}: missing {required}")

        if status in {"draft", "scaffold", "deprecated"} and load in {"index", "always"}:
            warnings.append(f"W_AGENT_NONACTIVE_ENTRY {key}: {status} file uses load: {load}; only load explicitly for construction/maintenance tasks")

        for marker in ["[[完整路径]]", "[[路径]]", "[[链接]]", "[[wiki-link]]"]:
            if marker in text:
                errors.append(f"E_AGENT_PLACEHOLDER_LINK {key}:{line_no(text, marker)} placeholder wikilink must be plain text, not a real link")

    for key, text in texts.items():
        fm = frontmatter[key]
        if fm.get("status") != "active" or fm.get("load") != "index":
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

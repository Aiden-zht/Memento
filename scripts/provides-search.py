#!/usr/bin/env python3
"""
provides-search — 辅助 provides 标签搜索工具

定位：
  本脚本用于已知 provides 标签、cron 固定依赖或 skill 依赖检查；常规任务主入口仍是任务索引 + 全文搜索 + synopsis 筛选。

解决：
  1. 不再用 rg "provides:.*标签" 正则 hack
  2. 一次调用返回所有匹配文件的完整 frontmatter
  3. 自动处理 YAML 格式差异（缩进列表、括号列表、混用）

用法：
  python3 scripts/provides-search.py 标签1 标签2 ...
  python3 scripts/provides-search.py 质量检查 示例业务
  python3 scripts/provides-search.py --files 标签名  # 仅输出文件路径
  python3 scripts/provides-search.py --synopsis 标签1 标签2  # 摘要模式：title + synopsis + provides + version + load

输出 JSON：

  {
    "query": ["质量检查", "示例业务"],
    "results": {
      "质量检查": [
        {"file": "...", "frontmatter": {...}, "matches": ["质量检查", "质量检查规则"]}
      ],
      "示例业务": [...]
    },
    "not_found": ["不存在的标签"],
    "summary": "2 files across 2 tags"
  }

--synopsis 模式输出更紧凑（用于 cron prompt 注入）：

  {
    "query": ["质量检查", "示例业务"],
    "results": {
      "质量检查": [
        {
          "file": "...",
          "title": "质量检查规则",
          "synopsis": "检查项目包括...",
          "provides": ["质量检查"],
          "version": 3,
          "load": "on-demand",
          "html_url": null
        }
      ]
    },
    "total": 2,
    "summary": "2 files across 2 tags"
  }
"""

import sys
import json
import yaml
from pathlib import Path

KB_ROOT = Path(__file__).resolve().parent.parent


def parse_frontmatter(filepath: Path) -> dict | None:
    """Extract YAML frontmatter from a markdown file."""
    text = filepath.read_text(encoding='utf-8')
    if not text.startswith('---'):
        return None
    end = text.find('---', 3)
    if end == -1:
        return None
    try:
        return yaml.safe_load(text[3:end])
    except yaml.YAMLError:
        return None


def extract_provides(fm: dict) -> list[str]:
    """Normalize provides field to a flat list of strings."""
    raw = fm.get('provides', [])
    if raw is None:
        return []
    if isinstance(raw, str):
        return [raw.strip()]
    if isinstance(raw, list):
        return [s.strip() for s in raw if isinstance(s, str)]
    return []


def search(tags: list[str], files_only: bool = False) -> dict:
    """Search all .md files for matching provides tags."""
    results: dict[str, list] = {tag: [] for tag in tags}
    seen_files: set[str] = set()

    for md_file in sorted(KB_ROOT.rglob('*.md')):
        # Skip hidden and template dirs
        rel = str(md_file.relative_to(KB_ROOT))
        if rel.startswith('.') or '/.' in rel or '_templates' in rel:
            continue

        fm = parse_frontmatter(md_file)
        if not fm:
            continue

        file_provides = extract_provides(fm)
        if not file_provides:
            continue

        for tag in tags:
            tag_lower = tag.lower()
            # Exact matches first, then substring matches
            exact = [p for p in file_provides if tag_lower == p.lower()]
            substring = [p for p in file_provides if tag_lower != p.lower() and tag_lower in p.lower()]
            matched = exact + substring
            if matched:
                entry = {
                    'file': rel,
                    'title': fm.get('title'),
                    'version': fm.get('version'),
                    'load': fm.get('load', 'on-demand'),
                    'status': fm.get('status'),
                    'changelog': fm.get('changelog', ''),
                    'matches': matched
                }
                if not files_only:
                    entry['provides_all'] = file_provides
                    entry['versions'] = fm.get('versions', {})
                    # Include a synopsis if available
                    if 'synopsis' in fm:
                        entry['synopsis'] = fm['synopsis']
                results[tag].append(entry)

    # Sort results per tag: exact match files first, then substring-only matches
    for tag in tags:
        def _sort_key(entry, _tag=tag):
            matches = entry.get('matches', [])
            has_exact = any(_tag.lower() == m.lower() for m in matches)
            # Exact match files get priority 0, substring-only get 1
            # Within same priority, prefer active status
            status_prio = 0 if entry.get('status') == 'active' else 1
            return (0 if has_exact else 1, status_prio, entry['file'])
        results[tag].sort(key=_sort_key)

    not_found = [tag for tag in tags if not results[tag]]
    total_files = len(set(
        r['file'] for tag_results in results.values() for r in tag_results
    ))

    return {
        'query': tags,
        'results': results,
        'not_found': not_found,
        'summary': f"{total_files} files across {len(tags)} tags"
    }


def search_synopsis(tags: list[str]) -> dict:
    """Compact synopsis output for cron prompt injection.

    Returns title + synopsis + provides + version + load per file.
    No full frontmatter — keeps output small enough to inject into a prompt.
    """
    raw = search(tags)
    results: dict[str, list] = {}
    total = 0
    for tag in tags:
        entries = []
        for r in raw['results'].get(tag, []):
            entries.append({
                'file': r['file'],
                'title': r.get('title'),
                'synopsis': r.get('synopsis'),
                'provides': r.get('provides_all', []),
                'version': r.get('version'),
                'load': r.get('load', 'on-demand'),
            })
            total += 1
        if entries:
            results[tag] = entries

    return {
        'query': tags,
        'results': results,
        'total': total,
        'summary': f"{total} files across {len(tags)} tags",
        'not_found': raw['not_found'],
    }


def list_all_tags() -> dict:
    """List all unique provides tags across the KB."""
    all_tags: set[str] = set()
    tag_files: dict[str, list[str]] = {}

    for md_file in sorted(KB_ROOT.rglob('*.md')):
        rel = str(md_file.relative_to(KB_ROOT))
        if rel.startswith('.') or '/.' in rel or '_templates' in rel:
            continue

        fm = parse_frontmatter(md_file)
        if not fm:
            continue

        for tag in extract_provides(fm):
            all_tags.add(tag)
            tag_files.setdefault(tag, []).append(rel)

    return {
        'total_tags': len(all_tags),
        'tags': sorted(all_tags),
        'tag_to_files': {t: tag_files[t] for t in sorted(all_tags)}
    }


def dump_tags_by_frequency() -> dict:
    """Dump all provides tags sorted by frequency (how many files use each)."""
    tag_files: dict[str, list[str]] = {}
    for md_file in sorted(KB_ROOT.rglob('*.md')):
        rel = str(md_file.relative_to(KB_ROOT))
        if rel.startswith('.') or '/.' in rel or '_templates' in rel:
            continue
        fm = parse_frontmatter(md_file)
        if not fm:
            continue
        for tag in extract_provides(fm):
            tag_files.setdefault(tag, []).append(rel)

    # Sort by frequency descending, then alphabetically
    sorted_tags = sorted(tag_files.items(), key=lambda x: (-len(x[1]), x[0]))
    return {
        'total_tags': len(sorted_tags),
        'by_frequency': [
            {'tag': tag, 'count': len(files), 'files': files}
            for tag, files in sorted_tags
        ]
    }


def check_index_consistency(index_path: str) -> dict:
    """Verify every provides tag in the task type index exists in actual KB files."""
    import re

    # Build set of all actual provides tags
    actual_tags: set[str] = set()
    for md_file in sorted(KB_ROOT.rglob('*.md')):
        rel = str(md_file.relative_to(KB_ROOT))
        if rel.startswith('.') or '/.' in rel or '_templates' in rel:
            continue
        fm = parse_frontmatter(md_file)
        if not fm:
            continue
        for tag in extract_provides(fm):
            actual_tags.add(tag)

    # Parse provides tags from task type index
    index_file = KB_ROOT / index_path
    if not index_file.exists():
        return {'error': f'Index file not found: {index_path}'}

    content = index_file.read_text(encoding='utf-8')

    # Match table rows: | task_name | tag1, tag2, ... | summary |
    # Only process the section before "关键文件速查" and "Agent 场景差异"
    main_section = content.split('## 关键文件速查')[0].split('## Agent 场景差异')[0]
    rows = re.findall(
        r'\|\s*[^|]+?\s*\|\s*([^|]{1,200}?)\s*\|\s*[^|]+\s*\|',
        main_section
    )

    referenced_tags: set[str] = set()
    for row in rows:
        # Skip header rows and summary-column rows (long prose)
        stripped = row.strip()
        if any(kw in stripped for kw in ['provides', '标签', '---', '说明', '摘要', '规则', '：', '；', '→', '//']):
            continue
        if len(stripped) > 120:
            continue  # Too long for a provides column — likely a 摘要 column
        for tag in re.split(r'[,，]', stripped):
            tag = tag.strip()
            # Filter: real provides tags are short identifiers, not sentences
            if tag and len(tag) < 40 and not any(c in tag for c in ['；', '：', '→', '。', '/', '\\']):
                referenced_tags.add(tag)

    ghosts = []
    found = []
    for tag in sorted(referenced_tags):
        tag_compact = tag.lower().replace(' ', '').replace('-', '').replace('_', '')
        matched = [a for a in actual_tags
                   if tag_compact in a.lower().replace(' ', '').replace('-', '').replace('_', '')
                   or a.lower().replace(' ', '').replace('-', '').replace('_', '') in tag_compact]
        if matched:
            found.append({'index_tag': tag, 'matched_in_kb': matched})
        else:
            ghosts.append(tag)

    return {
        'index_file': index_path,
        'tags_in_index': len(referenced_tags),
        'tags_found_in_kb': len(found),
        'ghost_tags': ghosts,
        'ghost_count': len(ghosts),
        'status': 'PASS' if not ghosts else 'FAIL'
    }


if __name__ == '__main__':
    args = sys.argv[1:]

    if not args or '--help' in args or '-h' in args:
        print(__doc__)
        sys.exit(0)

    if '--dump-tags' in args:
        print(json.dumps(dump_tags_by_frequency(), ensure_ascii=False, indent=2))
        sys.exit(0)

    if '--check-index' in args:
        idx_pos = args.index('--check-index')
        idx_path = args[idx_pos + 1] if idx_pos + 1 < len(args) else '规章制度/知识库管理/任务类型索引.md'
        print(json.dumps(check_index_consistency(idx_path), ensure_ascii=False, indent=2))
        sys.exit(0)

    if '--list' in args:
        print(json.dumps(list_all_tags(), ensure_ascii=False, indent=2))
        sys.exit(0)

    synopsis_mode = '--synopsis' in args
    files_only = '--files' in args or synopsis_mode  # synopsis implies files_only suppression of full fm
    tags = [a for a in args if not a.startswith('--')]

    if not tags:
        print(json.dumps(list_all_tags(), ensure_ascii=False, indent=2))
        sys.exit(0)

    if synopsis_mode:
        result = search_synopsis(tags)
        print(json.dumps(result, ensure_ascii=False, indent=2))
        sys.exit(0)

    result = search(tags, files_only=files_only)
    print(json.dumps(result, ensure_ascii=False, indent=2))

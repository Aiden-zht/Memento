---
title: "KB-执行层只读验收协议"
date: "2026-06-15"
tags: [知识库, 执行层对齐, 只读验收, requires_provides, kb_refresh_policy]
category: "规章制度/知识库管理"
load: on-demand
audience: [all]
provides: [KB-执行层只读验收协议, 执行层对齐, 只读验收, 规范变更闭环]
status: active
synopsis: "KB 规则变更后的最小只读验收协议：不进入执行层私有实现，只检查通用依赖和旧规则命中，输出 PASS/NOT_APPLICABLE/UNVERIFIED。"
version: 2
changelog: "[Agent自修] 新增执行层依赖文件清单，执行层对齐只对少数稳定依赖点触发"
---

# KB-执行层只读验收协议

> 本协议规定 KB 规则变更后，Agent 如何不侵入执行层私有实现的前提下，验证旧规则不再继续运行。
> 
> KB 只颁布规则，不管理执行层。本协议不要求登记具体 skill/cron/script/prompt 内容，只检查通用依赖和旧规则命中。

## 触发条件

修改以下内容后必须执行：

- [[规章制度/知识库管理/执行层依赖文件清单]] 中定义的全局依赖文件、项目入口、产物规范入口或被实现明确声明依赖的核心规则文件
- 目录结构、文件命名、frontmatter/provides/requires
- `kb_refresh_policy`、`load`、`status` 语义
- 项目契约、BLOCKING 规则、最低验证动作

## 验收范围（只读）

1. **KB 入口一致性**
   - [[规章制度/知识库管理/执行层依赖文件清单]] 中列出的入口文件，是否仍引用旧目录名、旧规则口径、已废弃的权威源。
2. **skill/cron 依赖声明**
   - 依赖 KB 的生产 skill/cron 是否在可见位置声明 `requires_provides` 与 `kb_refresh_policy: runtime`。
   - 不要求读取 skill 正文，只检查 frontmatter 依赖声明是否存在。
3. **scripts / role SOUL / prompt**
   - 扫描可访问的本地 scripts、profile SOUL、prompt 文件中是否存在会影响执行的旧词、旧路径、旧规则。
   - 不可访问的私有 profile、外部 repo 列为 UNVERIFIED，不强行突破。
4. **provides 命中**
   - 对于声明了 `requires_provides` 的本地实现，用 `python3 scripts/provides-search.py --synopsis <标签>` 验证 KB 中是否存在对应标签。

## 验收输出

每个检查项只能返回三种状态之一：

| 状态 | 含义 | 示例 |
|------|------|------|
| **PASS** | 已检查，未发现旧规则继续运行 | 入口索引已更新，本地 skill 声明了 `requires_provides` |
| **NOT_APPLICABLE** | 该本地实现不依赖被改动的规则，或不在本次验收范围内 | 某个不依赖 KB 的工具 skill；本次只改了写作规范，不涉及 cron 规范 |
| **UNVERIFIED** | 无法访问该执行资产，无法完成只读验收 | 私有 profile、外部 repo、无权限读取的远程环境 |

## 验收报告模板

```text
KB 规则变更只读验收报告
触发规则：<...>

1. KB 入口一致性
   - 检查范围：AGENTS.md, README.md, index.md, 任务能力索引, 强制规则索引
   - 旧词/旧路径命中：<...> / 无
   - 状态：PASS / NOT_APPLICABLE / UNVERIFIED

2. skill/cron 依赖声明
   - 检查范围：~/.hermes/skills/*/
   - requires_provides + kb_refresh_policy: runtime 命中：<...> / 无
   - 状态：PASS / NOT_APPLICABLE / UNVERIFIED

3. scripts / role SOUL / prompt
   - 检查范围：<...>
   - 旧词/旧路径命中：<...> / 无
   - 状态：PASS / NOT_APPLICABLE / UNVERIFIED

4. provides 命中
   - 检查标签：<...>
   - 命中结果：<...>
   - 状态：PASS / NOT_APPLICABLE / UNVERIFIED

综合结论：全部 PASS 才能声明规则变更完成；存在 UNVERIFIED 时必须在报告中说明不可访问范围。
```

## 约束

- 不得把具体 skill、cron、script、prompt 的私有内容写进 KB。
- 不得因为某个执行资产 UNVERIFIED 就阻止规则变更，但必须在完成报告中诊述。
- 不得用本协议替代对本地实现的真实修改和验证。

---

相关：[[规章制度/知识库管理/知识库内容治理规范/07-Agent行为约束]] · [[规章制度/知识库管理/任务类型索引]] · [[规章制度/知识库管理/执行层依赖文件清单]]

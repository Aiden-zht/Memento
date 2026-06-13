# Quick Start

**1. Fork 到自己的仓库**

点右上角 Fork。

**2. Clone 到本地**

```bash
git clone https://github.com/你的用户名/Memento.git
```

确保你的 Agent 能访问这个目录。

**3. 扔文章**

把任何文档拖进 `inbox/` 文件夹。

**4. 对 Agent 说**

先让它认识 Memento：

```
读一下 /path/to/Memento/AGENTS.md，以后按这里的规范工作
```

然后就可以用了：

```
消化 inbox
```

或者通过对话建立规范：

```
以后发布内容前必须先跑一遍校验
```

**5. 验证**

```bash
cd Memento && bash scripts/self-check.sh
```

8/8 = 一切正常。

---

不用学目录结构。不用写 frontmatter。不用管索引。

AI 自己搞定。

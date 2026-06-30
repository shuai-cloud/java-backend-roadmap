# Vim 📝

> Vim editor essentials for Java backend engineers.  
> Java 后端工程师必备的 Vim 编辑技能。

---

## 📖 Overview · 概览

This section covers the most useful Vim operations for daily editing tasks: navigating files, making quick edits, searching and replacing, and splitting windows. While Vim has a steep learning curve, mastering just 20% of its features will cover 80% of your needs.

本章涵盖日常编辑中最有用的 Vim 操作：文件导航、快速编辑、搜索替换和分屏操作。虽然 Vim 学习曲线陡峭，但掌握 20% 的功能就能满足 80% 的需求。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Modes · 模式

| Mode | Description · 说明 | How to Enter |
|------|--------------------|--------------|
| Normal | Default mode for navigation and commands · 默认模式，用于导航和执行命令 | `Esc` |
| Insert | Type text · 输入文本 | `i`（光标前插入）、`a`（光标后插入）、`o`（下方新行）、`O`（上方新行） |
| Visual | Select text · 选择文本 | `v`（字符选择）、`V`（行选择）、`Ctrl+v`（块选择） |
| Command | Execute commands (save, quit, etc.) · 执行命令（保存、退出等） | `:` |

**注意事项**：
- 任何时候不确定处于什么模式，按 `Esc` 回到 Normal 模式。
- Normal 模式下按 `:` 进入 Command 模式，执行完命令自动回到 Normal。

---

### 2️⃣ Navigation · 光标移动

| Key | Description · 说明 |
|-----|--------------------|
| `h` `j` `k` `l` | Left, Down, Up, Right · 左、下、上、右 |
| `w` `b` | Forward/backward by word · 按单词前进/后退 |
| `0` `$` | Beginning/end of line · 行首/行尾 |
| `^` | First non-blank character · 第一个非空字符 |
| `gg` `G` | Beginning/end of file · 文件开头/结尾 |
| `:n` | Go to line n · 跳转到第 n 行（如 `:42`） |
| `Ctrl+d` `Ctrl+u` | Page down/up half screen · 向下/上半页 |
| `Ctrl+f` `Ctrl+b` | Page down/up full screen · 向下/上整页 |
| `%` | Jump to matching bracket · 跳转到匹配的括号 |
| `zz` | Center cursor on screen · 将当前行居中 |

---

### 3️⃣ Editing · 编辑操作

| Key | Description · 说明 |
|-----|--------------------|
| `x` | Delete character under cursor · 删除光标处字符 |
| `dd` | Delete current line · 删除当前行 |
| `dw` | Delete word · 删除单词 |
| `d$` | Delete to end of line · 删除到行尾 |
| `yy` | Yank (copy) current line · 复制当前行 |
| `yw` | Yank word · 复制单词 |
| `p` | Paste after cursor · 粘贴到光标后 |
| `P` | Paste before cursor · 粘贴到光标前 |
| `u` | Undo · 撤销 |
| `Ctrl+r` | Redo · 重做 |
| `.` | Repeat last change · 重复上一次修改 |
| `r` | Replace single character · 替换单个字符 |
| `cc` | Change (replace) entire line · 修改整行 |
| `cw` | Change word · 修改单词 |

**注意事项**：
- 几乎所有删除/复制命令都可以配合数字使用，如 `3dd` 删除3行，`5yy` 复制5行。
- `u` 可多次撤销，`Ctrl+r` 恢复撤销。

---

### 4️⃣ Search & Replace · 搜索与替换

| Command | Description · 说明 |
|---------|--------------------|
| `/pattern` | Search forward · 向前搜索 |
| `?pattern` | Search backward · 向后搜索 |
| `n` | Repeat search in same direction · 重复搜索（相同方向） |
| `N` | Repeat search in opposite direction · 重复搜索（相反方向） |
| `*` | Search for word under cursor · 搜索光标下的单词 |
| `:%s/old/new/g` | Replace all occurrences in file · 全文件替换 |
| `:%s/old/new/gc` | Replace with confirmation · 替换前确认 |
| `:n,m s/old/new/g` | Replace in lines n to m · 在第 n 到 m 行替换 |

**注意事项**：
- 替换命令中可以使用正则表达式，如 `:%s/\<word\>/new/g` 精确匹配单词。
- `gc` 中的 `c` 表示 confirm，每次替换前会询问。

---

### 5️⃣ Saving & Exiting · 保存与退出

| Command | Description · 说明 |
|---------|--------------------|
| `:w` | Save · 保存 |
| `:w filename` | Save as · 另存为 |
| `:q` | Quit (if no changes) · 退出（未修改时） |
| `:q!` | Force quit without saving · 强制退出不保存 |
| `:wq` or `ZZ` | Save and quit · 保存并退出 |
| `:x` | Save and quit (same as :wq) · 保存并退出 |
| `:e!` | Discard changes and reload · 放弃修改重新加载 |

---

### 6️⃣ Multi-file Operations · 多文件操作

| Command | Description · 说明 |
|---------|--------------------|
| `:sp filename` | Split horizontally · 水平分屏打开文件 |
| `:vs filename` | Split vertically · 垂直分屏打开文件 |
| `Ctrl+w w` | Switch between splits · 切换分屏 |
| `Ctrl+w q` | Close current split · 关闭当前分屏 |
| `:tabnew filename` | Open in new tab · 在新标签页打开 |
| `gt` | Next tab · 下一个标签页 |
| `gT` | Previous tab · 上一个标签页 |
| `:bn` | Next buffer · 下一个缓冲区 |
| `:bp` | Previous buffer · 上一个缓冲区 |
| `:ls` | List buffers · 列出缓冲区 |
| `:bd` | Delete buffer · 删除缓冲区 |

---

### 7️⃣ Useful Configuration · 实用配置

将这些添加到 `~/.vimrc` 可以显著改善体验：

vim

" 基础设置

set number              " 显示行号

set relativenumber      " 相对行号（方便跳转）

set tabstop=4           " Tab 宽度 4

set shiftwidth=4        " 缩进宽度 4

set expandtab           " 将 Tab 转换为空格

set autoindent          " 自动缩进

set smartindent         " 智能缩进

set hlsearch            " 搜索结果高亮

set incsearch           " 实时搜索

set ignorecase          " 搜索忽略大小写

set smartcase           " 如果搜索包含大写则区分大小写

set mouse=a             " 启用鼠标支持

set clipboard=unnamedplus " 与系统剪贴板互通

syntax on               " 语法高亮

colorscheme desert      " 配色方案

" 快捷键映射

" 使用 jj 快速退出插入模式（避免按 Esc 太远）

inoremap jj <Esc>

" 使用 leader 键（默认为 \）保存文件

nnoremap <leader>w :w<CR>

---

## 🚀 Quick Reference · 速查示例

bash

打开文件

vim /etc/nginx/nginx.conf

快速跳转到第 42 行

:42

搜索 "error" 并高亮

/error

将所有 "localhost" 替换为 "127.0.0.1"

:%s/localhost/127.0.0.1/g

垂直分屏查看两个文件

:vs /etc/hosts

保存并退出

:wq

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating Vim operations in action.

---

## 🇨🇳 中文说明

本目录整理了 Vim 编辑器的核心操作，涵盖模式切换、光标移动、编辑、搜索替换、多文件操作和基础配置。每个操作都提供了中英文说明。  
建议在日常编辑中刻意练习，先从 `hjkl` 移动和 `dd`、`yy`、`p` 开始，逐步掌握更多技巧。

---

*Vim is not just an editor, it's a way of life.* ⌨️
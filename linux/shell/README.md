# Shell Scripting 🐚

> Bash scripting essentials for Java backend engineers.  
> Java 后端工程师必备的 Shell 脚本知识。

---

## 📖 Overview · 概览

This section covers Bash scripting fundamentals and best practices for automating daily tasks: deployment scripts, log analysis, health checks, backup routines, and CI/CD pipelines. Mastering shell scripting will save you hours of repetitive work and make you more productive.

本章涵盖 Bash 脚本基础知识和最佳实践，用于自动化日常任务：部署脚本、日志分析、健康检查、备份例程和 CI/CD 流水线。掌握 Shell 脚本能让你从重复劳动中解放出来，提高工作效率。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Variables & Quotes · 变量与引号

| Concept | Description · 说明 | Example |
|---------|--------------------|---------|
| Variable assignment | 变量赋值（等号两边不能有空格） | `name="world"` |
| Variable usage | 使用变量 | `echo "$name"` 或 `${name}` |
| Single quotes | 单引号：原样输出，不解析变量 | `echo '$name'` 输出 `$name` |
| Double quotes | 双引号：解析变量和转义 | `echo "Hello $name"` |
| Command substitution | 命令替换 | `now=$(date)` 或 `` now=`date` `` |
| Default values | 默认值 | `${var:-default}` 变量未设置时用默认值；`${var:=default}` 同时赋值 |

**注意事项**：
- 始终用双引号包裹变量，防止分词和通配符展开：`"$var"`。
- 使用 `${}` 形式更清晰，尤其在拼接字符串时：`${base}_${suffix}.log`。

---

### 2️⃣ String Operations · 字符串操作

| Operation | Description · 说明 | Example |
|-----------|--------------------|---------|
| Length | 字符串长度 | `${#str}` |
| Substring | 子串提取 | `${str:offset:length}` |
| Prefix removal | 删除前缀 | `${str#prefix}` 最短匹配；`${str##prefix}` 最长匹配 |
| Suffix removal | 删除后缀 | `${str%suffix}` 最短匹配；`${str%%suffix}` 最长匹配 |
| Replace | 替换 | `${str/old/new}` 替换第一个；`${str//old/new}` 替换全部 |
| Uppercase/Lowercase | 大小写转换 | `${str^^}` 大写；`${str,,}` 小写 |

---

### 3️⃣ Arrays · 数组

| Operation | Description · 说明 | Example |
|-----------|--------------------|---------|
| Define array | 定义数组 | `arr=("a" "b" "c")` |
| Access element | 访问元素 | `echo "${arr[0]}"` |
| All elements | 所有元素 | `echo "${arr[@]}"` |
| Array length | 数组长度 | `echo "${#arr[@]}"` |
| Iterate | 遍历 | `for item in "${arr[@]}"; do ... done` |

---

### 4️⃣ Conditionals · 条件判断

| Construct | Description · 说明 | Example |
|-----------|--------------------|---------|
| `if/then/elif/else/fi` | 条件分支 | `if [ "$age" -gt 18 ]; then ... fi` |
| `test` or `[ ]` | 文件测试、数值比较、字符串比较 | `[ -f "$file" ]` 文件存在；`[ "$a" = "$b" ]` 字符串相等；`[ "$num" -eq 10 ]` 数值相等 |
| `[[ ]]` | 增强版测试（支持正则、模式匹配） | `[[ "$str" == *.log ]]` 通配符；`[[ "$str" =~ ^[0-9]+$ ]]` 正则 |
| `&&` / `||` | 逻辑与/或（短路求值） | `[ -d "$dir" ] && echo "exists"` |
| `case/esac` | 多重分支 | `case "$1" in start) ... ;; stop) ... ;; *) ... ;; esac` |

**注意事项**：
- 数值比较用 `-eq`、`-ne`、`-lt`、`-le`、`-gt`、`-ge`。
- 字符串比较用 `=`、`!=`、`\<`、`\>`（需转义）。
- `[[ ]]` 比 `[ ]` 更安全，支持正则和空变量。

---

### 5️⃣ Loops · 循环

| Loop | Description · 说明 | Example |
|------|--------------------|---------|
| `for var in list` | 遍历列表 | `for i in {1..5}; do echo $i; done` |
| `for ((expr))` | C 风格 for 循环 | `for ((i=0; i<10; i++)); do ... done` |
| `while condition` | 条件循环 | `while read line; do echo $line; done < file` |
| `until condition` | 直到条件成立才停止 | `until ping -c1 host; do sleep 1; done` |
| `break` / `continue` | 跳出/继续循环 | 同其他语言 |

---

### 6️⃣ Functions · 函数

| Feature | Description · 说明 | Example |
|---------|--------------------|---------|
| Define function | 定义函数 | `function myfunc() { ... }` 或 `myfunc() { ... }` |
| Parameters | 参数（`$1`, `$2`, `$@`, `$*`, `$#`） | `echo "First arg: $1"` |
| Return value | 返回值（0-255，0 表示成功） | `return 1` |
| Local variables | 局部变量（`local`） | `local var="temp"` |
| Output capture | 捕获函数输出 | `result=$(myfunc arg1)` |

**注意事项**：
- 函数内的变量默认是全局的，使用 `local` 声明局部变量。
- 函数的 `return` 仅用于返回退出码，不要用它返回字符串，用 `echo` 输出并通过命令替换捕获。

---

### 7️⃣ Input & Output · 输入输出

| Feature | Description · 说明 | Example |
|---------|--------------------|---------|
| `read` | 从标准输入读取 | `read -p "Enter name: " name`；`-r` 不处理反斜杠 |
| `echo` | 输出到标准输出 | `echo "message"`；`-e` 启用转义（`\n` 换行） |
| `printf` | 格式化输出（更可控） | `printf "Name: %s, Age: %d\n" "$name" "$age"` |
| Here Document | 多行输入 | `cat <<EOF > file.txt ... EOF` |
| Here String | 字符串重定向 | `grep "error" <<< "$log_content"` |

---

### 8️⃣ Debugging & Error Handling · 调试与错误处理

| Technique | Description · 说明 | Example |
|-----------|--------------------|---------|
| `set -e` | 出错即退出（errexit） | `set -e` |
| `set -u` | 使用未定义变量时报错 | `set -u` |
| `set -x` | 打印每条命令（调试） | `set -x` |
| `set -o pipefail` | 管道中任一命令失败则整个管道失败 | `set -o pipefail` |
| `trap` | 捕获信号并执行清理 | `trap 'cleanup' EXIT`；`trap 'echo interrupted' INT` |
| `|| true` | 允许命令失败而不退出 | `some_command || true` |

**推荐的安全模式组合**：

bash

set -euo pipefail

---

### 9️⃣ Common Patterns · 常用模式

bash

1. 检查命令是否存在

if ! command -v java &>/dev/null; then

echo "Java not found"

exit 1

fi

2. 获取当前脚本所在目录

SCRIPT_DIR="(cd"(dirname "${BASH_SOURCE[0]}")" && pwd)"

3. 日志函数

log() {

echo "[(date
′
+*"

}

4. 临时文件处理

tempfile=$(mktemp)

trap 'rm -f "$tempfile"' EXIT

5. 并行执行

for cmd in "${commands[@]}"; do

($cmd) &

done

wait

6. 读取配置文件（key=value）

while IFS='=' read -r key value; do

[[ -z "key"∣∣"key" =~ ^# ]] && continue

export "key=value"

done < config.properties

---

## 🚀 Quick Reference · 速查示例

bash

检查 Java 进程是否存活

if pgrep -f "java -jar app.jar" > /dev/null; then

echo "Application is running"

else

echo "Application is down, restarting..."

nohup java -jar app.jar > app.log 2>&1 &

fi

统计日志中 ERROR 数量

count=$(grep -c "ERROR" app.log)

echo "Total errors: $count"

批量重命名 .log 文件为 .log.bak

for f in *.log; do

mv "f""{f}.bak"

done

健康检查脚本

check_health() {

local url="$1"

local status

status=(curl−s−o/dev/null−w"url")

if [ "$status" -eq 200 ]; then

return 0

else

return 1

fi

}

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these concepts in action.

---

## 🇨🇳 中文说明

本目录整理了 Bash 脚本的核心语法和常用模式，涵盖变量、字符串、数组、条件、循环、函数、输入输出、调试和错误处理。每个知识点都配有中英文说明和示例。  
建议在日常工作中多写脚本，将重复操作自动化，逐步积累自己的脚本库。

---

*Automate everything you can.* 🤖
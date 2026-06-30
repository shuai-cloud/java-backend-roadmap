#!/bin/bash
#
# demo.sh - Shell 脚本核心特性演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh
#

set -euo pipefail

echo "============================================"
echo "  Shell Scripting Demo"
echo "  场景：变量、条件、循环、函数、调试"
echo "============================================"

# ---------- 1. 变量与引号 ----------
echo -e "\n[1] 变量与引号"
APP_NAME="order-service"
PORT=8080
echo "  APP_NAME: $APP_NAME"
echo "  PORT: ${PORT}"
echo "  单引号不解析: '$APP_NAME'"
echo "  双引号解析: \"$APP_NAME\""

# ---------- 2. 字符串操作 ----------
echo -e "\n[2] 字符串操作"
STR="production-app.log"
echo "  原始字符串: $STR"
echo "  长度: ${#STR}"
echo "  去掉前缀 'production-': ${STR#production-}"
echo "  去掉后缀 '.log': ${STR%.log}"
echo "  替换 'app' 为 'service': ${STR/app/service}"

# ---------- 3. 数组 ----------
echo -e "\n[3] 数组"
SERVICES=("gateway" "order" "payment" "user")
echo "  服务列表: ${SERVICES[*]}"
echo "  第二个服务: ${SERVICES[1]}"
echo "  服务总数: ${#SERVICES[@]}"

# ---------- 4. 条件判断 ----------
echo -e "\n[4] 条件判断"
FILE="/etc/hosts"
if [ -f "$FILE" ]; then
    echo "  $FILE 存在"
else
    echo "  $FILE 不存在"
fi

NUM=42
if [[ $NUM -gt 40 && $NUM -lt 50 ]]; then
    echo "  $NUM 在 40 到 50 之间"
fi

# ---------- 5. 循环 ----------
echo -e "\n[5] 循环遍历数组"
for svc in "${SERVICES[@]}"; do
    echo "  服务: $svc"
done

echo "  C 风格 for 循环:"
for ((i=1; i<=3; i++)); do
    echo "  迭代 $i"
done

# ---------- 6. 函数 ----------
echo -e "\n[6] 函数"
greet() {
    local name="$1"
    echo "  Hello, $name!"
}
greet "Java Developer"

# 带返回值的函数
is_even() {
    local num=$1
    if (( num % 2 == 0 )); then
        return 0
    else
        return 1
    fi
}
if is_even 10; then
    echo "  10 是偶数"
fi

# ---------- 7. 输入输出 ----------
echo -e "\n[7] 输入输出"
echo "  请输入你的名字: "
read -r USER_NAME
echo "  你好, $USER_NAME!"

printf "  格式化输出: %s - %d\n" "order-service" 8080

# ---------- 8. 调试模式演示（仅打印一条命令） ----------
echo -e "\n[8] 调试模式（set -x）"
set -x
echo "  这条命令会被打印出来"
set +x

# ---------- 9. 错误处理 ----------
echo -e "\n[9] 错误处理（set -e 已启用）"
echo "  尝试执行一个可能失败的命令..."
false || echo "  命令失败了，但脚本继续执行（因为用了 ||）"

# ---------- 10. 实用模式：读取配置文件 ----------
echo -e "\n[10] 模拟读取配置文件"
CONFIG_FILE="/tmp/app_config.properties"
cat > "$CONFIG_FILE" <<EOF
# Application Config
DB_HOST=localhost
DB_PORT=3306
APP_ENV=production
EOF

while IFS='=' read -r key value; do
    # 跳过空行和注释
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    # 去除首尾空格
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    declare "$key=$value"
    echo "  加载配置: $key=$value"
done < "$CONFIG_FILE"

echo "  DB_HOST=$DB_HOST, DB_PORT=$DB_PORT"

# 清理
rm -f "$CONFIG_FILE"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"
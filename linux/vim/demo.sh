#!/bin/bash
#
# demo.sh - Vim 操作演示脚本
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（生成示例文件供练习）
#

set -euo pipefail

echo "============================================"
echo "  Vim Operations Demo"
echo "  场景：生成示例文件供 Vim 练习"
echo "============================================"

# ---------- 1. 创建临时工作目录 ----------
WORKDIR="/tmp/vim_demo"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# ---------- 2. 生成一个 Java 示例文件 ----------
echo -e "\n[1] 生成 Java 示例文件 Sample.java"
cat > Sample.java <<'EOF'
public class Sample {
    private String name;
    private int age;

    public Sample(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public void sayHello() {
        System.out.println("Hello, " + name);
    }

    public static void main(String[] args) {
        Sample sample = new Sample("World", 25);
        sample.sayHello();
    }
}
EOF
echo "  已生成 Sample.java"

# ---------- 3. 生成一个配置文件 ----------
echo -e "\n[2] 生成 Nginx 配置文件 nginx.conf"
cat > nginx.conf <<'EOF'
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
    }

    location /api/ {
        proxy_pass http://backend:9000;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF
echo "  已生成 nginx.conf"

# ---------- 4. 生成一个日志文件 ----------
echo -e "\n[3] 生成日志文件 app.log"
for i in $(seq 1 20); do
    echo "2025-03-15 10:$(printf '%02d' $((i % 60))):00 INFO Request processed in ${RANDOM}ms" >> app.log
done
echo "  已生成 app.log（20行）"

# ---------- 5. 生成一个 CSV 文件 ----------
echo -e "\n[4] 生成数据文件 data.csv"
cat > data.csv <<'EOF'
id,name,email,score
1,Alice,alice@example.com,95
2,Bob,bob@example.com,87
3,Charlie,charlie@example.com,92
4,Diana,diana@example.com,78
EOF
echo "  已生成 data.csv"

# ---------- 6. 生成一个 Vim 练习指南 ----------
echo -e "\n[5] 生成 Vim 练习指南 practice_guide.txt"
cat > practice_guide.txt <<'EOF'
Vim 练习指南
============

请按以下步骤练习：

1. 打开 Sample.java:  vim Sample.java
2. 练习移动: hjkl, w, b, 0, $, gg, G
3. 练习删除: dd, dw, d$, x
4. 练习复制粘贴: yy, p, P
5. 练习搜索: /name, ?public
6. 练习替换: :%s/World/Java/g
7. 练习分屏: :vs nginx.conf
8. 练习保存退出: :wq

提示: 按 Esc 回到 Normal 模式
EOF
echo "  已生成 practice_guide.txt"

# ---------- 7. 显示文件列表 ----------
echo -e "\n[6] 生成的文件列表:"
ls -lh "$WORKDIR"

# ---------- 8. 提示练习 ----------
echo -e "\n[7] 开始练习！使用以下命令打开文件:"
echo "  vim Sample.java"
echo "  vim nginx.conf"
echo "  vim app.log"
echo "  vim data.csv"
echo ""
echo "  或阅读练习指南: cat practice_guide.txt"

echo -e "\n============================================"
echo "  文件已生成在 $WORKDIR"
echo "  练习完后可删除: rm -rf $WORKDIR"
echo "============================================"
#!/bin/bash
#
# demo.sh - Linux 服务管理命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux Service Commands Demo"
echo "  场景：systemd 服务管理、日志查看、定时器"
echo "============================================"

# ---------- 1. 查看系统所有运行中的服务 ----------
echo -e "\n[1] 使用 systemctl list-units 查看运行中的服务（仅显示前5行）"
systemctl list-units --type=service --state=running 2>/dev/null | head -6 || echo "  systemctl 不可用"

# ---------- 2. 查看特定服务状态 ----------
echo -e "\n[2] 查看 sshd 服务状态"
if systemctl is-active sshd &>/dev/null; then
    systemctl status sshd --no-pager 2>/dev/null | head -10
else
    echo "  sshd 服务未运行或不存在"
fi

# ---------- 3. 查看服务日志 ----------
echo -e "\n[3] 查看 sshd 服务最近 5 条日志"
journalctl -u sshd -n 5 --no-pager 2>/dev/null || echo "  journalctl 不可用或无日志"

# ---------- 4. 创建一个临时的测试服务 ----------
echo -e "\n[4] 创建一个测试服务（需要 sudo）"
TEST_SERVICE="/etc/systemd/system/test-demo.service"
if sudo -n true 2>/dev/null; then
    # 创建服务文件
    sudo bash -c "cat > $TEST_SERVICE" <<'EOF'
[Unit]
Description=Test Demo Service
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/echo "Hello from test-demo service"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    echo "  服务文件已创建: $TEST_SERVICE"

    # 重新加载并启动
    sudo systemctl daemon-reload
    sudo systemctl start test-demo.service
    echo "  服务已启动"

    # 查看状态
    sudo systemctl status test-demo.service --no-pager | head -8

    # 清理
    sudo systemctl stop test-demo.service 2>/dev/null || true
    sudo systemctl disable test-demo.service 2>/dev/null || true
    sudo rm -f "$TEST_SERVICE"
    sudo systemctl daemon-reload
    echo "  测试服务已清理"
else
    echo "  无 sudo 权限，跳过服务创建演示"
fi

# ---------- 5. 查看所有定时器 ----------
echo -e "\n[5] 查看系统中所有定时器"
systemctl list-timers --no-pager 2>/dev/null | head -10 || echo "  无定时器或 systemctl 不可用"

# ---------- 6. 检查服务是否启用开机自启 ----------
echo -e "\n[6] 检查 crond 服务是否开机自启"
if systemctl is-enabled crond &>/dev/null; then
    echo "  crond 开机自启状态: $(systemctl is-enabled crond)"
else
    echo "  crond 服务不存在"
fi

# ---------- 7. 模拟 supervisor 检查（如果安装了 supervisor） ----------
echo -e "\n[7] 检查 supervisor 是否可用"
if command -v supervisorctl &>/dev/null; then
    supervisorctl status 2>/dev/null || echo "  supervisor 未配置任何进程"
else
    echo "  supervisor 未安装"
fi

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"
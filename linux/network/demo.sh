#!/bin/bash
#
# demo.sh - Linux 网络命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令可能需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux Network Commands Demo"
echo "  场景：网络接口、端口、连通性、DNS、抓包"
echo "============================================"

# ---------- 1. 查看网络接口 ----------
echo -e "\n[1] 使用 ip addr 查看网络接口（仅显示前10行）"
ip addr 2>/dev/null | head -10 || echo "  ip 命令不可用"

# ---------- 2. 查看监听端口 ----------
echo -e "\n[2] 使用 ss -tlnp 查看 TCP 监听端口（仅显示前5行）"
ss -tlnp 2>/dev/null | head -6 || echo "  ss 命令不可用"

# ---------- 3. 测试连通性 ----------
echo -e "\n[3] 使用 ping 测试百度连通性（发送2个包）"
ping -c 2 -W 2 baidu.com 2>/dev/null || echo "  ping 失败（可能被屏蔽或网络不通）"

# ---------- 4. 测试端口 ----------
echo -e "\n[4] 使用 nc 测试本地 22 端口（SSH）是否开放"
nc -zv 127.0.0.1 22 2>&1 || echo "  nc 不可用或端口未开放"

# ---------- 5. 使用 curl 测试 HTTP ----------
echo -e "\n[5] 使用 curl 测试 httpbin.org（仅获取响应头）"
curl -I -s --connect-timeout 3 https://httpbin.org/get 2>/dev/null | head -5 || echo "  curl 失败（网络问题）"

# ---------- 6. DNS 解析 ----------
echo -e "\n[6] 使用 dig 查询 github.com 的 A 记录"
dig +short github.com 2>/dev/null || echo "  dig 不可用"

# ---------- 7. 使用 getent 查询 hosts ----------
echo -e "\n[7] 使用 getent hosts 查询 localhost"
getent hosts localhost

# ---------- 8. 路由跟踪 ----------
echo -e "\n[8] 使用 tracepath 跟踪到百度（仅跳数，不解析域名）"
tracepath -n baidu.com 2>/dev/null | head -5 || echo "  tracepath 不可用"

# ---------- 9. 抓包演示（需要 sudo） ----------
echo -e "\n[9] 尝试抓取本地回环接口的 2 个包（需要 sudo）"
if sudo -n true 2>/dev/null; then
    sudo tcpdump -i lo -c 2 -nn 2>/dev/null || echo "  tcpdump 执行失败"
else
    echo "  无 sudo 权限，跳过抓包演示"
fi

# ---------- 10. 查看防火墙状态 ----------
echo -e "\n[10] 查看防火墙状态"
if command -v firewall-cmd &>/dev/null; then
    sudo firewall-cmd --state 2>/dev/null || echo "  firewalld 未运行"
elif command -v iptables &>/dev/null; then
    sudo iptables -L -n --line-numbers 2>/dev/null | head -5 || echo "  iptables 不可用"
else
    echo "  未检测到防火墙工具"
fi

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"
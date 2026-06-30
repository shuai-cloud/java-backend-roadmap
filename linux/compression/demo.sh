#!/bin/bash
#
# demo.sh - 压缩归档命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh
#

set -euo pipefail

echo "============================================"
echo "  Linux Compression & Archive Demo"
echo "  场景：tar、gzip、zip、rsync 模拟"
echo "============================================"

# ---------- 1. 创建临时工作目录和测试文件 ----------
WORKDIR="/tmp/compression_demo"
mkdir -p "$WORKDIR"/source
cd "$WORKDIR"

echo -e "\n[1] 创建测试文件"
for i in {1..3}; do
    echo "This is log file $i. Some content here." > "source/log_$i.log"
done
echo "  已创建 3 个测试文件"

# ---------- 2. 使用 tar 创建归档 ----------
echo -e "\n[2] 使用 tar 创建归档"
tar -cvf archive.tar source/ 2>/dev/null
echo "  已创建 archive.tar"
ls -lh archive.tar

# ---------- 3. 使用 tar + gzip 压缩 ----------
echo -e "\n[3] 使用 tar -czf 创建压缩归档"
tar -czf archive.tar.gz source/
echo "  已创建 archive.tar.gz"
ls -lh archive.tar.gz

# ---------- 4. 使用 tar + bzip2 压缩 ----------
echo -e "\n[4] 使用 tar -cjf 创建 bzip2 压缩归档"
tar -cjf archive.tar.bz2 source/
echo "  已创建 archive.tar.bz2"
ls -lh archive.tar.bz2

# ---------- 5. 使用 tar + xz 压缩 ----------
echo -e "\n[5] 使用 tar -cJf 创建 xz 压缩归档"
tar -cJf archive.tar.xz source/
echo "  已创建 archive.tar.xz"
ls -lh archive.tar.xz

# ---------- 6. 对比压缩率 ----------
echo -e "\n[6] 压缩率对比"
echo "  tar:         $(du -h archive.tar | cut -f1)"
echo "  tar.gz:      $(du -h archive.tar.gz | cut -f1)"
echo "  tar.bz2:     $(du -h archive.tar.bz2 | cut -f1)"
echo "  tar.xz:      $(du -h archive.tar.xz | cut -f1)"

# ---------- 7. 列出归档内容 ----------
echo -e "\n[7] 列出归档内容"
tar -tzf archive.tar.gz

# ---------- 8. 解压归档 ----------
echo -e "\n[8] 解压 tar.gz 到 extract 目录"
mkdir -p extract
tar -xzf archive.tar.gz -C extract/
echo "  已解压到 extract/"
ls -lh extract/

# ---------- 9. 使用 zip ----------
echo -e "\n[9] 使用 zip 创建跨平台压缩包"
zip -r archive.zip source/ 2>/dev/null
echo "  已创建 archive.zip"
ls -lh archive.zip

# ---------- 10. 使用 gzip 压缩单个文件 ----------
echo -e "\n[10] 使用 gzip 压缩单个文件"
cp source/log_1.log .
gzip -k log_1.log
echo "  已创建 log_1.log.gz"
ls -lh log_1.log*

# ---------- 11. 模拟 rsync（本地） ----------
echo -e "\n[11] 模拟 rsync 同步（本地）"
mkdir -p backup
rsync -avz source/ backup/ 2>/dev/null
echo "  已同步到 backup/"
ls -lh backup/

# ---------- 12. 清理 ----------
echo -e "\n[12] 清理临时文件"
rm -rf "$WORKDIR"
echo "  已删除 $WORKDIR"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"
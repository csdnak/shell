#!/bin/bash

# 设定要控制的目标目录
TARGET_DIR="/data"

# 设定目标磁盘占用比例(比如 50 表示 50%)
TARGET_USAGE=$1

# 计算当前磁盘信息
CURRENT_USAGE=$(df "${TARGET_DIR}" | awk 'NR==2 {print $5}' | sed 's/%//')
TOTAL_SPACE=$(df "${TARGET_DIR}" | awk 'NR==2 {print $2}')
USED_SPACE=$(df "${TARGET_DIR}" | awk 'NR==2 {print $3}')

# 计算需要填充的空间
TARGET_SPACE=$(echo "scale=0; (${TOTAL_SPACE} * ${TARGET_USAGE}/100 - ${USED_SPACE})/1024" | bc)

# 创建填充文件以增加磁盘占用
if [ "${TARGET_SPACE}" -gt "0" ]; then
    echo "Creating filler file to occupy ${TARGET_SPACE}M"
    dd if=/dev/zero of="${TARGET_DIR}/filler_file" bs=1M count=${TARGET_SPACE}
else
    echo "Disk usage is already at or above target."
fi


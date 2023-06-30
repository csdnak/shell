#!/bin/bash

read -p "请输入要占用的cpu使用率（写整数即可，别加%）：" numb

# 设置占用率参数（取值范围：0-100）
cpu_usage_percentage=$numb

# 计算要占用的 CPU 核心数量（使用 50% 的占用率，假设每个 CPU 核心有两个线程）
cpu_cores=$(($(nproc) * $cpu_usage_percentage / 100))

# 启动占用 CPU 的任务
for ((cpu=0; cpu<cpu_cores; cpu++))
do
    while : ; do
        :
    done &
done

echo "已启动动态占用 CPU，占用率为 $cpu_usage_percentage%"

# 按任意键停止占用 CPU 的任务
# read -n 1 -s -r -p "按任意键停止占用 CPU..."

# 结束占用 CPU 的任务
# killall -9 cpu.sh

# echo "已停止动态占用 CPU"

# exit 0


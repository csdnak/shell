#!/bin/bash

# 最小和最大触发间隔时间（单位：秒）
MIN_INTERVAL=5
MAX_INTERVAL=30

# 最小和最大占用持续时间（单位：秒）
MIN_DURATION=60
MAX_DURATION=300

# 目标 CPU 使用率（百分比）
TARGET_CPU_USAGE=${1:-50}

cpu_load() {
  while true; do
    # 生成随机的触发间隔时间和占用持续时间
    interval=$(( RANDOM % (MAX_INTERVAL - MIN_INTERVAL + 1) + MIN_INTERVAL ))
    duration=$(( RANDOM % (MAX_DURATION - MIN_DURATION + 1) + MIN_DURATION ))

    # 计算占用 CPU 的进程数量
    cpu_cores=$(nproc)
    stress_processes=$(( (TARGET_CPU_USAGE * cpu_cores) / 100 ))

    # 打印信息
    echo "Next CPU usage will start in $interval seconds and last for $duration seconds."
    echo "Target CPU usage: $TARGET_CPU_USAGE%"

    # 等待触发间隔时间
    sleep $interval

    # 启动占用 CPU 的进程
    echo "Start CPU usage..."
    for (( i=0; i<stress_processes; i++ )); do
      (
        end_time=$(( $(date +%s) + duration ))
        while [[ $(date +%s) -lt $end_time ]]; do
          :
        done
      ) &
    done

    # 等待所有进程结束
    wait

    # 停止占用 CPU 的进程
    echo "Stop CPU usage..."
  done
}

cpu_load


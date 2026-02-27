#!/bin/bash
# Top进程API - 显示CPU/内存占用最高的进程

echo "{"
echo "  \"topCpu\": ["

# 获取Top 5 CPU占用进程
ps aux --sort=-%cpu | head -6 | tail -5 | awk 'BEGIN {first=1} {if(!first) printf ","; printf "{\"pid\":%s,\"user\":\"%s\",\"cpu\":%.1f,\"mem\":%.1f,\"cmd\":\"%s\"}", $2, $1, $3, $4, $11; first=0}'

echo "],"
echo "  \"topMem\": ["

# 获取Top 5 内存占用进程
ps aux --sort=-%mem | head -6 | tail -5 | awk 'BEGIN {first=1} {if(!first) printf ","; printf "{\"pid\":%s,\"user\":\"%s\",\"cpu\":%.1f,\"mem\":%.1f,\"cmd\":\"%s\"}", $2, $1, $3, $4, $11; first=0}'

echo "],"

# 获取系统负载
LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
echo "  \"load\": \"$LOAD\","

# 获取运行进程数
echo "  \"totalProcesses\": $(ps aux | wc -l),"

# 获取运行时间
echo "  \"uptime\": \"$(uptime -p)\","

echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

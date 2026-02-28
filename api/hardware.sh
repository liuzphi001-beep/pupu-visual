#!/bin/bash
# 硬件和IO状态API - 显示硬件信息和IO统计

echo "{"
echo "  \"cpu\": {"
echo "    \"model\": \"$(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | xargs)\","
echo "    \"cores\": $(nproc),"
echo "    \"freq\": \"$(cat /proc/cpuinfo | grep 'cpu MHz' | head -1 | cut -d: -f2 | xargs) MHz\""
echo "  },"

# 内存详情
echo "  \"memory\": {"
echo "    \"total\": $(free -b | grep Mem | awk '{print $2}'),"
echo "    \"used\": $(free -b | grep Mem | awk '{print $3}'),"
echo "    \"free\": $(free -b | grep Mem | awk '{print $4}'),"
echo "    \"available\": $(free -b | grep Mem | awk '{print $7}'),"
echo "    \"percent\": $(free | grep Mem | awk '{print " "$3*100/$2}' | xargs printf "%.0f")"
echo "  },"

# Swap
echo "  \"swap\": {"
echo "    \"total\": $(free -b | grep Swap | awk '{print $2}'),"
echo "    \"used\": $(free -b | grep Swap | awk '{print $3}'),"
echo "    \"free\": $(free -b | grep Swap | awk '{print $4}')"
echo "  },"

# IO统计
echo "  \"io\": {"
IOSTAT=$(iostat 1 1 2>/dev/null | tail -1)
if [ -n "$IOSTAT" ]; then
    echo "    \"tps\": $(echo $IOSTAT | awk '{print $2}'),"
    echo "    \"read\": $(echo $IOSTAT | awk '{print $3}'),"
    echo "    \"write\": $(echo $IOSTAT | awk '{print $4}')"
else
    echo "    \"tps\": 0,"
    echo "    \"read\": 0,"
    echo "    \"write\": 0"
fi
echo "  },"

# 磁盘详情
echo "  \"disk\": ["
df -h | grep -E "^/dev" | while read line; do
    DEV=$(echo $line | awk '{print $1}')
    SIZE=$(echo $line | awk '{print $2}')
    USED=$(echo $line | awk '{print $3}')
    AVAIL=$(echo $line | awk '{print $4}')
    USE=$(echo $line | awk '{print $5}')
    echo "    {\"device\":\"$DEV\",\"size\":\"$SIZE\",\"used\":\"$USED\",\"available\":\"$AVAIL\",\"usePercent\":\"$USE\"},"
done | sed 's/,$//'
echo "  ],"

# 网络接口 - 使用ls /sys/class/net/
echo "  \"network\": ["
for IFACE in $(ls /sys/class/net/ 2>/dev/null | grep -v lo); do
    STATE=$(cat /sys/class/net/$IFACE/operstate 2>/dev/null || echo "unknown")
    RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes 2>/dev/null || echo 0)
    TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes 2>/dev/null || echo 0)
    echo "    {\"interface\":\"$IFACE\",\"state\":\"$STATE\",\"rx\":$RX,\"tx\":$TX},"
done | sed 's/,$//'
echo "  ],"

# 负载
echo "  \"load\": {"
echo "    \"1min\": $(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs),"
echo "    \"5min\": $(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f2 | xargs),"
echo "    \"15min\": $(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f3 | xargs)"
echo "  },"

echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

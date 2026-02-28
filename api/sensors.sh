#!/bin/bash
# 传感器和健康状态API

# 内存
MEM_USED=$(free -h | grep Mem | awk '{print $3}')
MEM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
MEM_PCT=$(free | grep Mem | awk '{print int($3*100/$2)}')

# 负载
LOAD_1=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
LOAD_5=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f2 | xargs)
LOAD_15=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f3 | xargs)

# 运行时间
UPTIME_SEC=$(cat /proc/uptime | awk '{print int($1)}')
UPTIME_DAYS=$((UPTIME_SEC / 86400))
UPTIME_HOURS=$(( (UPTIME_SEC % 86400) / 3600 ))

# 进程
PROC_TOTAL=$(ps aux 2>/dev/null | wc -l || echo 0)

# 健康状态
LOAD_VAL=$(echo "$LOAD_1" | sed 's/\..*//')
if [ -z "$LOAD_VAL" ] || [ "$LOAD_VAL" -gt 5 ]; then
    HEALTH_STATUS="critical"
elif [ "$LOAD_VAL" -gt 2 ]; then
    HEALTH_STATUS="warning"
else
    HEALTH_STATUS="healthy"
fi

echo "{"
echo "  \"memory\": {"
echo "    \"used\": \"$MEM_USED\","
echo "    \"total\": \"$MEM_TOTAL\","
echo "    \"percent\": $MEM_PCT"
echo "  },"
echo "  \"load\": {"
echo "    \"1min\": \"$LOAD_1\","
echo "    \"5min\": \"$LOAD_5\","
echo "    \"15min\": \"$LOAD_15\""
echo "  },"
echo "  \"uptime\": {"
echo "    \"days\": $UPTIME_DAYS,"
echo "    \"hours\": $UPTIME_HOURS,"
echo "    \"totalSeconds\": $UPTIME_SEC"
echo "  },"
echo "  \"processes\": $PROC_TOTAL,"
echo "  \"health\": {"
echo "    \"status\": \"$HEALTH_STATUS\","
echo "    \"cpuLoad\": \"$LOAD_1\","
echo "    \"memoryPercent\": $MEM_PCT"
echo "  },"
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

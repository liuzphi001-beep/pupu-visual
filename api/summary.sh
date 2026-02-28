#!/bin/bash
# 看板汇总API - 一键获取所有关键数据

# 获取基础状态
source /root/.openclaw/workspace/project/pupu-visual/api/status.sh 2>/dev/null
STATUS_JSON=$(bash /root/.openclaw/workspace/project/pupu-visual/api/status.sh 2>/dev/null)

# 获取服务状态
SERVICES_JSON=$(bash /root/.openclaw/workspace/project/pupu-visual/api/services.sh 2>/dev/null)

# 获取硬件信息
HARDWARE_JSON=$(bash /root/.openclaw/workspace/project/pupu-visual/api/hardware.sh 2>/dev/null)

# 解析关键数据
CPU=$(echo "$STATUS_JSON" | grep '"cpu"' | head -1 | grep -o '[0-9.]*' | head -1)
MEM_PCT=$(echo "$STATUS_JSON" | grep '"percent"' | head -1 | grep -o '[0-9]*' | head -1)
DISK=$(echo "$STATUS_JSON" | grep '"disk"' | head -1 | grep -o '[0-9]*' | head -1)
LOAD=$(echo "$STATUS_JSON" | grep '"load"' | head -1 | grep -o '[0-9.]*' | head -1)
UPTIME=$(echo "$STATUS_JSON" | grep '"uptime"' | head -1 | sed 's/.*"uptime": *"\([^"]*\)".*/\1/')
SKILLS=$(echo "$STATUS_JSON" | grep '"skills"' | head -1 | grep -o '[0-9]*' | head -1)

# CPU型号
CPU_MODEL=$(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d: -f2 | xargs)

# 内存详情
MEM_USED=$(free -h | grep Mem | awk '{print $3}')
MEM_TOTAL=$(free -h | grep Mem | awk '{print $2}')

# 网络流量
NET_RX=$(echo "$STATUS_JSON" | grep '"rx"' | head -1 | grep -o '[0-9]*' | head -1)
NET_TX=$(echo "$STATUS_JSON" | grep '"tx"' | head -1 | grep -o '[0-9]*' | head -1)

# 计算健康分数
HEALTH_SCORE=100
if [ ! -z "$CPU" ]; then
    CPU_INT=$(echo "$CPU" | cut -d. -f1)
    if [ "$CPU_INT" -gt 80 ]; then
        HEALTH_SCORE=$((HEALTH_SCORE - 30))
    elif [ "$CPU_INT" -gt 50 ]; then
        HEALTH_SCORE=$((HEALTH_SCORE - 15))
    fi
fi

if [ ! -z "$MEM_PCT" ]; then
    if [ "$MEM_PCT" -gt 80 ]; then
        HEALTH_SCORE=$((HEALTH_SCORE - 30))
    elif [ "$MEM_PCT" -gt 60 ]; then
        HEALTH_SCORE=$((HEALTH_SCORE - 15))
    fi
fi

if [ ! -z "$DISK" ]; then
    if [ "$DISK" -gt 90 ]; then
        HEALTH_SCORE=$((HEALTH_SCORE - 30))
    elif [ "$DISK" -gt 75 ]; then
        HEALTH_SCORE=$((HEALTH_SCORE - 15))
    fi
fi

# 运行天数
UPTIME_SEC=$(cat /proc/uptime | awk '{print int($1)}')
DAYS=$((UPTIME_SEC / 86400))
HOURS=$(( (UPTIME_SEC % 86400) / 3600 ))

# 输出汇总JSON
echo "{"
echo "  \"summary\": {"
echo "    \"cpu\": \"$CPU%\","
echo "    \"cpuModel\": \"$CPU_MODEL\","
echo "    \"memory\": \"$MEM_USED/$MEM_TOTAL\","
echo "    \"memoryPercent\": $MEM_PCT,"
echo "    \"diskPercent\": $DISK,"
echo "    \"load\": \"$LOAD\","
echo "    \"uptime\": \"${DAYS}天${HOURS}小时\","
echo "    \"uptimeDays\": $DAYS,"
echo "    \"skills\": $SKILLS,"
echo "    \"healthScore\": $HEALTH_SCORE,"
echo "    \"network\": {"
echo "      \"rx\": $NET_RX,"
echo "      \"tx\": $NET_TX"
echo "    }"
echo "  },"
echo "  \"apis\": ["
echo "    {\"name\":\"status\",\"path\":\"/api/status.sh\"},"
echo "    {\"name\":\"services\",\"path\":\"/api/services.sh\"},"
echo "    {\"name\":\"hardware\",\"path\":\"/api/hardware.sh\"},"
echo "    {\"name\":\"security\",\"path\":\"/api/security.sh\"},"
echo "    {\"name\":\"network\",\"path\":\"/api/network.sh\"},"
echo "    {\"name\":\"logs\",\"path\":\"/api/logs.sh\"},"
echo "    {\"name\":\"backup\",\"path\":\"/api/backup.sh\"},"
echo "    {\"name\":\"sensors\",\"path\":\"/api/sensors.sh\"}"
echo "  ],"
echo "  \"version\": \"V121.0\","
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

#!/bin/bash
# 系统状态API - 供看板调用

# 获取系统数据
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEM_TOTAL=$(free -m | grep Mem | awk '{print $2}')
MEM_USED=$(free -m | grep Mem | awk '{print $3}')
MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))
DISK_USED=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
LOAD=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
UPTIME=$(uptime -p)

# 获取Skills数量
SKILLS_LOCAL=$(ls /root/.openclaw/skills/ 2>/dev/null | wc -l)
SKILLS_GLOBAL=$(ls /root/.nvm/versions/node/v22.22.0/lib/node_modules/openclaw/skills/ 2>/dev/null | wc -l)
SKILLS_TOTAL=$((SKILLS_LOCAL + SKILLS_GLOBAL))

# 获取定时任务数
CRON_COUNT=3

# 获取OpenClaw状态
OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "未知")
MODEL=$(grep -o '"model":"[^"]*"' /root/.openclaw/config/openclaw.json 2>/dev/null | cut -d'"' -f4 || echo "MiniMax-M2.5")

# 输出JSON
echo "{"
echo "  \"cpu\": \"$CPU\","
echo "  \"memory\": {"
echo "    \"total\": $MEM_TOTAL,"
echo "    \"used\": $MEM_USED,"
echo "    \"percent\": $MEM_PERCENT"
echo "  },"
echo "  \"disk\": $DISK_USED,"
echo "  \"load\": \"$LOAD\","
echo "  \"uptime\": \"$UPTIME\","
echo "  \"skills\": $SKILLS_TOTAL,"
echo "  \"cron\": $CRON_COUNT,"
echo "  \"openclaw\": \"$OPENCLAW_VERSION\","
echo "  \"model\": \"$MODEL\","
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

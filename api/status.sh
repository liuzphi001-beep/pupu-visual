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

# 获取在线用户数
ONLINE_USERS=$(who | wc -l)

# 获取网络延迟 (ping百度)
API_LATENCY=$(ping -c 1 -W 1 baidu.com 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}' | cut -d'.' -f1)
if [ -z "$API_LATENCY" ]; then
    API_LATENCY=0
fi

# 获取Skills数量
SKILLS_GLOBAL=$(ls ~/.nvm/versions/node/v22.22.0/lib/node_modules/openclaw/skills/ 2>/dev/null | grep -v node_modules | wc -l)
SKILLS_EXTENSION=$(ls ~/.openclaw/extensions/*/skills/*/SKILL.md 2>/dev/null | wc -l)
SKILLS_TOTAL=$((SKILLS_GLOBAL + SKILLS_EXTENSION))

# 获取定时任务数
CRON_COUNT=3

# 获取OpenClaw状态
OPENCLAW_VERSION=$(openclaw --version 2>/dev/null || echo "未知")
MODEL=$(grep -o '"model":"[^"]*"' /root/.openclaw/config/openclaw.json 2>/dev/null | cut -d'"' -f4 || echo "MiniMax-M2.5")

# 获取网络流量 (字节)
NET_RX=$(cat /sys/class/net/eth0/statistics/rx_bytes 2>/dev/null || echo 0)
NET_TX=$(cat /sys/class/net/eth0/statistics/tx_bytes 2>/dev/null || echo 0)

# 获取进程数
PROCESS_COUNT=$(ps aux | wc -l)

# 获取内存详情
MEM_AVAILABLE=$(free -m | grep Mem | awk '{print $7}')
MEM_BUFFERS=$(free -m | grep Mem | awk '{print $6}')
MEM_CACHED=$(free -m | grep -E "^Mem:" | awk '{print $7}')

# 输出JSON
echo "{"
echo "  \"cpu\": \"$CPU\","
echo "  \"memory\": {"
echo "    \"total\": $MEM_TOTAL,"
echo "    \"used\": $MEM_USED,"
echo "    \"percent\": $MEM_PERCENT,"
echo "    \"available\": $MEM_AVAILABLE,"
echo "    \"buffers\": $MEM_BUFFERS,"
echo "    \"cached\": $MEM_CACHED"
echo "  },"
echo "  \"disk\": $DISK_USED,"
echo "  \"load\": \"$LOAD\","
echo "  \"uptime\": \"$UPTIME\","
echo "  \"onlineUsers\": $ONLINE_USERS,"
echo "  \"apiLatency\": $API_LATENCY,"
echo "  \"network\": {"
echo "    \"rx\": $NET_RX,"
echo "    \"tx\": $NET_TX"
echo "  },"
echo "  \"processes\": $PROCESS_COUNT,"
echo "  \"skills\": $SKILLS_TOTAL,"
echo "  \"cron\": $CRON_COUNT,"
echo "  \"openclaw\": \"$OPENCLAW_VERSION\","
echo "  \"model\": \"$MODEL\","
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

#!/bin/bash
# 服务状态API - 检查关键服务运行状态

# 收集服务状态
SERVICES_JSON="["

# OpenClaw Gateway
if pgrep -f "openclaw-gateway" > /dev/null 2>&1; then
    SERVICES_JSON+='{"name":"OpenClaw Gateway","status":"running","icon":"✅"}'
else
    SERVICES_JSON+='{"name":"OpenClaw Gateway","status":"stopped","icon":"❌"}'
fi

# SSH
if ss -tuln 2>/dev/null | grep -q ":22 " || netstat -tuln 2>/dev/null | grep -q ":22 "; then
    SERVICES_JSON+=',{"name":"SSH","status":"listening","icon":"✅","port":22}'
fi

SERVICES_JSON+="]"

# 系统运行服务数
SYS_SVCS=$(systemctl list-units --type=service --state=running 2>/dev/null | grep -c "\.service" || echo 0)

# 内存详情
MEM_USED=$(free -m | grep Mem | awk '{print $3}')
MEM_FREE=$(free -m | grep Mem | awk '{print $4}')
MEM_AVAIL=$(free -m | grep Mem | awk '{print $7}')

# 磁盘详情
DISK_USED=$(df -h / | tail -1 | awk '{print $3}')
DISK_AVAIL=$(df -h / | tail -1 | awk '{print $4}')
DISK_PCT=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1)

# 输出JSON
cat << EOF
{
  "services": $SERVICES_JSON,
  "systemdServices": $SYS_SVCS,
  "memoryDetail": {
    "used": $MEM_USED,
    "free": $MEM_FREE,
    "available": $MEM_AVAIL
  },
  "diskDetail": {
    "used": "$DISK_USED",
    "available": "$DISK_AVAIL",
    "percent": $DISK_PCT
  },
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

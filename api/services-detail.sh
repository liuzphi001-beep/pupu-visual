#!/bin/bash
# 容器和运行服务API - 显示容器和系统服务状态

echo "{"
echo "  \"containers\": ["

# 检查Docker
if command -v docker &> /dev/null; then
    CONTAINER_COUNT=$(docker ps -a 2>/dev/null | wc -l || echo 0)
    RUNNING_COUNT=$(docker ps 2>/dev/null | wc -l || echo 0)
    echo "    {\"type\":\"docker\",\"total\":$((CONTAINER_COUNT-1)),\"running\":$((RUNNING_COUNT-1))},"
fi

# 检查Podman
if command -v podman &> /dev/null; then
    PODMAN_COUNT=$(podman ps -a 2>/dev/null | wc -l || echo 0)
    echo "    {\"type\":\"podman\",\"total\":$PODMAN_COUNT,\"running\":0},"
fi

echo "    {\"type\":\"none\",\"total\":0,\"running\":0}"
echo "  ],"

# 系统服务
echo "  \"services\": ["

# 关键系统服务检查
declare -a SERVICES=(
    "sshd:SSH服务"
    "systemd:系统管理"
    "cron:定时任务"
    "rsyslog:系统日志"
    "netfs:网络文件系统"
    "network:网络服务"
)

for item in "${SERVICES[@]}"; do
    IFS=':' read -r svc desc <<< "$item"
    if systemctl is-active $svc &> /dev/null; then
        status="active"
    else
        status="inactive"
    fi
    echo "    {\"name\":\"$desc\",\"service\":\"$svc\",\"status\":\"$status\"},"
done | sed 's/,$//'

echo ""
echo "  ],"

# 快速链接
echo "  \"quickLinks\": {"
echo "    \"openclawLogs\": \"/var/log/openclaw-gateway.log\","
echo "    \"systemLogs\": \"/var/log/messages\","
echo "    \"backupDir\": \"/root/.openclaw/backup\","
echo "    \"configDir\": \"/root/.openclaw/config\""
echo "  },"

# OpenClaw服务
echo "  \"openclaw\": {"
echo "    \"gateway\": \"$(pgrep -f openclaw-gateway &>/dev/null && echo running || echo stopped)\","
echo "    \"version\": \"$(openclaw --version 2>/dev/null || echo unknown)\","
echo "    \"configPath\": \"/root/.openclaw/config/openclaw.json\""
echo "  },"

echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

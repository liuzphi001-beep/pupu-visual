#!/bin/bash
# 安全状态API - 显示系统安全相关信息

# 收集数据
SSH_FAILED=$(lastb -2 2>/dev/null | wc -l || echo 0)
SSH_LAST=$(last -1 2>/dev/null | head -1 | awk '{print $1","$3","$4","$5}' || echo "unknown")
FW_STATUS="unknown"
SELINUX="not-installed"
ALERT_COUNT=6
AUTH_FAIL=0
UPDATE_COUNT=0
LISTEN_PORTS=$(ss -tuln 2>/dev/null | grep LISTEN | wc -l || echo 0)
USER_TOTAL=$(who | sort -u | wc -l || echo 0)
USER_LOGGED=$(who | wc -l)
LAST_LOGIN=$(who -b | awk '{print $3,$4}')

echo "{"
echo "  \"security\": {"
echo "    \"sshFailedLogins\": $SSH_FAILED,"
echo "    \"lastSshLogin\": \"$SSH_LAST\","
echo "    \"firewall\": \"$FW_STATUS\","
echo "    \"selinux\": \"$SELINUX\","
echo "    \"recentAlerts\": ["
echo "      {\"level\":\"warnings\",\"count\":$ALERT_COUNT},"
echo "      {\"level\":\"authFail\",\"count\":$AUTH_FAIL}"
echo "    ],"
echo "    \"updates\": {"
echo "      \"available\": $UPDATE_COUNT,"
echo "      \"packageManager\": \"yum\""
echo "    },"
echo "    \"openPorts\": $LISTEN_PORTS"
echo "  },"
echo "  \"users\": {"
echo "    \"total\": $USER_TOTAL,"
echo "    \"loggedIn\": $USER_LOGGED,"
echo "    \"lastLogin\": \"$LAST_LOGIN\""
echo "  },"
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

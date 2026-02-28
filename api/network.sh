#!/bin/bash
# 网络连接详情API - 显示网络连接统计

# 网络接口统计
ETH0_RX=$(cat /sys/class/net/eth0/statistics/rx_bytes 2>/dev/null || echo 0)
ETH0_TX=$(cat /sys/class/net/eth0/statistics/tx_bytes 2>/dev/null || echo 0)
ETH0_RXP=$(cat /sys/class/net/eth0/statistics/rx_packets 2>/dev/null || echo 0)
ETH0_TXP=$(cat /sys/class/net/eth0/statistics/tx_packets 2>/dev/null || echo 0)
ETH0_ERR=$(cat /sys/class/net/eth0/statistics/rx_errors 2>/dev/null || echo 0)

META_RX=$(cat /sys/class/net/Meta/statistics/rx_bytes 2>/dev/null || echo 0)
META_TX=$(cat /sys/class/net/Meta/statistics/tx_bytes 2>/dev/null || echo 0)

rx0_mb=$(echo "scale=2; $ETH0_RX/1024/1024" | bc 2>/dev/null || echo 0)
tx0_mb=$(echo "scale=2; $ETH0_TX/1024/1024" | bc 2>/dev/null || echo 0)
meta_rx_mb=$(echo "scale=2; $META_RX/1024/1024" | bc 2>/dev/null || echo 0)
meta_tx_mb=$(echo "scale=2; $META_TX/1024/1024" | bc 2>/dev/null || echo 0)

# DNS
DNS_SERVERS=$(grep nameserver /etc/resolv.conf 2>/dev/null | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')

# 获取监听端口
LISTEN_PORTS=$(netstat -tln 2>/dev/null | grep LISTEN | wc -l || ss -tln 2>/dev/null | wc -l)

echo "{"
echo "  \"interfaces\": ["
echo "    {\"name\":\"eth0\",\"rx\":\"${rx0_mb}MB\",\"tx\":\"${tx0_mb}MB\",\"rxPackets\":$ETH0_RXP,\"txPackets\":$ETH0_TXP,\"errors\":$ETH0_ERR},"
echo "    {\"name\":\"Meta\",\"rx\":\"${meta_rx_mb}MB\",\"tx\":\"${meta_tx_mb}MB\"}"
echo "  ],"

echo "  \"dns\": {"
echo "    \"servers\": \"$DNS_SERVERS\""
echo "  },"

echo "  \"listeningPorts\": $LISTEN_PORTS,"

echo "  \"networkSummary\": {"
echo "    \"totalRx\": $ETH0_RX,"
echo "    \"totalTx\": $ETH0_TX"
echo "  },"

echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

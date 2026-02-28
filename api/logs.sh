#!/bin/bash
# 日志分析API - 分析系统关键日志

echo "{"
echo "  \"logs\": ["

# 定义要分析的日志
declare -a LOG_FILES=(
    "/var/log/openclaw-gateway.log:OpenClaw网关"
    "/var/log/clash.log:Clash代理"
    "/var/log/cloud-init.log:云初始化"
    "/var/log/dnf.log:包管理"
)

first=1
for item in "${LOG_FILES[@]}"; do
    IFS=':' read -r log_file desc <<< "$item"
    
    if [ -f "$log_file" ]; then
        # 获取最后修改时间
        last_mod=$(stat -c %Y "$log_file" 2>/dev/null)
        now=$(date +%s)
        age=$((now - last_mod))
        
        if [ $age -lt 60 ]; then
            age_str="刚刚"
        elif [ $age -lt 3600 ]; then
            age_str=$((age/60))"分钟前"
        elif [ $age -lt 86400 ]; then
            age_str=$((age/3600))"小时前"
        else
            age_str=$((age/86400))"天前"
        fi
        
        # 获取文件大小
        size=$(stat -c %s "$log_file" 2>/dev/null || echo 0)
        size_mb=$(echo "scale=2; $size/1024/1024" | bc 2>/dev/null || echo "0")
        
        # 获取最后几行
        last_lines=$(tail -5 "$log_file" 2>/dev/null | tr '\n' ' ' | head -c 200)
        
        if [ $first -eq 0 ]; then
            echo ","
        fi
        echo -n "    {\"name\":\"$desc\",\"file\":\"$log_file\",\"size\":\"${size_mb}MB\",\"lastModified\":\"$age_str\",\"recent\":\"$last_lines\"}"
        first=0
    fi
done

echo ""
echo "  ],"

# 系统日志摘要
echo "  \"system\": {"
echo "    \"lastBoot\": \"$(who -b | awk '{print $3,$4}')\","
echo "    \"lastLogin\": \"$(who -b | awk '{print $3,$4}')\","

# 内核日志
KMSG_SIZE=$(cat /var/log/dmesg 2>/dev/null | wc -l || echo 0)
echo "    \"kernelMessages\": $KMSG_SIZE,"

# 认证日志
AUTH_LINES=$(wc -l /var/log/secure 2>/dev/null | awk '{print $1}' || echo 0)
echo "    \"authLogLines\": $AUTH_LINES"

echo "  },"

# 日志统计
echo "  \"stats\": {"
TOTAL_SIZE=$(du -sm /var/log 2>/dev/null | awk '{print $1}')
echo "    \"totalLogSize\": \"${TOTAL_SIZE}MB\","
echo "    \"logFileCount\": $(ls -1 /var/log/*.log 2>/dev/null | wc -l)"
echo "  },"

echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

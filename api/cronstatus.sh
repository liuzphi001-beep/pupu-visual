#!/bin/bash
# Cron任务状态API - 显示定时任务的详细状态

echo "{"
echo "  \"cronJobs\": ["

# 定义任务列表
declare -a TASKS=(
    "pupu-daily-sync:0 3 * * *:每日同步"
    "pupu-health-check:0 9 * * 1:周一体检"
    "pupu-daily-reflection:0 22 * * *:每日反思"
    "pupu-version-weekly:5 3 * * 1:周版本"
    "pupu-version-monthly:10 3 1 *:月版本"
    "pupu-monitor:0 * * * *:每小时监控"
    "pupu-daily-email:0 22 * * *:每日邮件"
    "pupu-qmd-index:0 3 * * *:QMD索引"
    "pupu-memory-daily:0 10 * * *:每日记忆"
    "pupu-security-scan:0 0 * * *:安全扫描"
)

first=1
for task in "${TASKS[@]}"; do
    IFS=':' read -r name schedule desc <<< "$task"
    
    # 检查脚本是否存在
    script_path="/usr/local/bin/${name}.sh"
    if [ -f "$script_path" ]; then
        status="active"
    else
        # 检查Openclaw scripts目录
        script_path="/root/.openclaw/scripts/${name}.sh"
        if [ -f "$script_path" ]; then
            status="active"
        else
            status="inactive"
        fi
    fi
    
    if [ $first -eq 0 ]; then
        echo ","
    fi
    echo -n "    {\"name\":\"$name\",\"schedule\":\"$schedule\",\"status\":\"$status\",\"desc\":\"$desc\"}"
    first=0
done

echo ""
echo "  ],"

# 获取最近的任务执行日志
echo "  \"recentLogs\": ["

# 检查各个日志文件
for log_file in /var/log/pupu-*.log; do
    if [ -f "$log_file" ]; then
        last_line=$(tail -1 "$log_file" 2>/dev/null | head -c 100)
        log_name=$(basename "$log_file")
        echo "    {\"file\":\"$log_name\",\"lastLine\":\"$last_line\"},"
    fi
done | sed 's/,$//'

echo ""
echo "  ],"

# 统计信息
ACTIVE_CRON=$(crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" | wc -l)
echo "  \"summary\": {"
echo "    \"totalCronJobs\": $ACTIVE_CRON,"
echo "    \"monitoredTasks\": ${#TASKS[@]},"
echo "    \"logFiles\": $(ls /var/log/pupu-*.log 2>/dev/null | wc -l)"
echo "  },"

echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"

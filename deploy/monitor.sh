#!/bin/bash
#==============================================================================
# Mini Jira 服务器性能监控脚本
# 用于 2核2GB 配置的资源监控
#==============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        Mini Jira 资源监控 (2核2GB配置)                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

show_system_resources() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}系统资源总览${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # CPU 使用率
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')
    echo -e "CPU 使用率: ${YELLOW}$cpu_usage${NC}"
    
    # 内存使用
    mem_info=$(free -h | grep Mem)
    mem_total=$(echo $mem_info | awk '{print $2}')
    mem_used=$(echo $mem_info | awk '{print $3}')
    mem_percent=$(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100)}')
    echo -e "内存使用:  ${YELLOW}$mem_used / $mem_total ($mem_percent)${NC}"
    
    # 磁盘使用
    disk_info=$(df -h / | tail -1)
    disk_used=$(echo $disk_info | awk '{print $3}')
    disk_total=$(echo $disk_info | awk '{print $2}')
    disk_percent=$(echo $disk_info | awk '{print $5}')
    echo -e "磁盘使用:  ${YELLOW}$disk_used / $disk_total ($disk_percent)${NC}"
    
    echo ""
}

show_docker_stats() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Docker 容器资源使用${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" \
        mini-jira-app mini-jira-mysql 2>/dev/null || echo "容器未运行"
    
    echo ""
}

show_container_status() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}容器运行状态${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    docker compose ps 2>/dev/null || echo "Docker Compose 服务未找到"
    
    echo ""
}

show_app_logs() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}应用日志 (最近 10 行)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    docker compose logs --tail=10 app 2>/dev/null || echo "无法获取日志"
    
    echo ""
}

show_warnings() {
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  性能建议${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 检查内存使用
    mem_percent_num=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100)}')
    if [ "$mem_percent_num" -gt 85 ]; then
        echo -e "${RED}❌ 内存使用超过 85%，建议升级配置或优化应用${NC}"
    elif [ "$mem_percent_num" -gt 75 ]; then
        echo -e "${YELLOW}⚠️  内存使用超过 75%，需要关注${NC}"
    else
        echo -e "${GREEN}✅ 内存使用正常${NC}"
    fi
    
    # 检查容器是否运行
    if ! docker compose ps | grep -q "Up"; then
        echo -e "${RED}❌ 容器未正常运行，请检查日志${NC}"
    else
        echo -e "${GREEN}✅ 容器运行正常${NC}"
    fi
    
    echo ""
}

# 主循环
main() {
    cd /opt/mini-jira 2>/dev/null || {
        echo "请在 /opt/mini-jira 目录下运行此脚本"
        exit 1
    }
    
    if [ "$1" == "watch" ]; then
        # 持续监控模式
        while true; do
            print_header
            show_system_resources
            show_docker_stats
            show_container_status
            show_warnings
            
            echo -e "${BLUE}按 Ctrl+C 退出监控${NC}"
            sleep 5
        done
    else
        # 单次显示模式
        print_header
        show_system_resources
        show_docker_stats
        show_container_status
        show_app_logs
        show_warnings
        
        echo -e "${BLUE}提示：${NC}"
        echo "  - 持续监控: ./monitor.sh watch"
        echo "  - 查看完整日志: docker compose logs -f app"
        echo "  - 重启服务: docker compose restart"
        echo ""
    fi
}

main "$@"

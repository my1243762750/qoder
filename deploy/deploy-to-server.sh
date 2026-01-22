#!/bin/bash
#==============================================================================
# Mini Jira 本地上传并部署到阿里云脚本
# 用途：从本地机器将代码上传到阿里云服务器并自动部署
#==============================================================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
echo_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
echo_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 默认配置
SERVER_IP=""
SERVER_USER="root"
SERVER_PORT="22"
REMOTE_DIR="/opt/mini-jira"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_banner() {
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║     Mini Jira 上传并部署到阿里云服务器                ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# 获取服务器信息
get_server_info() {
    echo_info "请输入服务器信息"
    echo ""
    
    read -p "服务器 IP 地址: " SERVER_IP
    if [ -z "$SERVER_IP" ]; then
        echo_error "服务器 IP 不能为空"
        exit 1
    fi
    
    read -p "SSH 用户名 [root]: " input_user
    SERVER_USER=${input_user:-root}
    
    read -p "SSH 端口 [22]: " input_port
    SERVER_PORT=${input_port:-22}
    
    echo ""
    echo_info "服务器信息："
    echo "  IP: $SERVER_IP"
    echo "  用户: $SERVER_USER"
    echo "  端口: $SERVER_PORT"
    echo "  远程目录: $REMOTE_DIR"
    echo ""
}

# 测试 SSH 连接
test_ssh_connection() {
    echo_info "测试 SSH 连接..."
    
    if ssh -p $SERVER_PORT -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
        $SERVER_USER@$SERVER_IP "echo '连接成功'" &> /dev/null; then
        echo_success "SSH 连接测试成功"
    else
        echo_error "SSH 连接失败，请检查："
        echo "  1. 服务器 IP、用户名、端口是否正确"
        echo "  2. SSH 密钥或密码是否正确"
        echo "  3. 服务器防火墙是否开放 SSH 端口"
        exit 1
    fi
}

# 清理本地临时文件
clean_local() {
    echo_info "清理本地临时文件..."
    cd "$PROJECT_DIR"
    
    # 清理 Maven 构建文件
    if [ -d "target" ]; then
        rm -rf target
    fi
    
    echo_success "清理完成"
}

# 打包排除列表
create_exclude_file() {
    cat > /tmp/mini-jira-rsync-exclude <<EOF
.git/
.idea/
target/
*.iml
.DS_Store
*.log
.env
.mvn/wrapper/maven-wrapper.jar
EOF
}

# 上传代码到服务器
upload_code() {
    echo_info "开始上传代码到服务器..."
    
    create_exclude_file
    
    # 创建远程目录
    ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP "mkdir -p $REMOTE_DIR"
    
    # 使用 rsync 上传（如果没有 rsync 则使用 scp）
    if command -v rsync &> /dev/null; then
        echo_info "使用 rsync 上传..."
        rsync -avz --progress \
            -e "ssh -p $SERVER_PORT" \
            --exclude-from=/tmp/mini-jira-rsync-exclude \
            "$PROJECT_DIR/" \
            $SERVER_USER@$SERVER_IP:$REMOTE_DIR/
    else
        echo_warning "未找到 rsync，使用 scp 上传（速度较慢）..."
        scp -P $SERVER_PORT -r \
            "$PROJECT_DIR"/* \
            $SERVER_USER@$SERVER_IP:$REMOTE_DIR/
    fi
    
    rm -f /tmp/mini-jira-rsync-exclude
    echo_success "代码上传完成"
}

# 在服务器上执行部署
deploy_on_server() {
    echo_info "开始在服务器上部署..."
    
    ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP bash << 'ENDSSH'
set -e

cd /opt/mini-jira

echo "======================================"
echo "🔨 开始构建和部署"
echo "======================================"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "Docker 未安装，开始安装..."
    if [ -f "deploy-aliyun.sh" ]; then
        chmod +x deploy-aliyun.sh
        ./deploy-aliyun.sh
    else
        echo "错误：找不到 deploy-aliyun.sh"
        exit 1
    fi
fi

# 停止旧容器
echo ""
echo "停止旧容器..."
docker compose down || true

# 构建新镜像
echo ""
echo "构建 Docker 镜像..."
docker build -t mini-jira:latest .

# 启动服务
echo ""
echo "启动服务..."
docker compose up -d

# 等待服务启动
echo ""
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo ""
echo "======================================"
echo "服务状态："
echo "======================================"
docker compose ps

echo ""
echo "======================================"
echo "应用日志（最近 30 行）："
echo "======================================"
docker compose logs --tail=30 app

echo ""
echo "======================================"
echo "✅ 部署完成！"
echo "======================================"

ENDSSH

    echo_success "服务器部署完成"
}

# 显示访问信息
show_access_info() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}║              🎉 部署成功！                             ║${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}访问信息：${NC}"
    echo -e "  应用地址: ${GREEN}http://${SERVER_IP}:8080${NC}"
    echo -e "  API 文档: ${GREEN}http://${SERVER_IP}:8080/swagger-ui.html${NC}"
    echo ""
    echo -e "${BLUE}常用命令：${NC}"
    echo -e "  查看日志: ${YELLOW}ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP 'cd $REMOTE_DIR && docker compose logs -f app'${NC}"
    echo -e "  重启服务: ${YELLOW}ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP 'cd $REMOTE_DIR && docker compose restart'${NC}"
    echo -e "  停止服务: ${YELLOW}ssh -p $SERVER_PORT $SERVER_USER@$SERVER_IP 'cd $REMOTE_DIR && docker compose down'${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  重要提示：${NC}"
    echo -e "  1. 请在阿里云控制台安全组中开放 8080 端口"
    echo -e "  2. 首次启动可能需要 1-2 分钟"
    echo ""
}

# 主函数
main() {
    print_banner
    
    # 检查必要的工具
    if ! command -v ssh &> /dev/null; then
        echo_error "未找到 ssh 命令，请先安装 OpenSSH"
        exit 1
    fi
    
    if ! command -v scp &> /dev/null; then
        echo_error "未找到 scp 命令，请先安装 OpenSSH"
        exit 1
    fi
    
    # 获取服务器信息
    get_server_info
    
    # 测试连接
    test_ssh_connection
    
    echo ""
    read -p "确认开始部署？ [Y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        echo_info "取消部署"
        exit 0
    fi
    
    # 执行部署流程
    clean_local
    upload_code
    deploy_on_server
    show_access_info
}

# 运行主函数
main "$@"

#!/bin/bash
#==============================================================================
# Mini Jira 从 GitHub 自动化部署脚本
# 用途：在服务器上直接执行，从 GitHub 拉取代码并部署
# 特性：支持重复部署，自动处理所有异常和错误
#
# 使用方法:
#   1. 将此脚本上传到服务器
#   2. 修改下面的配置参数（GitHub仓库地址等）
#   3. 执行脚本: ./deploy-from-github.sh
#==============================================================================

set -e

#==============================================================================
# 配置区域 - 请根据实际情况修改以下参数
#==============================================================================

# GitHub 仓库配置
# 可以是公开仓库或私有仓库
# 如果是私有仓库，可以直接在地址中携带认证信息，例如：
# https://username:token@github.com/username/repo.git
GITHUB_REPO="git@github.com:my1243762750/qoder.git"  # GitHub 仓库地址
GITHUB_BRANCH="main"                    # Git 分支名称

# 部署配置
REMOTE_DIR="/opt/mini-jira"            # 远程部署目录

#==============================================================================
# 以下为脚本逻辑，一般不需要修改
#==============================================================================

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
echo_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
echo_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }
echo_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

print_banner() {
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║     Mini Jira 从 GitHub 自动化部署                     ║
║     支持重复部署，自动处理所有异常                      ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# 显示配置信息
show_config() {
    echo ""
    echo -e "${CYAN}═════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}当前配置${NC}"
    echo -e "${CYAN}═════════════════════════════════════════════════════${NC}"
    echo "  远程目录: ${GREEN}${REMOTE_DIR}${NC}"
    echo "  GitHub 仓库: ${GREEN}${GITHUB_REPO}${NC}"
    echo "  Git 分支: ${GREEN}${GITHUB_BRANCH}${NC}"
    echo -e "${CYAN}═════════════════════════════════════════════════════${NC}"
    echo ""
}

# 检查服务器环境
check_server_environment() {
    echo_step "检查服务器环境..."
    
    # 检查操作系统
    if [ ! -f /etc/os-release ]; then
        echo_error "无法检测操作系统"
        exit 1
    fi

    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        echo_warning "Docker 未安装，开始安装..."
        
        # 检测操作系统
        . /etc/os-release
        
        case $ID in
            centos|rhel|alinux)
                yum install -y yum-utils
                yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
                yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                ;;
            ubuntu|debian)
                apt-get update
                apt-get install -y ca-certificates curl gnupg lsb-release
                mkdir -p /etc/apt/keyrings
                curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update
                apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
                ;;
            *)
                echo_error "不支持的操作系统: $ID"
                exit 1
                ;;
        esac
        
        # 启动 Docker
        systemctl start docker
        systemctl enable docker
        
        echo_success "Docker 安装完成"
    fi

    # 检查 Git
    if ! command -v git &> /dev/null; then
        echo_warning "Git 未安装，开始安装..."
        
        . /etc/os-release
        
        case $ID in
            centos|rhel|alinux)
                yum install -y git
                ;;
            ubuntu|debian)
                apt-get update
                apt-get install -y git
                ;;
        esac
        
        echo_success "Git 安装完成"
    fi

    # 检查 Java（用于 Maven 构建）
    if ! command -v java &> /dev/null; then
        echo_warning "Java 未安装，开始安装..."
        
        . /etc/os-release
        
        case $ID in
            centos|rhel|alinux)
                yum install -y java-17-openjdk-devel
                ;;
            ubuntu|debian)
                apt-get update
                apt-get install -y openjdk-17-jdk
                ;;
        esac
        
        echo_success "Java 安装完成"
    fi

    # 检查 Maven（用于构建）
    if ! command -v mvn &> /dev/null; then
        echo_warning "Maven 未安装，开始安装..."
        
        . /etc/os-release
        
        case $ID in
            centos|rhel|alinux)
                yum install -y maven
                ;;
            ubuntu|debian)
                apt-get update
                apt-get install -y maven
                ;;
        esac
        
        echo_success "Maven 安装完成"
    fi

    echo_success "服务器环境检查完成"
}

# 部署应用
deploy_app() {
    echo_step "开始部署应用..."
    
    echo "======================================"
    echo "🚀 开始部署"
    echo "======================================"

    # 2. 检查部署状态
    echo ""
    echo "� 检查部署状态..."

    # 检查目录是否存在
    if [ ! -d "$REMOTE_DIR" ]; then
        echo "首次部署：目录不存在，创建并克隆..."
        mkdir -p $REMOTE_DIR
        cd $REMOTE_DIR
        git clone $GITHUB_REPO .
        git checkout $GITHUB_BRANCH
    elif [ ! -d "$REMOTE_DIR/.git" ]; then
        echo "首次部署：目录存在但不是 Git 仓库，克隆代码..."
        cd $REMOTE_DIR
        git clone $GITHUB_REPO .
        git checkout $GITHUB_BRANCH
    else
        echo "更新部署：Git 仓库已存在，拉取最新代码..."
        cd $REMOTE_DIR
        git fetch origin
        git checkout $GITHUB_BRANCH
        git pull origin $GITHUB_BRANCH
    fi

    # 3. 停止旧容器
    echo ""
    echo "🛑 停止旧容器..."
    if [ -f "docker-compose.yml" ]; then
        docker compose down 2>/dev/null || true
        echo "旧容器已停止"
    else
        echo "未找到旧容器"
    fi

    # 4. 清理旧镜像（可选，节省空间）
    echo ""
    echo "🧹 清理旧镜像..."
    docker image prune -f 2>/dev/null || true

    # 5. 构建 Docker 镜像
    echo ""
    echo "🔨 构建 Docker 镜像..."
    docker build -t mini-jira:latest .

    # 6. 启动服务
    echo ""
    echo "🚀 启动服务..."
    docker compose up -d

    # 7. 等待服务启动
    echo ""
    echo "⏳ 等待服务启动..."
    sleep 15

    # 8. 检查服务状态
    echo ""
    echo "======================================"
    echo "📊 服务状态"
    echo "======================================"
    docker compose ps

    # 9. 查看应用日志
    echo ""
    echo "======================================"
    echo "📝 应用日志（最近 30 行）"
    echo "======================================"
    docker compose logs --tail=30 app

    # 10. 健康检查
    echo ""
    echo "======================================"
    echo "🏥 健康检查"
    echo "======================================"

    # 检查容器是否运行
    if docker compose ps | grep -q "Up"; then
        echo "✅ 容器运行正常"
    else
        echo "❌ 容器未正常运行"
        echo "查看完整日志："
        docker compose logs app
        exit 1
    fi

    # 检查应用是否响应
    if curl -f -s http://localhost:8080/actuator/health &> /dev/null; then
        echo "✅ 应用健康检查通过"
    else
        echo "⚠️  应用健康检查失败（可能是首次启动，请稍后再试）"
    fi

    echo ""
    echo "======================================"
    echo "✅ 部署完成！"
    echo "======================================"
    
    echo_success "应用部署完成"
}

# 显示部署结果
show_deployment_result() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}║              🎉 部署成功！                             ║${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}访问信息：${NC}"
    echo -e "  应用地址: ${GREEN}http://$(hostname -I | awk '{print $1}'):8080${NC}"
    echo -e "  API 文档: ${GREEN}http://$(hostname -I | awk '{print $1}'):8080/swagger-ui.html${NC}"
    echo ""
    echo -e "${BLUE}常用命令：${NC}"
    echo -e "  查看日志:   ${YELLOW}cd $REMOTE_DIR && docker compose logs -f app${NC}"
    echo -e "  重启服务:   ${YELLOW}cd $REMOTE_DIR && docker compose restart${NC}"
    echo -e "  停止服务:   ${YELLOW}cd $REMOTE_DIR && docker compose down${NC}"
    echo -e "  查看状态:   ${YELLOW}cd $REMOTE_DIR && docker compose ps${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  重要提示：${NC}"
    echo -e "  1. 请确保在服务器安全组中开放 8080 端口"
    echo -e "  2. 首次启动可能需要 1-2 分钟，请耐心等待"
    echo -e "  3. 如需再次部署，直接运行此脚本即可"
    echo ""
}

# 错误处理
handle_error() {
    echo_error "部署过程中发生错误！"
    echo ""
    echo "请检查以下内容："
    echo "  1. 服务器网络连接是否正常"
    echo "  2. GitHub 仓库地址是否正确: $GITHUB_REPO"
    echo "  3. 服务器是否有足够的磁盘空间"
    echo "  4. 查看服务器日志："
    echo "     cd $REMOTE_DIR && docker compose logs"
    exit 1
}

# 主函数
main() {
    print_banner
    show_config
    
    # 设置错误处理
    trap handle_error ERR
    
    # 确认部署
    echo -e "${YELLOW}确认开始部署？ [Y/n]: ${NC}"
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]] && [[ ! -z $REPLY ]]; then
        echo_info "取消部署"
        exit 0
    fi
    
    echo ""
    echo -e "${CYAN}开始部署流程...${NC}"
    echo ""
    
    # 执行部署流程
    check_server_environment
    deploy_app
    show_deployment_result
}

# 运行主函数
main

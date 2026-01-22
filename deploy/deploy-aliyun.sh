#!/bin/bash
#==============================================================================
# Mini Jira 阿里云服务器一键部署脚本
# 支持：CentOS 7/8, Ubuntu 18.04/20.04/22.04, Alibaba Cloud Linux
#==============================================================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
PROJECT_NAME="mini-jira"
APP_DIR="/opt/mini-jira"
MYSQL_ROOT_PASSWORD="MinijiraRoot@2024"
MYSQL_DB="mini_jira"
MYSQL_USER="minijira"
MYSQL_PASSWORD="my@123456"
APP_PORT="8080"

echo_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
echo_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
echo_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_banner() {
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║          Mini Jira 一键部署脚本                        ║
║          阿里云轻量服务器专用版                        ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# 检测操作系统
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        echo_error "无法检测操作系统"
        exit 1
    fi
    echo_info "检测到操作系统: $OS $VERSION"
}

# 安装 Docker
install_docker() {
    echo_info "开始安装 Docker..."
    
    if command -v docker &> /dev/null; then
        echo_warning "Docker 已安装，跳过..."
        docker --version
        return 0
    fi

    case $OS in
        centos|rhel|alinux)
            # 卸载旧版本
            sudo yum remove -y docker docker-client docker-client-latest docker-common \
                docker-latest docker-latest-logrotate docker-logrotate docker-engine

            # 安装依赖
            sudo yum install -y yum-utils device-mapper-persistent-data lvm2

            # 添加 Docker 仓库（使用阿里云镜像）
            sudo yum-config-manager --add-repo \
                http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

            # 安装 Docker
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
        ubuntu|debian)
            # 卸载旧版本
            sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

            # 更新包索引
            sudo apt-get update

            # 安装依赖
            sudo apt-get install -y ca-certificates curl gnupg lsb-release

            # 添加 Docker GPG 密钥（使用阿里云镜像）
            sudo mkdir -p /etc/apt/keyrings
            curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | \
                sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

            # 添加 Docker 仓库
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
              http://mirrors.aliyun.com/docker-ce/linux/ubuntu \
              $(lsb_release -cs) stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            # 安装 Docker
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
            ;;
        *)
            echo_error "不支持的操作系统: $OS"
            exit 1
            ;;
    esac

    # 启动 Docker
    sudo systemctl start docker
    sudo systemctl enable docker

    # 配置 Docker 镜像加速（阿里云）
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker

    # 添加当前用户到 docker 组（如果不是 root）
    if [ "$EUID" -ne 0 ]; then
        sudo usermod -aG docker $USER
        echo_warning "已将当前用户添加到 docker 组，请重新登录以生效"
    fi

    echo_success "Docker 安装完成"
    docker --version
}

# 安装 Docker Compose
install_docker_compose() {
    echo_info "检查 Docker Compose..."
    
    if docker compose version &> /dev/null; then
        echo_warning "Docker Compose (Plugin) 已安装，跳过..."
        docker compose version
        return 0
    fi

    echo_info "Docker Compose Plugin 已随 Docker 安装"
    docker compose version
}

# 配置防火墙
configure_firewall() {
    echo_info "配置防火墙规则..."
    
    # 检查是否使用 firewalld
    if command -v firewall-cmd &> /dev/null && sudo systemctl is-active --quiet firewalld; then
        sudo firewall-cmd --permanent --add-port=$APP_PORT/tcp
        sudo firewall-cmd --reload
        echo_success "Firewalld 规则已添加"
    # 检查是否使用 ufw
    elif command -v ufw &> /dev/null; then
        sudo ufw allow $APP_PORT/tcp
        echo_success "UFW 规则已添加"
    # 检查是否使用 iptables
    elif command -v iptables &> /dev/null; then
        sudo iptables -I INPUT -p tcp --dport $APP_PORT -j ACCEPT
        # 尝试保存 iptables 规则
        if command -v iptables-save &> /dev/null; then
            sudo iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
        fi
        echo_success "Iptables 规则已添加"
    else
        echo_warning "未检测到防火墙，跳过配置"
    fi

    echo_warning "请确保在阿里云控制台的安全组中开放 $APP_PORT 端口！"
}

# 创建应用目录
create_app_directory() {
    echo_info "创建应用目录..."
    sudo mkdir -p $APP_DIR
    sudo chown -R $USER:$USER $APP_DIR
    cd $APP_DIR
    echo_success "应用目录创建完成: $APP_DIR"
}

# 创建 docker-compose.yml
create_docker_compose() {
    echo_info "创建 Docker Compose 配置..."
    
    cat > $APP_DIR/docker-compose.yml <<EOF
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: mini-jira-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DB}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      TZ: Asia/Shanghai
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
    command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
    networks:
      - mini-jira-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    image: ${PROJECT_NAME}:latest
    container_name: mini-jira-app
    restart: always
    depends_on:
      mysql:
        condition: service_healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql:3306/${MYSQL_DB}?useSSL=false&serverTimezone=Asia/Shanghai&characterEncoding=UTF-8&allowPublicKeyRetrieval=true
      SPRING_DATASOURCE_USERNAME: ${MYSQL_USER}
      SPRING_DATASOURCE_PASSWORD: ${MYSQL_PASSWORD}
      SPRING_JPA_HIBERNATE_DDL_AUTO: update
      SPRING_JPA_SHOW_SQL: false
      TZ: Asia/Shanghai
    ports:
      - "${APP_PORT}:8080"
    networks:
      - mini-jira-network

volumes:
  mysql-data:
    driver: local

networks:
  mini-jira-network:
    driver: bridge
EOF

    echo_success "Docker Compose 配置创建完成"
}

# 创建 Dockerfile（如果需要本地构建）
create_dockerfile() {
    echo_info "创建 Dockerfile..."
    
    cat > $APP_DIR/Dockerfile <<'EOF'
# 多阶段构建
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app

# 复制 Maven wrapper 和 pom.xml
COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .

# 下载依赖
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# 复制源码并构建
COPY src ./src
RUN ./mvnw package -DskipTests

# 运行时镜像
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# 创建非 root 用户
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# 复制 JAR 文件
COPY --from=builder /app/target/*.jar app.jar

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

    echo_success "Dockerfile 创建完成"
}

# 获取服务器公网 IP
get_public_ip() {
    PUBLIC_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || curl -s ipecho.net/plain || echo "无法获取")
    echo "$PUBLIC_IP"
}

# 部署应用
deploy_app() {
    echo_info "开始部署应用..."
    
    cd $APP_DIR
    
    # 停止旧容器
    echo_info "停止旧容器..."
    docker compose down || true
    
    # 拉取镜像或构建（这里假设你会上传代码到服务器）
    echo_warning "请确保已将代码上传到服务器: $APP_DIR"
    echo_warning "或者使用 scp/git 将项目文件传输到此目录"
    
    read -p "是否现在构建镜像？(如果代码已在 $APP_DIR 目录下) [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo_info "构建 Docker 镜像..."
        docker build -t ${PROJECT_NAME}:latest .
    fi
    
    # 启动服务
    echo_info "启动服务..."
    docker compose up -d
    
    echo_success "应用部署完成！"
}

# 检查服务状态
check_status() {
    echo_info "检查服务状态..."
    sleep 5
    
    cd $APP_DIR
    docker compose ps
    
    echo ""
    echo_info "查看应用日志..."
    docker compose logs --tail=50 app
}

# 打印访问信息
print_access_info() {
    PUBLIC_IP=$(get_public_ip)
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}║              🎉 部署成功！                             ║${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}访问信息：${NC}"
    echo -e "  应用地址: ${GREEN}http://${PUBLIC_IP}:${APP_PORT}${NC}"
    echo -e "  健康检查: ${GREEN}http://${PUBLIC_IP}:${APP_PORT}/actuator/health${NC}"
    echo ""
    echo -e "${BLUE}数据库信息：${NC}"
    echo -e "  主机: ${GREEN}${PUBLIC_IP}:3306${NC}"
    echo -e "  数据库: ${GREEN}${MYSQL_DB}${NC}"
    echo -e "  用户名: ${GREEN}${MYSQL_USER}${NC}"
    echo -e "  密码: ${GREEN}${MYSQL_PASSWORD}${NC}"
    echo ""
    echo -e "${BLUE}常用命令：${NC}"
    echo -e "  查看日志:   ${YELLOW}cd $APP_DIR && docker compose logs -f app${NC}"
    echo -e "  重启服务:   ${YELLOW}cd $APP_DIR && docker compose restart${NC}"
    echo -e "  停止服务:   ${YELLOW}cd $APP_DIR && docker compose down${NC}"
    echo -e "  更新应用:   ${YELLOW}cd $APP_DIR && docker compose up -d --build${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  重要提示：${NC}"
    echo -e "  1. 请在阿里云控制台安全组中开放 ${APP_PORT} 端口"
    echo -e "  2. 首次启动可能需要 1-2 分钟，请耐心等待"
    echo -e "  3. 建议修改默认的数据库密码"
    echo ""
}

# 主函数
main() {
    print_banner
    
    # 检查是否为 root 或有 sudo 权限
    if [ "$EUID" -ne 0 ]; then 
        if ! sudo -n true 2>/dev/null; then
            echo_error "此脚本需要 root 权限或 sudo 权限"
            exit 1
        fi
    fi
    
    echo_info "开始安装和部署..."
    echo ""
    
    detect_os
    install_docker
    install_docker_compose
    configure_firewall
    create_app_directory
    create_docker_compose
    create_dockerfile
    
    echo ""
    echo_success "环境准备完成！"
    echo ""
    echo_info "下一步："
    echo "  1. 将你的项目代码上传到服务器: $APP_DIR"
    echo "  2. 执行部署命令: cd $APP_DIR && docker compose up -d --build"
    echo ""
    read -p "是否现在开始部署（需要代码已在 $APP_DIR 目录）？ [y/N]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_app
        check_status
        print_access_info
    else
        echo_info "环境已准备就绪，稍后可手动部署"
        echo ""
        echo "手动部署步骤："
        echo "  1. 上传代码: scp -r /path/to/your/project/* user@server:$APP_DIR/"
        echo "  2. 连接服务器: ssh user@server"
        echo "  3. 构建并启动: cd $APP_DIR && docker compose up -d --build"
    fi
}

# 运行主函数
main

# 部署配置目录

本目录包含 Mini Jira 项目的所有部署相关配置和脚本。

## 目录结构

```
deploy/
├── Dockerfile              # Docker 镜像构建配置
├── docker-compose.yml      # Docker Compose 编排配置
├── build.sh               # 项目构建脚本
├── start.sh               # 快速启动脚本
├── deploy-aliyun.sh       # 阿里云服务器一键部署脚本
├── deploy-to-server.sh    # 从本地上传并部署到服务器
├── deploy-from-github.sh   # 从 GitHub 自动化部署到服务器（推荐）
└── monitor.sh             # 服务器性能监控脚本
```

## 文件说明

### Dockerfile
多阶段构建的 Docker 镜像配置文件，用于构建 Mini Jira 应用的 Docker 镜像。

**特性：**
- 基于 OpenJDK 17 Alpine 镜像
- 多阶段构建减小镜像体积
- 非 root 用户运行，提升安全性
- 健康检查支持

### docker-compose.yml
Docker Compose 编排配置，用于一键启动 MySQL 和应用服务。

**包含服务：**
- MySQL 8.0 数据库
- Mini Jira 应用

**特性：**
- 自动健康检查
- 资源限制配置
- 数据持久化
- 网络隔离

### build.sh
项目构建脚本，一键完成清理、编译、测试和打包。

**使用方法：**
```bash
./deploy/build.sh
```

### start.sh
快速启动脚本，自动检查 MySQL 连接并启动应用。

**使用方法：**
```bash
./deploy/start.sh
```

### deploy-aliyun.sh
阿里云服务器一键部署脚本，自动安装 Docker 并部署应用。

**支持系统：**
- CentOS 7/8
- Ubuntu 18.04/20.04/22.04
- Alibaba Cloud Linux

**使用方法：**
```bash
# 在服务器上执行
./deploy/deploy-aliyun.sh
```

**功能：**
- 自动检测操作系统
- 安装 Docker 和 Docker Compose
- 配置防火墙规则
- 创建应用目录
- 生成配置文件
- 部署应用

### deploy-to-server.sh
从本地上传代码到服务器并自动部署。

**使用方法：**
```bash
# 在本地执行
./deploy/deploy-to-server.sh
```

**功能：**
- 交互式输入服务器信息
- 测试 SSH 连接
- 使用 rsync/scp 上传代码
- 在服务器上自动构建和部署

### deploy-from-github.sh ⭐ 推荐
从 GitHub 自动化部署到服务器，支持重复部署，自动处理所有异常。

**使用方法：**
```bash
# 在本地执行
./deploy/deploy-from-github.sh
```

**功能：**
- 交互式输入服务器信息和 GitHub 仓库地址
- 自动检测并安装 Docker、Git、Java、Maven
- 自动从 GitHub 拉取最新代码
- 智能判断首次部署或更新部署
- 自动停止旧容器、清理旧镜像
- 自动构建 Docker 镜像并启动服务
- 自动健康检查和状态验证
- 完善的错误处理和日志输出

**特性：**
- ✅ 支持重复部署，无需手动清理
- ✅ 自动处理所有异常和错误
- ✅ 智能检测服务器环境，自动安装缺失的依赖
- ✅ 完整的部署日志和状态反馈
- ✅ 健康检查确保服务正常运行

**适用场景：**
- 代码托管在 GitHub
- 需要频繁更新部署
- 希望一键完成所有部署操作
- 不想手动处理各种异常情况

**示例：**
```bash
./deploy/deploy-from-github.sh
# 按提示输入：
# - 服务器 IP：123.45.67.89
# - SSH 用户名：root
# - SSH 端口：22
# - GitHub 仓库：https://github.com/yourname/qoder.git
# - Git 分支：main
```

### monitor.sh
服务器性能监控脚本，用于 2核2GB 配置的服务器监控。

**使用方法：**
```bash
# 单次查看
./deploy/monitor.sh

# 持续监控
./deploy/monitor.sh watch
```

**监控内容：**
- CPU 使用率
- 内存使用情况
- 磁盘使用情况
- Docker 容器资源使用
- 容器运行状态
- 应用日志
- 性能建议

## 快速开始

### 本地开发

1. 使用 Maven 启动：
```bash
mvn spring-boot:run
```

2. 使用启动脚本：
```bash
./deploy/start.sh
```

### Docker 部署

```bash
# 启动所有服务
docker compose -f deploy/docker-compose.yml up -d

# 查看日志
docker compose -f deploy/docker-compose.yml logs -f mini-jira-app

# 停止服务
docker compose -f deploy/docker-compose.yml down
```

### 服务器部署

#### 方式一：从 GitHub 自动化部署 ⭐ 推荐

```bash
# 在本地执行（代码托管在 GitHub）
./deploy/deploy-from-github.sh
```

**优势：**
- 一键完成所有部署操作
- 自动从 GitHub 拉取最新代码
- 支持重复部署，无需手动清理
- 自动处理所有异常和错误
- 自动安装缺失的依赖

#### 方式二：阿里云一键部署

```bash
# 在服务器上执行
./deploy/deploy-aliyun.sh
```

#### 方式三：从本地上传部署

```bash
# 在本地执行
./deploy/deploy-to-server.sh
```

#### 监控服务器

```bash
# 在服务器上执行
./deploy/monitor.sh watch
```

## 配置说明

### 环境变量

docker-compose.yml 中支持的环境变量：

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| SPRING_DATASOURCE_URL | 数据库连接地址 | jdbc:mysql://mysql:3306/mini_jira |
| SPRING_DATASOURCE_USERNAME | 数据库用户名 | minijira |
| SPRING_DATASOURCE_PASSWORD | 数据库密码 | my@123456 |
| SPRING_JPA_HIBERNATE_DDL_AUTO | DDL 自动更新策略 | update |
| SPRING_JPA_SHOW_SQL | 是否显示 SQL | false |
| SPRING_PROFILES_ACTIVE | 激活的配置文件 | prod |
| JAVA_OPTS | JVM 参数 | -Xms256m -Xmx768m |

### 端口映射

| 服务 | 容器端口 | 主机端口 |
|------|----------|----------|
| MySQL | 3306 | 3306 |
| Mini Jira App | 8080 | 8080 |

### 资源限制

| 服务 | 内存限制 | 内存保留 |
|------|----------|----------|
| MySQL | 512M | 256M |
| Mini Jira App | 1024M | 512M |

## 常见问题

### 1. Docker 镜像构建失败

检查网络连接，或使用国内镜像源：
```bash
# 编辑 /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com"
  ]
}
```

### 2. 容器启动失败

查看容器日志：
```bash
docker compose -f deploy/docker-compose.yml logs -f
```

### 3. 数据库连接失败

检查 MySQL 容器是否健康：
```bash
docker compose -f deploy/docker-compose.yml ps
```

### 4. 服务器部署失败

确保服务器满足以下条件：
- 操作系统支持（CentOS/Ubuntu/Alibaba Cloud Linux）
- 有 sudo 权限
- 网络连接正常
- 防火墙已开放必要端口

## 维护命令

### 查看服务状态
```bash
docker compose -f deploy/docker-compose.yml ps
```

### 查看日志
```bash
docker compose -f deploy/docker-compose.yml logs -f [service-name]
```

### 重启服务
```bash
docker compose -f deploy/docker-compose.yml restart
```

### 更新应用
```bash
docker compose -f deploy/docker-compose.yml up -d --build
```

### 清理资源
```bash
docker compose -f deploy/docker-compose.yml down -v
```

## 安全建议

1. 修改默认的数据库密码
2. 使用环境变量管理敏感信息
3. 配置 HTTPS（使用 Nginx 反向代理）
4. 限制数据库访问 IP
5. 定期更新基础镜像
6. 启用应用日志审计

## 性能优化

### JVM 参数调优

根据服务器配置调整 JAVA_OPTS：

```yaml
environment:
  JAVA_OPTS: >-
    -Xms512m
    -Xmx1024m
    -XX:MaxMetaspaceSize=128m
    -XX:+UseG1GC
    -XX:MaxGCPauseMillis=100
```

### 数据库优化

```yaml
command:
  - --innodb-buffer-pool-size=256M
  - --max-connections=100
```

## 相关文档

- [项目主 README](../README.md)
- [架构设计文档](../docs/ARCHITECTURE.md)
- [API 文档](../docs/api/api-test.http)

# Mini Jira - 后端学习项目

一个基于 Spring Boot 的任务管理系统，用于学习后端开发和面试准备。

## 📋 项目简介

Mini Jira 是一个简化版的任务管理系统，实现了用户认证、项目管理和任务跟踪等核心功能。项目采用工业级标准开发，涵盖常见的后端面试知识点。

## 🚀 技术栈

### 后端
- **Java 17** - 编程语言
- **Spring Boot 3.2.5** - 应用框架
- **Spring Security** - 安全认证
- **Spring Data JPA** - 数据持久化
- **MySQL 8.0** - 关系数据库
- **JWT** - 无状态认证
- **Maven** - 项目构建工具
- **Lombok** - 代码简化
- **Docker** - 容器化部署

### 计划中（后续阶段）
- Redis - 缓存
- RabbitMQ - 消息队列
- Spring Boot Actuator - 监控

## 📦 项目结构

```
qoder/
├── src/
│   ├── main/
│   │   ├── java/com/qoder/minijira/
│   │   │   ├── common/              # 通用组件
│   │   │   │   ├── api/            # 统一响应格式
│   │   │   │   └── exception/      # 全局异常处理
│   │   │   ├── security/           # 安全配置
│   │   │   │   ├── JwtTokenProvider.java
│   │   │   │   ├── JwtAuthenticationFilter.java
│   │   │   │   └── SecurityConfig.java
│   │   │   ├── user/               # 用户模块
│   │   │   │   ├── controller/
│   │   │   │   ├── service/
│   │   │   │   ├── repository/
│   │   │   │   ├── entity/
│   │   │   │   └── dto/
│   │   │   ├── project/            # 项目模块
│   │   │   │   └── ...
│   │   │   ├── issue/              # 任务模块
│   │   │   │   └── ...
│   │   │   └── MiniJiraApplication.java
│   │   └── resources/
│   │       ├── application.yml            # 主配置文件
│   │       ├── application-example.yml    # 配置模板（供参考）
│   │       └── logback-spring.xml         # 日志配置
│   └── test/                       # 测试代码
│       ├── java/
│       │   └── MiniJiraApplicationTests.java
│       └── resources/
│           └── application.yml            # 测试配置
├── docs/                           # 文档目录
│   ├── ARCHITECTURE.md             # 架构设计文档
│   └── api/
│       └── api-test.http           # API 测试集合
├── .qoder/                         # AI 协作配置
│   ├── rules/                      # 项目规则
│   └── skills/                     # 技能模板
├── deploy/                        # 部署配置目录
│   ├── Dockerfile                # Docker 镜像构建
│   ├── docker-compose.yml        # Docker 编排配置
│   ├── build.sh                  # 构建脚本
│   ├── start.sh                  # 快速启动脚本
│   ├── deploy-aliyun.sh          # 阿里云部署脚本
│   ├── deploy-to-server.sh       # 服务器部署脚本
│   ├── deploy-from-github.sh     # GitHub 自动化部署脚本（推荐）
│   └── monitor.sh                # 服务器监控脚本
├── .gitignore                    # Git 忽略配置
├── CHANGELOG.md                  # 版本变更记录
├── CONTRIBUTING.md               # 贡献指南
├── LICENSE                       # MIT 开源协议
├── README.md                     # 项目文档（本文件）
├── backend-learning-plan.md      # 完整学习计划
└── pom.xml                       # Maven 配置
```

## 🛠️ 环境要求

- **JDK**: 17 或更高版本
- **Maven**: 3.6+
- **MySQL**: 8.0+
- **操作系统**: macOS / Linux / Windows

## ⚡ 如何启动项目

### 🎯 当前项目状态

✅ **项目已经启动运行中！**

之前我已经帮你完成了：
1. ✅ 创建了数据库 `mini_jira` 和用户 `minijira`
2. ✅ 配置了 `application.yml`（数据库连接、JWT密钥等）
3. ✅ 安装了 Maven 依赖
4. ✅ 启动了 Spring Boot 应用（运行在后台）

**应用地址**: http://localhost:8080

### 🔄 如何重新启动项目

如果你关闭了终端或想重新启动，有以下几种方式：

#### 方式 1: 使用 Maven 命令（最常用）

```bash
# 进入项目目录
cd /Users/apple/IdeaProjects/InterviewProject/qoder

# 启动项目
mvn spring-boot:run
```

这个命令会：
- 自动编译代码
- 启动 Spring Boot 应用
- 在控制台显示日志
- 按 `Ctrl+C` 可停止

#### 方式 2: 使用启动脚本

```bash
# 进入项目目录
cd /Users/apple/IdeaProjects/InterviewProject/qoder

# 运行启动脚本（会自动检查 MySQL 连接）
./deploy/start.sh
```

#### 方式 3: 使用 IntelliJ IDEA / Qoder

1. 在 Qoder 中打开项目
2. 找到 `src/main/java/com/qoder/minijira/MiniJiraApplication.java`
3. 右键点击文件，选择 "Run 'MiniJiraApplication'"
4. 或者点击类旁边的绿色运行按钮 ▶️

#### 方式 4: 运行打包后的 JAR

```bash
# 先打包
mvn clean package -DskipTests

# 运行 JAR 文件
java -jar target/mini-jira-0.0.1-SNAPSHOT.jar
```

#### 方式 5: 使用 Docker

```bash
# 启动所有服务（MySQL + 应用）
docker compose -f deploy/docker-compose.yml up -d

# 查看日志
docker compose -f deploy/docker-compose.yml logs -f mini-jira-app

# 停止服务
docker compose -f deploy/docker-compose.yml down
```

### 🔍 如何检查项目是否在运行

1. **检查端口占用**：
```bash
lsof -i:8080
# 如果看到 java 进程，说明项目正在运行
```

2. **访问测试接口**：
```bash
curl http://localhost:8080/api/auth/register
# 如果返回数据（而不是连接错误），说明项目在运行
```

3. **查看进程**：
```bash
ps aux | grep spring-boot
# 查找是否有 Spring Boot 进程
```

### 🛑 如何停止项目

- **在终端运行的**：按 `Ctrl+C`
- **在后台运行的**：
  ```bash
  # 找到进程
  lsof -ti:8080
  
  # 杀掉进程
  kill -9 $(lsof -ti:8080)
  ```

### 💡 关于 Qoder 的启动

从你的截图看，Qoder 本身是一个 AI 编程助手工具，它：
- 不是项目的一部分，而是帮助你开发的工具
- 类似于 GitHub Copilot 或 Cursor
- 可以帮你写代码、理解代码、执行命令等
- `.qoder/` 目录存放的是给 Qoder 的项目规则和技能配置

Qoder 的使用：
1. 在 Qoder 中打开项目文件夹
2. 可以在聊天窗口问问题
3. 可以选中代码让 Qoder 帮忙解释或修改
4. Qoder 会根据 `.qoder/rules/` 中的规则来工作

## 📥 快速开始

### 方式一：使用自动化脚本（推荐） 🚀

#### 1. 配置数据库
```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库和用户
CREATE DATABASE IF NOT EXISTS mini_jira CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'minijira'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON mini_jira.* TO 'minijira'@'localhost';
FLUSH PRIVILEGES;
exit;
```

#### 2. 配置应用
```bash
# 复制配置模板
cp src/main/resources/application-example.yml src/main/resources/application.yml

# 编辑配置文件，修改数据库密码
vim src/main/resources/application.yml
```

#### 3. 一键启动
```bash
# 使用启动脚本（会自动检查 MySQL 连接）
./start.sh
```

### 方式二：手动启动

### 1. 克隆项目

```bash
git clone <repository-url>
cd qoder
```

### 2. 配置数据库

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库和用户
CREATE DATABASE IF NOT EXISTS mini_jira CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'minijira'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON mini_jira.* TO 'minijira'@'localhost';
FLUSH PRIVILEGES;
exit;
```

### 3. 修改配置

编辑 `src/main/resources/application.yml`，更新数据库密码：

```yaml
spring:
  datasource:
    password: your_password  # 修改为你的密码
```

### 4. 编译项目

```bash
mvn clean install -DskipTests
# 或使用构建脚本
./deploy/build.sh
```

### 方式三：从 GitHub 自动化部署 ⭐ 推荐

在服务器上直接执行，从 GitHub 自动化部署。

**使用步骤：**

1. 将脚本上传到服务器：
```bash
scp deploy/deploy-from-github.sh root@your-server:/root/
```

2. SSH 登录服务器：
```bash
ssh root@your-server
```

3. 编辑脚本，修改顶部的配置参数：
```bash
vim /root/deploy-from-github.sh
```

4. 修改以下配置项：
```bash
# GitHub 仓库配置
# 可以是公开仓库或私有仓库
# 如果是私有仓库，可以直接在地址中携带认证信息，例如：
# https://username:token@github.com/username/repo.git
GITHUB_REPO="https://github.com/username/qoder.git"  # GitHub 仓库地址
GITHUB_BRANCH="main"                    # Git 分支名称

# 部署配置
REMOTE_DIR="/opt/mini-jira"            # 远程部署目录
```

5. 执行脚本：
```bash
chmod +x /root/deploy-from-github.sh
./deploy-from-github.sh
```

**如何配置私有仓库访问：**

如果 GitHub 仓库是私有的，需要在仓库地址中携带认证信息：

**方式一：在 URL 中携带 Token（推荐）**
1. 在 GitHub 上生成 Token：Settings -> Developer settings -> Personal access tokens
2. 选择 `repo` 权限并生成
3. 在仓库地址中添加认证信息：`https://username:token@github.com/username/repo.git`

**方式二：使用 SSH（更安全）**
1. 将仓库地址改为 SSH 格式：`git@github.com:username/qoder.git`
2. 确保服务器上有 SSH 密钥并已添加到 GitHub

**特性：**
- 在服务器上直接执行，无需本地连接
- 自动从 GitHub 拉取最新代码
- 支持重复部署，无需手动清理
- 自动处理所有异常和错误
- 自动安装 Docker、Git、Java、Maven 等依赖
- 支持 GitHub 私有仓库（URL 中携带认证信息）
- 配置参数在脚本顶部，一目了然

### 方式四：使用 Docker 🐳

```bash
# 启动所有服务（MySQL + 应用）
docker compose -f deploy/docker-compose.yml up -d

# 查看日志
docker compose -f deploy/docker-compose.yml logs -f mini-jira-app

# 停止服务
docker compose -f deploy/docker-compose.yml down
```

## 📚 API 文档

**Swagger UI 访问地址**: `http://localhost:8080/swagger-ui.html`

**完整的 API 测试集合**: `docs/api/api-test.http`
你可以使用 IntelliJ IDEA 的 HTTP Client 直接运行测试，或参考以下示例：

### 认证接口

#### 1. 用户注册
```bash
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "username": "username",
  "password": "password123"
}
```

#### 2. 用户登录
```bash
POST /api/auth/login
Content-Type: application/json

{
  "usernameOrEmail": "username",
  "password": "password123"
}

# 响应
{
  "code": 0,
  "message": "ok",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

### 项目接口（需要认证）

#### 3. 创建项目
```bash
POST /api/projects
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "项目名称",
  "description": "项目描述"
}
```

#### 4. 查看我的项目
```bash
GET /api/projects
Authorization: Bearer <token>
```

### 任务接口（需要认证）

#### 5. 创建任务
```bash
POST /api/projects/{projectId}/issues
Authorization: Bearer <token>
Content-Type: application/json

{
  "title": "任务标题",
  "description": "任务描述",
  "priority": "HIGH"  # LOW, MEDIUM, HIGH, CRITICAL
}
```

#### 6. 查看项目任务
```bash
GET /api/projects/{projectId}/issues
Authorization: Bearer <token>
```

## 🎯 学习路线

项目分为 5 个阶段（详见 `backend-learning-plan.md`）：

- **Stage 0**: 环境准备
- **Stage 1**: MVP 核心功能（✅ 已完成）
- **Stage 2**: 功能增强（分页、权限、文件上传）
- **Stage 3**: 性能优化（缓存、消息队列、监控）
- **Stage 4**: 高级特性（分布式、微服务）

## 🔐 安全设计

- **密码加密**: BCrypt 算法
- **JWT 认证**: 无状态 token，有效期 1 小时
- **CORS 配置**: 允许跨域请求
- **统一异常处理**: 全局错误码规范

## 📝 开发规范

### 错误码规范
- `0` - 成功
- `1000` - 参数验证错误
- `2000` - 认证/授权错误
- `3000` - 业务逻辑错误
- `5000` - 系统错误

### API 响应格式
```json
{
  "code": 0,
  "message": "ok",
  "data": { ... }
}
```

## 🧪 测试

```bash
# 运行所有测试
mvn test

# 运行特定测试类
mvn test -Dtest=UserServiceTest
```

## 🛠️ 辅助工具

### 构建脚本
```bash
./deploy/build.sh          # 清理、编译、测试、打包一键完成
```

### 启动脚本
```bash
./deploy/start.sh          # 检查 MySQL + 启动应用
```

### API 测试
使用 IntelliJ IDEA 打开 `docs/api/api-test.http`，可以直接运行所有 API 测试。

## 📦 打包部署

### 本地部署
```bash
# 打包成 jar
mvn clean package
# 或使用构建脚本
./deploy/build.sh

# 运行 jar
java -jar target/mini-jira-0.0.1-SNAPSHOT.jar
```

### Docker 部署
```bash
# 使用 Docker Compose 部署
docker compose -f deploy/docker-compose.yml up -d
```

### 服务器部署
```bash
# 从 GitHub 自动化部署（推荐）
./deploy/deploy-from-github.sh

# 阿里云服务器一键部署
./deploy/deploy-aliyun.sh

# 从本地上传到服务器并部署
./deploy/deploy-to-server.sh

# 服务器监控
./deploy/monitor.sh
```

## 📖 项目文档

- **[架构设计文档](docs/ARCHITECTURE.md)** - 详细的技术架构和设计说明
- **[部署文档](deploy/README.md)** - 部署配置和脚本说明
- **[贡献指南](CONTRIBUTING.md)** - 如何参与项目开发
- **[变更日志](CHANGELOG.md)** - 版本历史和更新记录
- **[学习计划](backend-learning-plan.md)** - 完整的后端学习路线图

## 🤝 贡献指南

详见 [CONTRIBUTING.md](CONTRIBUTING.md)

简要步骤：

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

[MIT License](LICENSE) - 本项目仅用于学习目的。

## 📞 联系方式

如有问题，欢迎提交 Issue。

---

**Happy Coding! 🚀**

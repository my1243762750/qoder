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

### 计划中（后续阶段）
- Redis - 缓存
- RabbitMQ - 消息队列
- Docker - 容器化部署
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
├── .gitignore                      # Git 忽略配置
├── CHANGELOG.md                    # 版本变更记录
├── CONTRIBUTING.md                 # 贡献指南
├── Dockerfile                      # Docker 镜像构建
├── docker-compose.yml              # Docker 编排配置
├── LICENSE                         # MIT 开源协议
├── README.md                       # 项目文档（本文件）
├── backend-learning-plan.md        # 完整学习计划
├── build.sh                        # 构建脚本
├── start.sh                        # 快速启动脚本
└── pom.xml                         # Maven 配置
```

## 🛠️ 环境要求

- **JDK**: 17 或更高版本
- **Maven**: 3.6+
- **MySQL**: 8.0+
- **操作系统**: macOS / Linux / Windows

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
./build.sh
```

### 5. 启动应用

```bash
mvn spring-boot:run
```

应用将在 `http://localhost:8080` 启动。

### 方式三：使用 Docker 🐳

```bash
# 启动所有服务（MySQL + 应用）
docker-compose up -d

# 查看日志
docker-compose logs -f mini-jira-app

# 停止服务
docker-compose down
```

## 📚 API 文档

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
./build.sh          # 清理、编译、测试、打包一键完成
```

### 启动脚本
```bash
./start.sh          # 检查 MySQL + 启动应用
```

### API 测试
使用 IntelliJ IDEA 打开 `docs/api/api-test.http`，可以直接运行所有 API 测试。

## 📦 打包部署

```bash
# 打包成 jar
mvn clean package
# 或使用构建脚本
./build.sh

# 运行 jar
java -jar target/mini-jira-0.0.1-SNAPSHOT.jar

# 使用 Docker 部署
docker-compose up -d
```

## 📖 项目文档

- **[架构设计文档](docs/ARCHITECTURE.md)** - 详细的技术架构和设计说明
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

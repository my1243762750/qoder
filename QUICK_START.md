# 快速启动指南

## 🎯 当前状态

✅ **项目已经在运行！**
- 进程ID: 55223
- 端口: 8080
- 地址: http://localhost:8080

## ⚡ 常用命令

### 启动项目
```bash
cd /Users/apple/IdeaProjects/InterviewProject/qoder
mvn spring-boot:run
```

### 检查是否运行
```bash
lsof -i:8080
```

### 停止项目
```bash
# 方式1: 如果在终端运行，按 Ctrl+C

# 方式2: 杀掉进程
kill -9 $(lsof -ti:8080)
```

### 测试 API
```bash
# 注册用户
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"test123456"}'

# 登录
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"testuser","password":"test123456"}'
```

## 🛠️ 在 Qoder 中运行

### 方法1: 使用运行按钮
1. 打开 `src/main/java/com/qoder/minijira/MiniJiraApplication.java`
2. 点击类名旁边的绿色运行按钮 ▶️
3. 选择 "Run 'MiniJiraApplication'"

### 方法2: 使用调试模式
1. 点击 Qoder 左侧的 "Run and Debug" 按钮
2. 点击 "Run and Debug" 绿色按钮
3. 选择 Java 应用

## 📊 项目信息

- **数据库**: mini_jira
- **数据库用户**: minijira
- **数据库密码**: my@123456
- **JWT密钥**: 已配置在 application.yml

## 🔗 有用的链接

- API 测试: `docs/api/api-test.http`（用 IntelliJ IDEA 打开）
- 完整文档: `README.md`
- 架构设计: `docs/ARCHITECTURE.md`
- 学习计划: `backend-learning-plan.md`

## ❓ 常见问题

### Q: 端口被占用怎么办？
```bash
# 查看占用端口的进程
lsof -ti:8080

# 杀掉进程
kill -9 $(lsof -ti:8080)
```

### Q: 如何查看日志？
日志会在启动时显示在控制台，也可以查看：
```bash
tail -f logs/mini-jira.log
```

### Q: 数据库连接失败？
1. 检查 MySQL 是否运行：`mysql -u minijira -pmy@123456`
2. 检查配置文件：`src/main/resources/application.yml`

### Q: 如何重新编译？
```bash
mvn clean install -DskipTests
```

---

**更多详细信息，请查看 [README.md](README.md)**

## [0.1.0] - 2026-01-22

### ✨ Added
- 用户注册和登录功能
- JWT 无状态认证
- 项目管理（创建、查看）
- 任务管理（创建、查看）
- 统一 API 响应格式
- 全局异常处理
- 数据库表自动创建

### 🔐 Security
- BCrypt 密码加密
- JWT Token 认证
- Spring Security 配置

### 📝 Documentation
- README.md 项目文档
- API 接口文档
- 后端学习计划文档

### 🏗️ Architecture
- 三层架构：Controller → Service → Repository
- DTO 模式分离请求/响应
- Entity 实体与表映射
- 统一错误码规范

---

## 版本规范

遵循 [语义化版本](https://semver.org/lang/zh-CN/)：

- **主版本号**：不兼容的 API 修改
- **次版本号**：向下兼容的功能性新增
- **修订号**：向下兼容的问题修正

### 变更类型

- `Added` 新增功能
- `Changed` 功能变更
- `Deprecated` 即将废弃的功能
- `Removed` 已移除的功能
- `Fixed` 问题修复
- `Security` 安全相关

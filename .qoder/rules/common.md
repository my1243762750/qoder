---
trigger: always_on
---

## 迷你 Jira 项目规则（Rules）

> 说明：本规则用于约束后续所有 AI 在本仓库中编写代码时的行为，目标是让不同 AI 写出的代码在技术栈、架构和风格上保持统一，减少沟通成本，加快实现进度。

---

### 1. 技术栈约定

1. **后端技术栈**
   - 语言：Java 17。
   - 框架：Spring Boot 3.x。
   - Web 层：Spring MVC（Spring Web）。
   - 持久化：Spring Data JPA + MySQL。
   - 缓存：Redis（在阶段 3 引入）。
   - 消息队列：RabbitMQ（在阶段 3 引入）。
   - 安全：Spring Security + JWT。
   - 构建工具：Maven。

2. **前端技术栈**
   - 框架：Vue 3 + Vite。
   - UI 组件库：Element Plus 优先。
   - HTTP 请求：Axios。

> 除非用户在对话中明确要求更换技术栈，否则所有 AI 都必须基于以上技术栈进行设计和实现。

---

### 2. 架构与分层规则

1. **必须采用清晰的分层结构**：
   - `controller` 层：处理 HTTP 请求/响应、参数校验、调用 service，不写复杂业务逻辑。
   - `service` 层：承载业务逻辑，包含权限判定、事务控制、业务规则等。
   - `repository` 层：仅负责数据访问，使用 Spring Data JPA 接口。
   - `domain/entity` 层：业务实体，与数据库表结构对应。
   - `dto` 层：接口请求和响应的数据结构，不允许直接把实体返回给前端。

2. **禁止的做法**：
   - Controller 直接操作 Repository（必须通过 Service 层）。
   - 在任意一层中大量编写与本层职责无关的逻辑（例如在 Repository 中写业务判断）。

3. **包结构偏好**（如无现有约束）：
   - `com.xxx.minijira.user`、`com.xxx.minijira.project` 等按业务域划分包。
   - 每个业务域下再细分 `controller`、`service`、`repository`、`dto`、`entity` 等子包。

---

### 3. API 设计规则

1. **路径约定**
   - 所有业务接口统一以 `/api` 开头：
     - `/api/auth/register`、`/api/auth/login`。
     - `/api/projects`、`/api/projects/{projectId}`。
     - `/api/projects/{projectId}/issues`、`/api/projects/{projectId}/issues/{issueId}`。

2. **HTTP 动词使用**
   - GET：查询资源。
   - POST：创建资源。
   - PUT / PATCH：更新资源。
   - DELETE：删除资源。

3. **统一返回格式**
   - 所有对外 API 返回结构必须为：
     {
       "code": 0,
       "message": "ok",
       "data": { }
     }
   - 成功时：`code = 0`，`message` 一般为 "ok" 或简要描述。
   - 失败时：`code != 0`，`message` 为可读错误信息，`data` 可选。

4. **分页接口约定**
   - 查询列表时统一使用 `page`（从 1 开始）和 `pageSize` 参数。
   - 返回数据中建议包含：`total`, `page`, `pageSize`, `items`。

---

### 4. 校验与错误处理

1. **参数校验**
   - 使用 Bean Validation 注解（`@NotBlank`、`@Size`、`@Email` 等）对请求 DTO 进行约束。
   - Controller 方法入参使用 `@Valid` 或 `@Validated` 触发校验。

2. **统一异常处理**
   - 使用 `@ControllerAdvice` + `@ExceptionHandler` 统一捕获常见异常，转换为统一返回结构。
   - 不允许在业务代码中无意义地 `catch (Exception)` 然后忽略异常。

3. **错误码风格**
   - 可以简单使用：
     - `0`：成功。
     - `1000` 段：参数或校验错误。
     - `2000` 段：权限相关错误。
     - `3000` 段：业务类错误。
     - `5000` 段：系统类错误。
   - 实际实现时按项目已有约定为准，如无则遵循上述建议。

---

### 5. 安全与权限规则

1. **认证**
   - 除注册、登录、健康检查等少数接口外，所有接口默认要求 JWT 鉴权。
   - 鉴权逻辑应基于 Spring Security 的过滤器链实现，不要在每个 Controller 里重复写 Token 解析。

2. **授权（权限控制）**
   - 当前登录用户信息统一从 Spring Security 上下文获取。
   - 与项目相关的操作（查看项目、管理任务等）必须检查：
     - 用户是否属于该项目成员。
     - 是否具备项目管理员 / 系统管理员权限（针对敏感操作，如删除项目）。

3. **敏感信息处理**
   - 密码必须使用 BCrypt 或类似算法加密存储。
   - 不在日志、错误信息或响应中输出密码、完整 Token 等敏感数据。

---

### 6. 日志与监控

1. **日志要求**
   - 重要业务操作必须记录 INFO 级日志，例如：
     - 用户登录 / 登出。
     - 创建 / 删除项目。
     - 创建 / 更新 / 删除任务。
   - 日志内容需包含关键标识信息：userId、projectId、issueId（如适用）。

2. **可观测性**
   - 使用 Spring Boot Actuator 暴露健康检查和基本指标（后续阶段引入）。

---

### 7. 数据库与事务

1. **数据库操作规则**
   - 优先使用 Spring Data JPA 提供的方法，如有复杂查询再使用 `@Query` 或 Specification。
   - 对性能敏感的查询需要考虑索引设计。

2. **事务规则**
   - 包含多个写操作的业务方法应使用 `@Transactional` 保证原子性。
   - 不允许在事务内部做长时间阻塞操作（如长时间外部 HTTP 调用），如确有需要应拆分为异步或事件驱动。

---

### 8. 代码风格偏好

1. 命名必须清晰可读，避免过度缩写。
2. 尽量保持方法单一职责，避免超长方法（超过 80～100 行应考虑拆分）。
3. 遵循项目中已有的代码风格，如果新建项目则按常规 Java/Spring 社区习惯来写。

> 总结：任何在本仓库中为“迷你 Jira”项目生成或修改的代码，都应默认遵守以上 Rules，除非用户在对话中明确要求破例或调整。

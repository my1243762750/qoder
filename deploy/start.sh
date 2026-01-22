#!/bin/bash
# Mini Jira 快速启动脚本

set -e

echo "======================================"
echo "🚀 Mini Jira 启动脚本"
echo "======================================"

# 检查 MySQL 是否运行
echo ""
echo "🔍 检查 MySQL 服务..."
if ! mysql -u minijira -pmy@123456 -e "SELECT 1" &> /dev/null; then
    echo "❌ 无法连接到 MySQL，请检查："
    echo "   1. MySQL 服务是否启动"
    echo "   2. 用户名和密码是否正确"
    echo "   3. 数据库 mini_jira 是否已创建"
    exit 1
fi

echo "✅ MySQL 连接成功"

# 启动应用
echo ""
echo "🚀 启动 Spring Boot 应用..."
echo ""

mvn spring-boot:run

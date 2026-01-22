#!/bin/bash
# Mini Jira 项目构建脚本

set -e

echo "======================================"
echo "🚀 Mini Jira 项目构建"
echo "======================================"

# 1. 清理之前的构建
echo ""
echo "📦 清理之前的构建..."
mvn clean

# 2. 编译项目
echo ""
echo "🔨 编译项目..."
mvn compile

# 3. 运行测试
echo ""
echo "🧪 运行测试..."
mvn test

# 4. 打包
echo ""
echo "📦 打包项目..."
mvn package -DskipTests

echo ""
echo "======================================"
echo "✅ 构建成功！"
echo "======================================"
echo ""
echo "生成的 JAR 文件："
ls -lh target/*.jar | grep -v original

echo ""
echo "运行应用："
echo "  java -jar target/mini-jira-0.0.1-SNAPSHOT.jar"
echo ""

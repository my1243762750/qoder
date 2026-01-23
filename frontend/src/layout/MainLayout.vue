<template>
  <div class="common-layout">
    <el-container class="layout-container">
      <el-aside width="240px" class="aside">
        <div class="logo">
          <el-icon class="logo-icon" size="24" color="#409EFF"><Platform /></el-icon>
          <span>Mini Jira</span>
        </div>
        <el-menu
            router
            :default-active="route.path"
            class="el-menu-vertical"
            background-color="#001529"
            text-color="#fff"
            active-text-color="#409EFF"
        >
            <el-menu-item index="/">
                <el-icon><HomeFilled /></el-icon>
                <span>Dashboard</span>
            </el-menu-item>
             <el-menu-item index="/projects">
                <el-icon><List /></el-icon>
                <span>Projects</span>
            </el-menu-item>
        </el-menu>
      </el-aside>
      <el-container>
        <el-header class="header">
            <div class="breadcrumb">
               <!-- Placeholder for breadcrumb if needed -->
            </div>
            <div class="header-right">
                <el-dropdown trigger="click" @command="handleCommand">
                    <span class="el-dropdown-link">
                        <el-avatar :size="32" icon="UserFilled" />
                        <span class="username">{{ username }}</span>
                        <el-icon class="el-icon--right"><arrow-down /></el-icon>
                    </span>
                    <template #dropdown>
                        <el-dropdown-menu>
                            <el-dropdown-item command="profile">Profile</el-dropdown-item>
                            <el-dropdown-item command="settings">Settings</el-dropdown-item>
                            <el-dropdown-item divided command="logout">Logout</el-dropdown-item>
                        </el-dropdown-menu>
                    </template>
                </el-dropdown>
            </div>
        </el-header>
        <el-main class="main-content">
            <router-view v-slot="{ Component }">
                <transition name="fade" mode="out-in">
                    <component :is="Component" />
                </transition>
            </router-view>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { HomeFilled, List, Platform, ArrowDown } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { computed } from 'vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const username = computed(() => userStore.userInfo.username || 'User')

const handleCommand = (command: string) => {
    if (command === 'logout') {
        userStore.logout()
        router.push('/login')
        ElMessage.success('Logged out successfully')
    } else {
        ElMessage.info(`Clicked ${command}`)
    }
}
</script>

<style scoped>
.layout-container {
    height: 100vh;
}
.aside {
    background-color: #001529;
    color: #fff;
    transition: width 0.3s;
    display: flex;
    flex-direction: column;
}
.logo {
    height: 64px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    font-size: 20px;
    font-weight: bold;
    color: #fff;
    background-color: #002140;
}
.el-menu-vertical {
    border-right: none;
    flex: 1;
}
.header {
    background-color: #fff;
    border-bottom: 1px solid #e6e6e6;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 24px;
    box-shadow: 0 1px 4px rgba(0,21,41,.08);
    z-index: 10;
}
.header-right {
    display: flex;
    align-items: center;
}
.el-dropdown-link {
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 8px;
    color: #606266;
}
.username {
    font-weight: 500;
}
.main-content {
    background-color: #f0f2f5;
    padding: 24px;
}

/* Transition */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>

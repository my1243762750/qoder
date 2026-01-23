<template>
  <div class="dashboard">
    <div class="welcome-section">
      <h2>Welcome, {{ userStore.userInfo.username || 'User' }}</h2>
      <p class="subtitle">Here is the overview of your workspace.</p>
    </div>

    <el-row :gutter="20" class="stat-cards">
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>Total Projects</span>
            </div>
          </template>
          <div class="card-content">
            <span class="big-number">{{ stats.totalProjects }}</span>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>Total Issues</span>
            </div>
          </template>
          <div class="card-content">
            <span class="big-number">{{ stats.totalIssues }}</span>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>My Issues</span>
            </div>
          </template>
          <div class="card-content">
            <span class="big-number">{{ stats.myIssues }}</span>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" class="main-sections">
      <el-col :span="24">
        <el-card shadow="hover" class="quick-access">
          <template #header>
            <div class="card-header">
              <span>Quick Actions</span>
            </div>
          </template>
          <div class="action-buttons">
             <el-button type="primary" size="large" @click="router.push('/projects')">
                <el-icon><List /></el-icon> View All Projects
             </el-button>
             <el-button type="success" size="large" @click="router.push('/projects')">
                <el-icon><Plus /></el-icon> Create New Project
             </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { List, Plus } from '@element-plus/icons-vue'
import request from '@/utils/request'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const stats = reactive({
  totalProjects: 0,
  totalIssues: 0,
  myIssues: 0
})

const fetchStats = async () => {
  try {
    const res: any = await request.get('/api/dashboard/stats')
    if (res.data) {
        // Only copy relevant fields
        stats.totalProjects = res.data.totalProjects
        stats.totalIssues = res.data.totalIssues
        stats.myIssues = res.data.myIssues
    }
  } catch (e) {
    console.error('Failed to fetch dashboard stats', e)
  }
}

onMounted(() => {
    fetchStats()
})
</script>

<style scoped>
.welcome-section {
  margin-bottom: 24px;
}
.subtitle {
  color: #909399;
  margin-top: 5px;
}
.stat-cards {
  margin-bottom: 24px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 500;
}
.card-content {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 10px 0;
}
.big-number {
  font-size: 36px;
  font-weight: bold;
  color: #303133;
}
.action-buttons {
  display: flex;
  gap: 20px;
}
</style>

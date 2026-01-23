<template>
  <div class="login-container">
    <div class="login-content">
      <div class="login-header">
        <el-icon class="logo-icon" size="40" color="#409EFF"><Platform /></el-icon>
        <h1 class="app-title">Mini Jira</h1>
        <p class="app-subtitle">Project Management Simplified</p>
      </div>
      <el-card class="login-card" shadow="hover">
        <h2>Login</h2>
        <el-form :model="form" :rules="rules" ref="formRef" label-position="top" size="large">
          <el-form-item label="Username or Email" prop="usernameOrEmail">
            <el-input v-model="form.usernameOrEmail" :prefix-icon="User" placeholder="Enter your username" />
          </el-form-item>
          <el-form-item label="Password" prop="password">
            <el-input v-model="form.password" type="password" :prefix-icon="Lock" placeholder="Enter your password" show-password />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleLogin" :loading="loading" class="full-width-btn">Login</el-button>
          </el-form-item>
          <div class="form-footer">
            <span>Don't have an account?</span>
            <el-button link type="primary" @click="handleRegister">Register Now</el-button>
          </div>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'
import { ElMessage } from 'element-plus'
import { Platform, User, Lock } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref()
const loading = ref(false)

const form = reactive({
  usernameOrEmail: '',
  password: ''
})

const rules = {
  usernameOrEmail: [{ required: true, message: 'Please input username', trigger: 'blur' }],
  password: [{ required: true, message: 'Please input password', trigger: 'blur' }]
}

const handleLogin = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid: boolean) => {
    if (valid) {
      loading.value = true
      try {
        const res: any = await request.post('/api/auth/login', form)
        const data = res.data
        if (data?.token) {
           userStore.setToken(data.token)
           userStore.setUserInfo(data.username, data.email)
           ElMessage.success('Login success')
           router.push('/')
        } else {
            ElMessage.error('No token received')
        }
      } catch (e) {
        // Error handled in interceptor
      } finally {
        loading.value = false
      }
    }
  })
}

const handleRegister = () => {
    router.push('/register')
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #001529 0%, #002140 100%);
  padding: 20px;
}
.login-content {
  width: 100%;
  max-width: 400px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}
.login-header {
  text-align: center;
  color: #fff;
}
.app-title {
  margin: 10px 0 5px;
  font-size: 28px;
  font-weight: bold;
}
.app-subtitle {
  margin: 0;
  opacity: 0.8;
  font-size: 14px;
}
.login-card {
  width: 100%;
  border-radius: 8px;
}
.full-width-btn {
  width: 100%;
}
.form-footer {
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 14px;
  color: #606266;
  margin-top: -10px;
}
</style>

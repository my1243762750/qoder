<template>
  <div class="register-container">
    <div class="register-content">
      <div class="register-header">
        <el-icon class="logo-icon" size="40" color="#409EFF"><Platform /></el-icon>
        <h1 class="app-title">Mini Jira</h1>
        <p class="app-subtitle">Join us and start managing efficiently</p>
      </div>
      <el-card class="register-card" shadow="hover">
        <h2>Register</h2>
        <el-form :model="form" :rules="rules" ref="formRef" label-position="top" size="large">
          <el-form-item label="Email" prop="email">
            <el-input v-model="form.email" prefix-icon="Message" placeholder="Enter your email" />
          </el-form-item>
          <el-form-item label="Username" prop="username">
            <el-input v-model="form.username" prefix-icon="User" placeholder="Choose a username" />
          </el-form-item>
          <el-form-item label="Password" prop="password">
            <el-input v-model="form.password" type="password" prefix-icon="Lock" placeholder="Create a password" show-password />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleRegister" :loading="loading" class="full-width-btn">Create Account</el-button>
          </el-form-item>
          <div class="form-footer">
            <span>Already have an account?</span>
            <el-button link type="primary" @click="goToLogin">Login here</el-button>
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
import { ElMessage, type FormRules } from 'element-plus'
import { Platform } from '@element-plus/icons-vue'

const router = useRouter()
const formRef = ref()
const loading = ref(false)

const form = reactive({
  email: '',
  username: '',
  password: ''
})

const rules = reactive<FormRules>({
  email: [
      { required: true, message: 'Please input email', trigger: 'blur' },
      { type: 'email', message: 'Please input correct email address', trigger: ['blur', 'change'] }
  ],
  username: [{ required: true, message: 'Please input username', trigger: 'blur' }],
  password: [{ required: true, message: 'Please input password', trigger: 'blur' }]
})

const handleRegister = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid: boolean) => {
    if (valid) {
      loading.value = true
      try {
        await request.post('/api/auth/register', form)
        ElMessage.success('Registration success')
        router.push('/login')
      } catch (e) {
        // Error handled in interceptor
      } finally {
        loading.value = false
      }
    }
  })
}

const goToLogin = () => {
  router.push('/login')
}
</script>

<style scoped>
.register-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #001529 0%, #002140 100%);
  padding: 20px;
}
.register-content {
  width: 100%;
  max-width: 400px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}
.register-header {
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
.register-card {
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

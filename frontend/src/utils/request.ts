import axios from 'axios'
import { ElMessage } from 'element-plus'

const service = axios.create({
  timeout: 5000
})

service.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

service.interceptors.response.use(
  (response) => {
    const res = response.data
    // If code is not 0, it means error (based on backend ApiResponse)
    // Adjust logic if backend returns direct data for some endpoints, 
    // but standard qoder backend uses ApiResponse
    if (res.code !== undefined && res.code !== 0) {
      ElMessage.error(res.message || 'Error')
      return Promise.reject(new Error(res.message || 'Error'))
    }
    return res
  },
  (error) => {
    console.error('err' + error)
    ElMessage.error(error.message || 'Request Error')
    return Promise.reject(error)
  }
)

export default service

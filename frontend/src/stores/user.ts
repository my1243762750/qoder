import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref({
    username: localStorage.getItem('username') || '',
    email: localStorage.getItem('email') || ''
  })

  const setToken = (newToken: string) => {
    token.value = newToken
    localStorage.setItem('token', newToken)
  }

  const setUserInfo = (username: string, email: string) => {
    userInfo.value.username = username
    userInfo.value.email = email
    localStorage.setItem('username', username)
    localStorage.setItem('email', email)
  }

  const logout = () => {
    token.value = ''
    userInfo.value = { username: '', email: '' }
    localStorage.removeItem('token')
    localStorage.removeItem('username')
    localStorage.removeItem('email')
  }

  return { token, userInfo, setToken, setUserInfo, logout }
})

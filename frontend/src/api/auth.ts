import api from './index'

export const login = (email: string, password: string) => {
  return api.post('/auth/login', { email, password })
}

export const register = (email: string, password: string) => {
  return api.post('/auth/register', { email, password })
}
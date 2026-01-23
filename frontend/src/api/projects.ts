import api from './index'

export interface Project {
  id: number
  name: string
  description: string
  ownerId: number
}

export interface Issue {
  id: number
  title: string
  description: string
  priority: string
  status: string
  projectId: number
}

export const getProjects = () => {
  return api.get<Project[]>('/projects')
}

export const createProject = (data: { name: string; description: string }) => {
  return api.post('/projects', data)
}

export const getProject = (id: string) => {
  return api.get<Project>(`/projects/${id}`)
}

export const getIssues = (projectId: string) => {
  return api.get<Issue[]>(`/projects/${projectId}/issues`)
}

export const createIssue = (projectId: string, data: { title: string; description: string; priority: string }) => {
  return api.post(`/projects/${projectId}/issues`, data)
}
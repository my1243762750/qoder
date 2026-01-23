<template>
  <div class="project-details" v-loading="loading">
    <div v-if="project" class="project-header">
      <div class="header-left">
        <el-button @click="$router.push('/projects')" icon="Back" circle />
        <h2 class="project-title">{{ project.name }}</h2>
      </div>
      <div class="header-right">
        <el-button type="primary" @click="showCreateIssueDialog">
          <el-icon><Plus /></el-icon> Create Issue
        </el-button>
        <el-popconfirm title="Are you sure to delete this project?" @confirm="deleteProject">
          <template #reference>
            <el-button type="danger" icon="Delete" circle />
          </template>
        </el-popconfirm>
      </div>
    </div>
    <p v-if="project" class="project-desc">{{ project.description }}</p>

    <div class="kanban-board">
      <div class="kanban-column" v-for="status in statuses" :key="status">
        <div class="column-header">
          <span class="status-title">{{ formatStatus(status) }}</span>
          <el-tag :type="getStatusType(status)" size="small" effect="dark">{{ getIssuesByStatus(status).length }}</el-tag>
        </div>
        <div class="column-content">
          <el-card v-for="issue in getIssuesByStatus(status)" :key="issue.id" class="issue-card" shadow="hover">
            <div class="issue-header">
              <span class="issue-title">{{ issue.title }}</span>
              <el-dropdown trigger="click" @command="(cmd) => handleIssueAction(cmd, issue)">
                <span class="el-dropdown-link">
                  <el-icon><More /></el-icon>
                </span>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item v-for="s in statuses" :key="s" :command="'status:' + s" :disabled="s === issue.status">
                      Move to {{ formatStatus(s) }}
                    </el-dropdown-item>
                    <el-dropdown-item divided command="delete" style="color: red;">Delete</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
            <p class="issue-desc">{{ issue.description }}</p>
            <div class="issue-footer">
              <el-tag size="small" :type="getPriorityType(issue.priority)">{{ issue.priority }}</el-tag>
              <span class="issue-id">#{{ issue.id }}</span>
            </div>
          </el-card>
        </div>
      </div>
    </div>

    <!-- Create Issue Dialog -->
    <el-dialog v-model="createDialogVisible" title="Create Issue" width="500px">
      <el-form :model="issueForm" label-position="top" :rules="rules" ref="issueFormRef">
        <el-form-item label="Title" prop="title">
          <el-input v-model="issueForm.title" placeholder="Issue title" />
        </el-form-item>
        <el-form-item label="Description" prop="description">
          <el-input v-model="issueForm.description" type="textarea" :rows="3" placeholder="Description" />
        </el-form-item>
        <el-form-item label="Priority" prop="priority">
          <el-select v-model="issueForm.priority" placeholder="Select priority">
            <el-option label="Low" value="LOW" />
            <el-option label="Medium" value="MEDIUM" />
            <el-option label="High" value="HIGH" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="createDialogVisible = false">Cancel</el-button>
          <el-button type="primary" @click="createIssue" :loading="creating">Create</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, reactive } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import request from '@/utils/request'
import { ElMessage, type FormInstance } from 'element-plus'
import { Plus, More } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const projectId = route.params.id

const loading = ref(false)
const project = ref<any>(null)
const issues = ref<any[]>([])
const statuses = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED']

const createDialogVisible = ref(false)
const creating = ref(false)
const issueFormRef = ref<FormInstance>()
const issueForm = reactive({
  title: '',
  description: '',
  priority: 'MEDIUM'
})

const rules = {
  title: [{ required: true, message: 'Please input title', trigger: 'blur' }],
  priority: [{ required: true, message: 'Please select priority', trigger: 'change' }]
}

const fetchData = async () => {
  loading.value = true
  try {
    const [pRes, iRes] = await Promise.all([
      request.get(`/api/projects/${projectId}`),
      request.get(`/api/projects/${projectId}/issues`)
    ])
    project.value = pRes.data
    issues.value = iRes.data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const getIssuesByStatus = (status: string) => {
  return issues.value.filter(i => i.status === status)
}

const formatStatus = (status: string) => {
  return status.replace('_', ' ')
}

const getStatusType = (status: string) => {
  const map: any = { OPEN: 'info', IN_PROGRESS: 'primary', RESOLVED: 'success', CLOSED: '' }
  return map[status] || 'info'
}

const getPriorityType = (priority: string) => {
  const map: any = { LOW: 'info', MEDIUM: 'warning', HIGH: 'danger' }
  return map[priority] || 'info'
}

const showCreateIssueDialog = () => {
  createDialogVisible.value = true
}

const createIssue = async () => {
  if (!issueFormRef.value) return
  await issueFormRef.value.validate(async (valid) => {
    if (valid) {
      creating.value = true
      try {
        await request.post(`/api/projects/${projectId}/issues`, issueForm)
        ElMessage.success('Issue created')
        createDialogVisible.value = false
        fetchData()
        issueForm.title = ''
        issueForm.description = ''
        issueForm.priority = 'MEDIUM'
      } catch (e) {
        // handled
      } finally {
        creating.value = false
      }
    }
  })
}

const handleIssueAction = async (command: string, issue: any) => {
  if (command === 'delete') {
    try {
      await request.delete(`/api/issues/${issue.id}`)
      ElMessage.success('Issue deleted')
      fetchData()
    } catch (e) {
      // handled
    }
  } else if (command.startsWith('status:')) {
    const newStatus = command.split(':')[1]
    try {
      await request.put(`/api/issues/${issue.id}`, { status: newStatus })
      ElMessage.success('Status updated')
      fetchData()
    } catch (e) {
      // handled
    }
  }
}

const deleteProject = async () => {
  try {
    await request.delete(`/api/projects/${projectId}`)
    ElMessage.success('Project deleted')
    router.push('/projects')
  } catch (e) {
    // handled
  }
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.project-details {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.project-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}
.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
}
.project-title {
  margin: 0;
  font-size: 24px;
}
.project-desc {
  color: #666;
  margin-bottom: 20px;
}
.kanban-board {
  display: flex;
  gap: 20px;
  overflow-x: auto;
  flex: 1;
  padding-bottom: 20px;
}
.kanban-column {
  min-width: 280px;
  width: 280px;
  background-color: #f4f5f7;
  border-radius: 6px;
  display: flex;
  flex-direction: column;
  max-height: 100%;
}
.column-header {
  padding: 12px 16px;
  font-weight: 600;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #dfe1e6;
}
.column-content {
  padding: 10px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.issue-card {
  cursor: pointer;
  transition: transform 0.2s;
}
.issue-card:hover {
  transform: translateY(-2px);
}
.issue-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 8px;
}
.issue-title {
  font-weight: 500;
  line-height: 1.4;
}
.issue-desc {
  font-size: 13px;
  color: #666;
  margin: 0 0 10px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.issue-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.issue-id {
  font-size: 12px;
  color: #999;
}
</style>

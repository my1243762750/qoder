<template>
  <div class="project-list-view">
    <el-card shadow="never" class="list-card">
      <template #header>
        <div class="header-actions">
          <div class="left-panel">
            <h2>Projects</h2>
            <el-input
              v-model="searchQuery"
              placeholder="Search projects..."
              prefix-icon="Search"
              class="search-input"
              clearable
            />
          </div>
          <el-button type="primary" @click="openCreateDialog">
            <el-icon><Plus /></el-icon> Create Project
          </el-button>
        </div>
      </template>

      <el-table 
        :data="projects" 
        style="width: 100%" 
        v-loading="loading"
        empty-text="No projects found"
      >
        <el-table-column prop="name" label="Name" min-width="180">
            <template #default="scope">
                <span class="project-name">{{ scope.row.name }}</span>
            </template>
        </el-table-column>
        <el-table-column prop="description" label="Description" min-width="250" show-overflow-tooltip />
        <el-table-column prop="ownerId" label="Owner" width="120">
             <template #default>
                <el-tag size="small" type="info">Admin</el-tag>
             </template>
        </el-table-column>
        <el-table-column label="Actions" width="150" fixed="right">
            <template #default="scope">
                <el-button link type="primary" size="small" @click="viewProject(scope.row.id)">View</el-button>
                <el-button link type="danger" size="small" @click="openEditDialog(scope.row)">Settings</el-button>
            </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog 
        v-model="dialogVisible" 
        :title="isEdit ? 'Edit Project' : 'Create Project'" 
        width="500px"
        destroy-on-close
    >
      <el-form :model="form" label-position="top" :rules="rules" ref="formRef">
        <el-form-item label="Project Name" prop="name">
          <el-input v-model="form.name" placeholder="Enter project name" />
        </el-form-item>
        <el-form-item label="Description" prop="description">
          <el-input 
            v-model="form.description" 
            type="textarea" 
            :rows="3"
            placeholder="Enter project description" 
           />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-popconfirm 
            v-if="isEdit"
            title="Are you sure to delete this project?" 
            @confirm="handleDelete"
          >
            <template #reference>
              <el-button type="danger" plain style="float: left">Delete Project</el-button>
            </template>
          </el-popconfirm>
          <el-button @click="dialogVisible = false">Cancel</el-button>
          <el-button type="primary" @click="handleSubmit" :loading="creating">
            {{ isEdit ? 'Save Changes' : 'Create Project' }}
          </el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import request from '@/utils/request'
import { ElMessage, type FormInstance } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'

const router = useRouter()
const projects = ref([])
const loading = ref(false)
const dialogVisible = ref(false)
const creating = ref(false)
const searchQuery = ref('')
const formRef = ref<FormInstance>()
const isEdit = ref(false)
const currentProjectId = ref<number | null>(null)

const form = reactive({
  name: '',
  description: ''
})

const rules = {
    name: [{ required: true, message: 'Please input project name', trigger: 'blur' }]
}

const fetchProjects = async () => {
  loading.value = true
  try {
    const res: any = await request.get('/api/projects')
    projects.value = res.data
  } catch (e) {
    // handled
  } finally {
    loading.value = false
  }
}

const openCreateDialog = () => {
  isEdit.value = false
  currentProjectId.value = null
  form.name = ''
  form.description = ''
  dialogVisible.value = true
}

const openEditDialog = (row: any) => {
  isEdit.value = true
  currentProjectId.value = row.id
  form.name = row.name
  form.description = row.description
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
      if (valid) {
          creating.value = true
          try {
            if (isEdit.value && currentProjectId.value) {
                await request.put(`/api/projects/${currentProjectId.value}`, form)
                ElMessage.success('Project updated successfully')
            } else {
                await request.post('/api/projects', form)
                ElMessage.success('Project created successfully')
            }
            dialogVisible.value = false
            fetchProjects()
          } catch (e) {
            // handled
          } finally {
              creating.value = false
          }
      }
  })
}

const handleDelete = async () => {
    if (!currentProjectId.value) return
    try {
        await request.delete(`/api/projects/${currentProjectId.value}`)
        ElMessage.success('Project deleted successfully')
        dialogVisible.value = false
        fetchProjects()
    } catch (e) {
        // handled
    }
}

const viewProject = (id: number) => {
    router.push(`/projects/${id}`)
}


onMounted(() => {
  fetchProjects()
})
</script>

<style scoped>
.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.left-panel {
    display: flex;
    align-items: center;
    gap: 20px;
}
.left-panel h2 {
    margin: 0;
    font-size: 18px;
    font-weight: 600;
}
.search-input {
    width: 250px;
}
.project-name {
    font-weight: 500;
    color: #409EFF;
}
</style>

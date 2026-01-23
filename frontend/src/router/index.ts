import { createRouter, createWebHistory } from 'vue-router'
import MainLayout from '../layout/MainLayout.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/LoginView.vue')
    },
    {
        path: '/register',
        name: 'register',
        component: () => import('../views/RegisterView.vue')
    },
    {
      path: '/',
      component: MainLayout,
      children: [
        {
          path: '',
          name: 'home',
          component: () => import('../views/HomeView.vue')
        },
        {
          path: 'projects',
          name: 'projects',
          component: () => import('../views/ProjectListView.vue')
        }
      ]
    }
  ]
})

router.beforeEach((to, _from, next) => {
    const token = localStorage.getItem('token')
    if (to.name !== 'login' && to.name !== 'register' && !token) {
        next({ name: 'login' })
    } else {
        next()
    }
})

export default router

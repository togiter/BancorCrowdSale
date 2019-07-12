import Vue from 'vue'
import Router from 'vue-router'
import HelloWorld from '@/components/HelloWorld'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'HelloWorld',
      component: HelloWorld,
      children:[
        
      ]
    },
    {
      path:'/operate',
      name:'operate',
      component: () => import('@/components/operate.vue')
    },
    {
      path:'/walletOP',
      name:'walletOP',
      component: () => import('@/components/walletOP.vue')
    }

  ]
})

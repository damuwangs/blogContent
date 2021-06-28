---
title: "Vue2-刷新组件"
date: "2021-06-28"
tags: [编程]
categories: 前端

---

# 刷新组件

## provide、inject 结合 v-if

这对选项需要一起使用，以允许一个根组件向其所有子组件注入一个依赖，实现原理就是通过控制router-view 的显示与隐藏，来重渲染路由区域，重而达到页面刷新的效果，show -> false -> show

1. 修改app.vue，利用 v-if 可以刷新页面的属性，同时使用 provide 和 inject 将祖先节点的数据传递给子代节点

   ```
   <template>
       <div id="app">
           <router-view v-if="isRouterAlive"></router-view>
       </div>
   </template>
    
   <script>
   export default {
       name: 'App',
       provide (){
           return {
               reload:this.reload
           }
       },
       data(){
           return {
               isRouterAlive:true
           }
       },
       methods:{
           reload (){
               this.isRouterAlive = false
               this.$nextTick(function(){
                   this.isRouterAlive = true
               })
           }
      }
   }
   </script>
   ```

   

2. 在要刷新的子路由页面引入inject,然后执行reload事件即可刷新页面

   ```
   export default {    
       inject:['reload'],
       data() {
           return {}
       },
       methods: {
           reflesh(){
               this.reload()
           }
       }
   }
   ```

## forceUpdate

```
export default {
    methods: {
        handleUpdateClick() {
            this.$forceUpdate()
        }
    }
}
```

由于一些嵌套特别深的数据，导致数据更新了，但是页面却没有重新渲染。我遇到的一个情况是，v-for遍历数据渲染，当方法中处理相应数组数据时，数组改变了，但是页面却没有重新渲染

解决方法：运用 `this.$forceUpdate()`强制刷新，解决v-for更新数据不重新渲染页面

官方解释：迫使 Vue 实例重新渲染。注意它仅仅影响实例本身和插入插槽内容的子组件，而不是所有子组件

## 修改组件key值

key-changing的原理很简单，vue使用`key`标记组件身份，当`key`改变时就是释放原始组件，重新加载新的组件

```
<template>
    <div>
        <!-- 父组件 -->
        <div>
            <button @click="reLoad">点击重新渲染子组件</button>
        </div>
        <!-- 内容库子组件 -->
        <lib-window :key="time" :channelCode="searchChannelCode"></lib-window>
    </div>
</template>
 
<script>
import children from '@/components/parent/children'
export default {
    name: 'contentLib',
    components: { libWindow },
    data () {
        return {
            time: ''
        }
    },
    methods: {
        reLoad () {
            this.time = new Date().getTime()
        }
    }
}
</script>
```



## eventHub

一般比较适合毫无关系的页面之间的刷新，如页面添加了keep-alive缓存，但是又需要在特定操作下重新初始化数据

- main.js

  ```
  // 给Vue函数添加一个原型属性$eventHub
  Vue.prototype.$eventHub = Vue.prototype.$eventHub || new Vue()
  ```

- 页面A

  ```
  // 一般情况下为了避免重名需要给事件名后面加唯一标记
  let timestamp = Date.parse(new Date())
  // 通过路由传参将timestamp传给目标页面
  this.$router.push({path: '/xxx', query: {timestamp: timestamp}})
  // 父组件发送一个全局事件
  this.$eventHub.$emit('refresh' + timestamp)
  ```

- 页面B

  ```jsp
  // 接受路由参数
  let timestamp = this.$route.query.timestamp
  // 接收全局事件
  this.$eventHub.$on('refresh' + timestamp, (params) => {
  	// 初始化数据方法
  	this.fetchData()
  })
  ```

# 参考资料

> [vue项目刷新当前页面的几种解决方案对比：如何优雅的强制重新渲染子组件](https://www.cnblogs.com/goloving/p/13941836.html)
>
> [Vue 数据更新了但页面没有更新的 7 种情况汇总及延伸](https://cloud.tencent.com/developer/article/1637749)


---
title: "Vue2-nextTick"
date: "2021-06-28"
tags: [编程]
categories: VUE

---

# 概念

> 官方文档说明：在下次 DOM 更新循环结束之后执行延迟回调。在修改数据之后立即使用这个方法，获取更新后的 DOM

## 异步解析

> Vue 实现响应式并不是数据发生变化之后 DOM 立即变化，而是按一定的策略进行 DOM 的更新

​	简而言之，异步接信息的运行机制如下

1. 所有同步任务都在主线程上执行，形成一个[执行栈](https://www.ruanyifeng.com/blog/2013/11/stack.html)（execution context stack）
2. 主线程之外，还存在一个"任务队列"（task queue）。只要异步任务有了运行结果，就在"任务队列"之中放置一个事件
3. 一旦"执行栈"中的所有同步任务执行完毕，系统就会读取"任务队列"，看看里面有哪些事件。那些对应的异步任务，于是结束等待状态，进入执行栈，开始执行
4. 主线程不断重复上面的第三步

## 事件循环说明

简单来说，Vue 在修改数据后，视图不会立刻更新，而是等**同一事件循环**中的所有数据变化完成之后，再统一进行视图更新

```js
//改变数据
vm.message = 'changed'

//想要立即使用更新后的DOM。这样不行，因为设置message后DOM还没有更新
console.log(vm.$el.textContent) // 并不会得到'changed'

//这样可以，nextTick里面的代码会在DOM更新后执行
Vue.nextTick(function(){
    console.log(vm.$el.textContent) // 可以得到'changed'
})
```

![](/img/Vue2-nextTick/事件循环.png)

1. 本次更新循环

   - 首先修改数据，这是同步任务。同一事件循环的所有同步任务都在主线程上执行，形成一个执行栈，此时还未涉及DOM
   - Vue开启一个异步队列，并缓冲再次事件循环中发生的所有数据改变。如果同一个watcher被多次执行，只会被推入到队列中一次

2. 下次更新循环

   - 同步任务执行完毕，开始执行异步watcher队列的任务，更新DOM。Vue在内部尝试对异步队列使用原生的Promise.then和messageChannel方法，如果执行环境不支持，会采用setTimeOut(fn,0)代替

3. 下次更新循环结束之后

   此时通过Vue.nextTick获取到改变后的DOM。通过setTimeOut(fn,0)也可以同样获取到

简单总结事件循环：

- 同步代码执行
- 查找异步队列，推入执行栈，执行Vue.nextTick[事件1]
- 查找异步队列，推入执行栈，执行Vue.nextTick[事件2]

总之，异步是单独的一个tick，不会和同步在同一个tick里发生，也是DOM不会马上改变的原因

# 应用场景

1. 在 created 和 mounted 阶段，如果需要操作渲染后的试图，也要使用 nextTick 方法。

> 官方文档说明：注意 mounted 不会承诺所有的子组件也都一起被挂载。如果你希望等到整个视图都渲染完毕，可以用 vm.$nextTick 替换掉 mounted

```js
created(){
    let that=this
    that.$nextTick(
    	function(){  
    		//不使用this.$nextTick()方法会报错
        	that.$refs.aa.innerHTML = "created中更改了按钮内容" // 写入到DOM元素
        }
    })
}
```

2. 当项目中你想在改变 DOM 元素的数据后基于新的 dom 做点什么，对新 DOM 一系列的 js 操作都需要放进 Vue.nextTick()的回调函数中；通俗的理解是：更改数据后当你想立即使用 js 操作新的视图的时候需要使用它

```vue
<template>
    <div class="app">
        <div ref="msgDiv">{{msg}}</div>
      	<div v-if="msg1">Message got outside $nextTick: {{msg1}}</div>
      	<div v-if="msg2">Message got inside $nextTick: {{msg2}}</div>
      	<div v-if="msg3">Message got outside $nextTick: {{msg3}}</div>
      	<button @click="changeMsg">Change the Message</button>
    </div>
</template>
 
<script>
export default {
    data () {
        return {
            msg: 'Hello Vue.',
            msg1: '',
            msg2: '',
            msg3: ''
        }
    },
    methods:{
        changeMsg() {
            this.msg = "Hello world."
            this.msg1 = this.$refs.msgDiv.innerHTML
            this.$nextTick(() => {
                this.msg2 = this.$refs.msgDiv.innerHTML
            })
            this.msg3 = this.$refs.msgDiv.innerHTML
        }
    }
}    
```

点击前

![](/img/Vue2-nextTick/点击前.png)

点击后

![](/img/Vue2-nextTick/点击后.png)

从图中可以得知：msg1和msg3显示的内容还是变换之前的，而msg2显示的内容是变换之后的

# 通过一个实例理解nextTick

```vue
<template>
    <div class="content">
        <ul>
            <li v-for="item in list1" :key="item">{{item}}</li>
        </ul>
        <ul>
       	    <li v-for="item in list2" :key="item">{{item}}</li>
        </ul>
        <ol>
            <li v-for="item in list3" :key="item">{{item}}</li>
        </ol>
        <ol>
            <li v-for="item in list4" :key="item">{{item}}</li>
        </ol>
        <ol>
            <li v-for="item in list5" :key="item">{{item}}</li>
        </ol>
    </div>
</template>

<script>
import {dateFormat} from '@/components/JS方法库/util/common.js'
export default {
  data () {
        return {
            list1: [],
            list2: [],
            list3: [],
            list4: [],
            list5: []
        }
    },
    created(){
        this.composeList12()
        this.composeList34()
        this.composeList5()
        this.$nextTick(function() {
            // DOM 更新了
            console.log('[7]同步视图更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)
            console.log('——————————同步视图更新完成——————————')
        })
    },
 
    methods: {
        composeList12() {
            for (let i = 0; i < 10000; i++) {
                this.$set(this.list1, i, 'I am a 测试信息～～啦啦啦' + i)
            }
            console.log('——————————开始更新同步数据——————————')
            console.log('[1]同步数据更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)

            for (let i = 0; i < 10000; i++) {
                this.$set(this.list2, i, 'I am a 测试信息～～啦啦啦' + i)
            }
            console.log('[2]同步数据更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)

            this.$nextTick(function() {
                // DOM 更新了
                console.log('[1][2]同步视图更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)
            })
        },
        composeList34() {
            for (let i = 0; i < 10000; i++) {
                this.$set(this.list3, i, 'I am a 测试信息～～啦啦啦' + i)
            }
            console.log('[3]同步数据更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)

            this.$nextTick(function() {
                // DOM 更新了
                console.log('[3]同步视图更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)
            })

            setTimeout(this.setTimeout1, 0)
        },
        setTimeout1() {
            for (let i = 0; i < 10000; i++) {
                this.$set(this.list4, i, 'I am a 测试信息～～啦啦啦' + i)
            }
            console.log('——————————开始更新异步数据——————————')
            console.log('[4]异步数据更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)

            this.$nextTick(function() {
                // DOM 更新了
                console.log('[4]异步视图更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)
            })
        },
        composeList5() {
            this.$nextTick(function() {
                // DOM 更新了
                console.log('[5]同步视图更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)
            })

            setTimeout(this.setTimeout2, 0)
        },
        setTimeout2() {
            for (let i = 0; i < 10000; i++) {
                this.$set(this.list5, i, 'I am a 测试信息～～啦啦啦' + i)
            }
            console.log('[6]异步数据更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)

            this.$nextTick(function() {
                // DOM 更新了
                console.log('[6]异步视图更新 - ' + dateFormat(new Date() ,'yyyy-MM-dd hh:mm:ss'),document.querySelectorAll('li').length)
                console.log('——————————异步视图更新完成——————————')
            })
        },
    }
}
</script>
```

运行结果如下：

![](/img/Vue2-nextTick/实例.png)

- 通过list1、2、3验证，处在同步代码中的DOM更新情况及nextTick的触发时机

- 通过list3、list4验证，同步代码及异步代码中Dom更新及nextTick触发的区别

- list4、list5对比验证，多个异步代码中nextTick触发的区别

- 通过在视图更新后获取DOM中<li>的数量，判断nextTick序列渲染的时间点

# 参考资料

> [Vue.nextTick 的原理和用途](https://segmentfault.com/a/1190000012861862)
>


---
title: "Vue2-响应式原理"
date: "2021-10-13"
tags: [编程]
categories: VUE

---

# 概述

Vue采用数据劫持结合发布者-订阅者模式的方式来实现数据的响应式，

**监听属性变化**

1. Vue在初始化的时候，对data对象进行遍历，在这个方法中会调Observe（监听器，观察者）对用户的数据进行监听
2. 在observe中对数据进行判断，对对象进行循环，使用defineReactive，它是vue中的一个核心方法，用来定义响应式
3. defineReactive方法中实例化了一个Dep（发布者），通过Object.defineProperty对数据进行拦截，把这些 property 全部转为 getter/setter。get数据的时候，通过dep.depend触发Watcher（订阅者）的依赖收集，收集订阅者；set时，会对数据进行比较，如果数据发生了变化会通过dep.notify发布通知，通知Watcher，更新视图

**解析指令**

1. Vue在初始化时传入当前Vue实例和html根节点的元素标识，进行模板解析

2. 首先会取出模板元素将其转化成fragment编译后统一进行dom挂载，这样做比较高效（此为虚拟dom）

3. 循环从fragment取出所有元素子节点，进行指令类型判断（以v-text为例），传入指令类型和属性值调用update方法

4. update方法中会将视图与vue实例的data属性绑定渲染页面数据。

    当data属性值发生变化会被defineReactive监听到，然后通知wctaher绑定新的数据更新视图

![](/img/Vue2-响应式原理/响应式图解.png)

# 代码

## template

```html
<div id="app">
    <!-- 双向绑定 -->
    <input type="text" v-model="name">
</div>
```

## 监听属性变化

初始化vue时会传入一个json格式的对象

```js
let vue = new Vue({
    el: '#app',
    data: {
        name: "name",
    }
})
```

取出该对象并遍历data数据，使用Object.defineProperty()方法来监听每一个属性的变化

```js
observe(value){
    if (!value || typeof value !== 'object') {
        return
    }
    //遍历data
    Object.keys(value).forEach(key =>{
        this.defineReactive(value,key,value[key])
        // 代理data中的属性到vue实例上
        this.proxyData(key)
    })
}
```

使用defineReactive，用来定义响应式

```js
defineReactive(data, key, value){
    this.observe(value) //递归解决数据嵌套
    const dep = new Dep()
    Object.defineProperty(data, key, {
        get(){
            Dep.target && dep.addDep(Dep.target)
            return value
        },
        set(newVal){
            if (newVal == value) {
                return
            }
            value = newVal
            dep.notify()
        }
    })
}
```

因为要实现数据动态绑定所以定义了Dep(依赖管理器)和Watcher(依赖)
Watcher为Dep的子对象，当Watcher初始化时会将当前Watcher实例放进Dep的静态属性target中，然后再读取当前vue实例的数据，触发Object.defineProperty()的getter
Object.defineProperty()触发getter时会先判断全局静态属性是否存在，如果存在则添加Watcher依赖
当数据发生变化时，触发Object.defineProperty()的setter,如果新旧数据没有发生变化则直接return,如果新旧数据发生变化则调用Dep的notify方法循环获取所有依赖进行update

```js
// Dep 用来管理依赖(Watcher)
class Dep {
    constructor(){
        // 这里存放若干依赖(Watcher),一个Watcher对应一个key
        this.deps = [] 
    }

    // 添加依赖
    addDep(dep){
        this.deps.push(dep)
    }

    // 通知所有依赖
    notify(){
        this.deps.forEach(dep =>{dep.update()})
    }
}

// 依赖
class Watcher {
    constructor(vm, key, callback){
        this.vm = vm
        this.key = key
        this.callback = callback
        
        // 将当前Watcher实例指定到Dep静态属性target
        Dep.target = this
        this.vm[this.key] // 触发getter,添加依赖
        Dep.target = null
        console.log('Watcher');
    }

    update(){
        console.log('属性更新了')
        this.callback.call(this.vm, this.vm[this.key])
    }
}
```

## 解析指令

在数据相应话之后会进行模板的解析，传入当前页面元素和vue实例。首先将元素转化成fragment

```js
// 取出宿主元素将其转换成fragment编译后统一进行dom挂载,这样做比较高效
node2Fragment(el){
    // fragment详细解释查看参考资料
    const frag = document.createDocumentFragment()
    //将el中所有子元素搬家至frag中
    let child
    //每次拿出el里面的首个元素赋值给child,然后把child放进frag
    while (child = el.firstChild) {
        frag.appendChild(child)
    }
    return frag
}
```

解析指令

```js
compile(el){
    //获取元素子节点
    const childNodes = el.childNodes 
    // 将结果转换成数组进行遍历
    Array.from(childNodes).forEach(node => {
        //类型判断（nodeType详细解析查看参考资料）
        if (node.nodeType === 1) {
            // 元素
            // 查找k-, @, :
            const nodeAttrs = node.attributes //拿出节点所有属性
            Array.from(nodeAttrs).forEach(attr => {
                const attrName = attr.name // 属性名：v-model
                const attrValue = attr.value // 属性值：name
                if (attrName.indexOf('v-') == 0) {
                    //如果是指令则截取掉前缀v-
                    const dir = attrName.substring(2)
                    // 执行指令
                    // this[dir] = this.model()
                    this[dir] && this[dir](node, this.vm, attrValue)
                }              
            })
        }
        //递归子节点
        if (node.childNodes && node.childNodes.length > 0) {
            this.compile(node)
        }
    })
}
```

绑定视图

```js
model(node, vm, attrValue){
	this.update(node, vm, attrValue, 'model') 
    // 视图对模型的响应
    node.addEventListener('input',e => {
        vm[attrValue] = e.target.value
    })
}
```

通过wctaher监听数据变化更新视图

```js
// 参数：节点、vue实例、指令值(name)、指令类型(model)
update(node, vm, attrValue, dir){
    // 根据指令名称+Updater拼接要执行的修改方法(类似java的反射)
    // updateFn = modelUpdater
    const updateFn = this[dir+'Updater']
    // 第一次更新
    updateFn && updateFn(node, vm[attrValue])
    // 依赖收集
    new Watcher(vm, attrValue, function(value){
        updateFn && updateFn(node, value)
    })
}
```

绑定新数据刷新视图

```js
modelUpdater(node, value){
    node.value = value
}
```

# 参考资料

> [HTML DOM nodeType 属性](https://www.w3school.com.cn/jsref/prop_node_nodetype.asp)
>
> [Document.createDocumentFragment()](https://www.jianshu.com/p/8ff10b4cf929)
>
> [codepen-Vue2-响应式原理](https://codepen.io/damuwangs/pen/RwZPKjw)


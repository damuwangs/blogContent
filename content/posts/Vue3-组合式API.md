---
title: "Vue3-组合式API"
date: "2021-07-05"
tags: [编程]
categories: VUE
---

# 概念

> 通过创建 Vue 组件，我们可以将界面中重复的部分连同其功能一起提取为可重用的代码段。仅此一项就可以使我们的应用在可维护性和灵活性方面走得相当远。然而随着项目的扩大，功能越来越复杂，定义的数据以及对其数据的操作被放在不同的地方，如methods，watch，碎片化使得理解和维护复杂组件变得困难。选项的分离掩盖了潜在的逻辑问题。此外，在处理单个逻辑关注点时，我们必须不断地“跳转”相关代码的选项块，于是出现了组合式api

组合式api主要解决的问题就是单业务逻辑代码单文件处理，将一个巨大无比的组件分成无数小的文件模块每个模块只处理很少的业务，通过定义setUp选项，将单逻辑的变量、生命周期以及方法独立成JS，再通过export的方式将需要使用的暴漏出来。Vue3提供的响应式API基本上可以保证我们在JS中实现响应式变量、父子组件传值、生命周期等所有操作，这是其它方式所不具备的

# 为什么要使用组合式 API

1. ## 组件化的缺点

   使用 (`data`、`computed`、`methods`、`watch`) 组件选项来组织逻辑通常都很有效。然而，当我们的组件开始变得更大时，逻辑关注点的列表也会增长。尤其对于那些一开始没有编写这些组件的人来说，这会导致组件难以阅读和理解

   这种碎片化使得理解和维护复杂组件变得困难。选项的分离掩盖了潜在的逻辑问题。此外，在处理单个逻辑关注点时，我们必须不断地“跳转”相关代码的选项块

2. ## 提取公共JS方式的缺点

   因为无法获取vue对象，只能编写非业务代码，例如工具方法

3. ## 插槽的缺点

   - 配置最终出现在模板中，理想情况下，模板应仅包含我们要呈现的内容
   - 公开的属性仅在模板中可用

4. ## mixin方式的缺点

   mixin的解决方案是将vue页面的js部分提取成公共的以供多个相似模块的共用。这种方式的缺点主要由以下几点

   - 如methods,components等，选项会被合并，键冲突的组件会覆盖混入对象的，比如混入对象里有个方法A，组件里也有方法A，这时候在组件里调用的话，执行的是组件里的A方法
   - 不可知，不易维护因为你可以在mixins里几乎可以加任何代码，props、data、methods、各种东西，就导致如果不了解mixins封装的代码的话，是很难维护的

# 样例

## 说明

实现了一个简单的列表功能，包括：列表展示、查看更多、关键字搜索

| 文件名称   | 功能描述                                                     |
| ---------- | ------------------------------------------------------------ |
| app.vue    | 主页，引入列表和搜索组件                                     |
| app.js     | 主页面逻辑，包含：1、初始化列表2、加载更多（接收子组件事件）3、关键字搜索（接收子组件事件） |
| panel.vue  | 列表组件：接收列表数据渲染数据                               |
| panel.js   | 列表组件逻辑：1、加载更多（emit发送事件）                    |
| search.vue | 搜索组件：点击搜索框切换选中样式，输入关键字刷新列表数据     |
| search.js  | 搜索组件逻辑：1、点击搜索框样式切换，自动聚集2、搜索值监听(emit发送事件) |

## 代码

### app.vue

```
<template>
  <div id="app">    
    <Search @search="search"/>
    <Panel :listData='listData' @loadMore="loadMore"/>
  </div>
</template>
<script>
import app from "./app.js";
import Search from "./components/Search.vue";
import Panel from "./components/Panel.vue";
export default {
  name: "app",
  components: {
    Search,
    Panel
  },   
  setup(props, context){
    const {search, loadMore, listData} = app(props, context)
    return {
      search,
      loadMore,
      listData
    }
  }
}
</script>
```

### app.js

```
import { ref} from "@vue/composition-api";
export default function app(props, context) {
  let listData = ref([]) // 定义响应式变量,切记下方赋值/取值时修改的是.value属性！
  // 初始化列表
  const loadData = () => {      
    return [{title:'标题一', author: '作者一'},{title:'标题二', author: '作者二'},{title:'标题三', author: '作者三'},{title:'标题四', author: '作者四'},{title:'标题五', author: '作者五'}]
  }
  // 加载更多
  const loadMore = () => {   
    listData.value = [...listData.value, ...[{title:'标题X', author: '作者X'}]]
  }
  // 搜索
  const search = (searchVal) => {
    if (searchVal) {
      listData.value = listData.value.filter(item => {
        if (item.title.indexOf(searchVal) >= 0) {
          return item
        } 
      })         
    } else {
      listData.value = loadData()
    }
  }
  return {
    listData,
    loadMore,
    search
  }
}
```

### panel.vue

```
<template>
  <div class="weui-panel weui-panel_access">
    <div v-for="(n,index) in listData" :key="index" class="weui-panel__bd">
      <a href="javascript:void(0);" class="weui-media-box weui-media-box_appmsg">
        <div class="weui-media-box__bd">
          <h4 class="weui-media-box__title" v-text="n.title"></h4>
          <p class="weui-media-box__desc" v-text="n.author"></p>
        </div>
      </a>
    </div>
    <div @click="loadMore" class="weui-panel__ft">
      <a href="javascript:void(0);" class="weui-cell weui-cell_access weui-cell_link">
        <div class="weui-cell__bd">查看更多</div>
        <span class="weui-cell__ft"></span>
      </a>
    </div>
  </div>
</template>
<script>
import { reactive, toRefs} from "@vue/composition-api";
import pane from "./pane.js";
export default {
  props:['listData'],
  setup(props, context) {
    const {loadMore} = pane(props, context)
    const state = reactive({
    })     
    return {
      ...toRefs(state),
      loadMore
    }
  }
}
</script>
```

### panel.js

```
export default function pane(props, context) {
  const loadMore = () => {
    context.emit("loadMore")
  }
  return {
    loadMore
  }
}
```

### search.vue

```
<template>
  <div :class="['weui-search-bar', {'weui-search-bar_focusing':isFocus}]" id="searchBar">
    <form class="weui-search-bar__form">
      <div class="weui-search-bar__box">
        <i class="weui-icon-search"></i>
        <input
          v-model="searchValue"
          ref="inputElement"
          type="search"
          class="weui-search-bar__input"
          id="searchInput"
          placeholder="搜索"
          required
        />
        <a href="javascript:" class="weui-icon-clear" id="searchClear"></a>
      </div>
      <label @click="toggle" class="weui-search-bar__label" id="searchText">
        <i class="weui-icon-search"></i>
        <span>搜索</span>
      </label>
    </form>
    <a @click="toggle" href="javascript:" class="weui-search-bar__cancel-btn" id="searchCancel">取消</a>
  </div>
</template>
<script>
import search from "./search.js";
export default {
  setup(props, context) {
    const {searchValue, isFocus, inputElement,  toggle} = search(props, context)
    return {
      toggle,
      searchValue, 
      isFocus, 
      inputElement
    }
  }
}
</script>
```

### search.js

```
import {reactive, toRefs, watch} from "@vue/composition-api";
export default function search(props, context) {
  const search = reactive({
    searchValue: "",
    isFocus: false,
    inputElement: null
  })
  const searchRefs = toRefs(search); // 定义一个新的对象，它本身不具备响应性，但是它的字段全部是ref变量
  // 切换搜索框状态的方法
  const toggle = () => {
    search.inputElement.focus() // 让点击搜索后出现的输入框自动聚焦
    search.isFocus = !search.isFocus
  }
  // 监听搜索框的值
  watch(
    () => {
      return search.searchValue
    },
    () => {
      context.emit("search", search.searchValue)
    }
  )
  return {
    ...searchRefs, // 在这里结构toRefs对象才能继续保持响应式
    toggle
  }
}
```

# 响应式

- ## setup

  概念：在组件创建之前执行，一旦 `props` 被解析，就将作为组合式 API 的入口

  参数：

  1、props

  响应式的，当传入新的 prop 时，它将被更新

  ```
  export default {
    props: {
      title: String
    },
    setup(props) {
      console.log(props.title)
    }
  }
  ```

  2、context

  context是一个普通的 JavaScript 对象，它暴露组件的三个 property

  ```
  export default {
    setup(props, context) {
      // Attribute (非响应式对象)
      console.log(context.attrs)
  
      // 插槽 (非响应式对象)
      console.log(context.slots)
  
      // 触发事件 (方法)
      console.log(context.emit)
    }
  }
  ```

  attrs和slots是有状态的对象，它们总是会随组件本身的更新而更新。这意味着你应该避免对它们进行解构，并始终以 attrs.x或slots.x的方式引用 property。请注意，与props不同，attrs和slots是非响应式的。如果你打算根据attrs或slots更改应用副作用，那么应该在onUpdated生命周期钩子中执行此操作

  setup注册生命周期钩子

  ```
  import {onMounted} from "@vue/composition-api";
  export default function pane(props, context) {
    onMounted(() => {
    	// 业务逻辑
    })
    return {    
    }
  }
  ```

  watch响应式更改

  ```
  import {watch} from "@vue/composition-api";
  export default function search(props, context) {
    watch(
      () => {
        // 监听的值	
        return search.searchValue
      },
      () => {
        // 业务逻辑
        context.emit("search", search.searchValue)
      }
    )
    return {
    }
  }
  ```

  独立的computed属性

  ```
  import {computed} from "@vue/composition-api";
  export default function search(props, context) {
    newsComputed: computed(() => {
        // 业务逻辑
    })
    return {  
    }
  }
  ```

- ## ref

  创建单个对象的响应对象，取值/赋值时需要使用.value

  ```
  const count = ref(0)
  console.log(count.value) // 0
  count.value++
  console.log(count.value) // 1

- ## toRefs

  从组合式函数返回响应式对象

  ```
  const state = reactive({
    foo: 1,
    bar: 2
  })
  const stateAsRefs = toRefs(state)
  // ref 和原始 property 已经“链接”起来了
  state.foo++
  console.log(stateAsRefs.foo.value) // 2
  stateAsRefs.foo.value++
  console.log(state.foo) // 3
  ```

# 参考资料

> [组合式API的使用示例](https://github.com/Wscats/vue-cli)
>
> [Vue3.0学习教程与实战案例](https://vue3.chengpeiquan.com/)


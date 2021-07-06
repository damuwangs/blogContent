---
title: "Vue3-Teleport"
date: "2021-07-06"
tags: [编程]
categories: 前端

---

# 概念

> Teleport 是一种能够将我们的模板移动到 DOM中Vue app之外的其他位置的技术，就有点像哆啦A梦的“任意门”
>
> 场景：像 modals,toast 等这样的元素，很多情况下，我们将它完全的和我们的 Vue 应用的 DOM完全剥离，管理起来反而会方便容易很多
>
> 原因在于如果我们嵌套在Vue的某个组件内部，那么处理嵌套组件的定位、z-index和样式就会变得很困难
>
> 另外，像 modals，toast等这样的元素需要使用到 Vue组件的状态（data或者props）的值
>
> 这就是Teleport派上用场的地方。我们可以在组件的逻辑位置写模板代码，这意味着我们可以使用组件的data或props。然后在Vue应用的范围之外渲染它

# Teleport 的使用

index.html中

```
<div id="app"></div>
  <div id="teleport-target"></div>
<script type="module" src="/src/main.js"></script>
```
src/components/HelloWorld.vue中，添加如下，留意to属性跟上面的id选择器一致

```
 <button @click="showToast" class="btn">打开 toast</button>
  <!-- to 属性就是目标位置 -->
  <teleport to="#teleport-target">
    <div v-if="visible" class="toast-wrap">
      <div class="toast-msg">我是一个 Toast 文案</div>
    </div>
  </teleport>
```

```
import { ref } from 'vue';
export default {
  setup() {
    // toast 的封装
    const visible = ref(false);
    let timer;
    const showToast = () => {
      visible.value = true;
      clearTimeout(timer);
      timer = setTimeout(() => {
        visible.value = false;
      }, 2000);
    }
    return {
      visible,
      showToast
    }
  }
}
```

效果展示：

![](/img/Vue3-Teleport/效果一.gif)

可以看到，我们使用teleport组件，通过to属性，指定该组件渲染的位置与<div id="app"></div>同级，也就是在body下，但是teleport的状态visible又是完全由内部Vue组件控制

# 与 Vue组件 一起使用modal

如果<teleport>包含Vue组件，则它仍将是<teleport>父组件的逻辑子组件

接下来我们以一个modal组件为例

```
<div id="app"></div>
<div id="modal-container"></div>
<script type="module" src="/src/main.js"></script>
```

```
<teleport to="#modal-container">
  <!-- use the modal component, pass in the prop -->
  <modal :show="showModal" @close="showModal = false">
    <template #header>
      <h3>custom header</h3>
    </template>
  </modal>
</teleport>
```

```
import { ref } from 'vue';
import Modal from './Modal.vue';
export default {
  components: {
    Modal
  },
  setup() {
    // modal 的封装
    const showModal = ref(false);
    return {
      showModal
    }
  }
}
```

在这种情况下，即使在不同的地方渲染Modal，它仍将是当前组件（调用Modal的组件）的子级，并将从中接收show prop

这也意味着来自父组件的注入按预期工作，并且子组件将嵌套在Vue Devtools中的父组件之下，而不是放在实际内容移动到的位置

看实际效果以及在Vue Devtool中

![](/img/Vue3-Teleport/效果二.gif)

# 参考资料

> [Vue 3 任意传送门——Teleport](https://juejin.cn/post/6874720017863147527)
>
> [vue3.0新特性teleport是啥，用起来真香](https://juejin.cn/post/6910100912367206414)


---
title: "React-Portals"
date: "2021-11-29"
tags: [编程]
categories: React
---

# 为什么需要Portals

Portals能够将子组件渲染到父组件以外的DOM树，他通常用于子组件需要从父组件的容器中脱离出来的场景，有以下场景：

- Dialog对话框
- Tooltip文字提示
- Popover弹出框
- Loader全局loader

比如某个组件在渲染时，在某种条件下需要显示一个Dialog，最直观的做法，就是直接在JSX中把Dialog画出来，像下面代码的样子

```jsx
<div class="foo">
   <div> ... </div>
   { needDialog ? <Dialog /> : null }
</div>
```

问题是，Dialog最终渲染产生的HTML就与上面JSX产生的HTML产生嵌套了，类似下面这样

```html
<div class="foo">
   <div> ... </div>
   <div class="dialog">Dialog Content</div>
</div>
```

对于对话框应该是一个独立的组件，通常应该显示在屏幕的最中间，现在Dialog被包在其它组件中，要用CSS的position属性控制Dialog位置，就要从Dialog往上一直到body都没有其它position是relative的元素干扰。还有一点，Dialog的样式，因为包含在其它元素中，各种样式纠缠，CSS样式太容易搞成一坨浆糊了。

我们既希望在组件的JSX中选择使用Dialog，把Dialog用的像普通组件一样，但是又希望Dialog内容显示在另一个地方，就需要Portals上场了。

Portals就是建立一个“传送门”，让Dialog这样的组件在表示层和其它组件没有任何差异，但是渲染的东西却像经过传送门一样出现在另一个地方

当我们需要在正常的DOM结构之外呈现子组件时，React Portals非常有用，而不需要通过React组件树层次结构破坏事件传播的默认行为，这在渲染例如弹窗、提示时非常有用

# React v16的Portals支持

在某个组件中需要使用modal弹框，大多数情况下可以使用fixed定位让这个弹框全局展示，但是特殊情况下，这个modal弹框可能会显示不正常。这个时候如果使用了portals的方式，使modal的dom结构脱离父组件的容器，就可以规避这种问题

```typescript
// 定义弹框组件
const Modal = ({message, isOpen, onClose, children}) => {
  if (!isOpen) return null
  // 创建portals并挂载到body中  
  return ReactDOM.createPortal(
    <div className="modal">
      <span>{message}</span>
      <button onClick={onClose}>Close</button>
    </div>
  , document.body)
}
// 弹框使用
function Component() {
  const [open, setOpen] = useState(false)
  return (
    <div className="component">
      <button onClick={() => setOpen(true)}></button>
      <Modal
        message="Hello World!"
        isOpen={open}
        onClose={() => setOpen(false)}
      />
    </div>
  )
}
```

上面的代码能够保证，无论子组件嵌套多深，这个modal能够和root同一级。使用浏览器检查dom结构，就可以看到如下结构

![](/img/React-Portals/React-Portals.png)

# Portals的事件冒泡 

v16之前的React Portals实现方法，有一个小小的缺陷，就是Portals是单向的，内容通过Portals传到另一个出口，在那个出口DOM上发生的事件不会冒泡传送回Portals的父组件的

```html
<div onClick={onDialogClick}>   
   <Dialog>
     What ever shit
   </Dialog>
</div>
```

在Dialog画出的内容上点击，onClick是不会被触发的。

在v16中，通过Portals渲染出去的DOM，事件是会从传送门的入口端冒出来的，上面的onDialogClick也就会被调用到了

# 参考资料

> [传送门：React Portal](https://zhuanlan.zhihu.com/p/29880992)
>
> [你真的了解React Portals吗](https://juejin.cn/post/6892951045685641224)


---
title: "JavaScript-事件冒泡、事件捕获和事件委托"
date: "2021-08-16"
tags: [编程]
categories: JavaScript
---

# 事件流

![](/img/JavaScript-事件冒泡、事件捕获和事件委托/事件流.png)

事件冒泡和事件捕获分别由微软和网景公司提出，这两个概念都是为了解决页面中事件流（事件发生顺序）的问题

```html
<div id="outer">
    <p id="inner">Click me!</p>
</div>
```

上面的代码当中一个div元素当中有一个p子元素，如果两个元素都有一个click的处理函数，那么我们怎么才能知道哪一个函数会首先被触发呢？

为了解决这个问题微软和网景提出了两种几乎完全相反的概念

# 事件冒泡

## 事件冒泡

##### 概念

微软提出了名为**事件冒泡**(event bubbling)的事件流。事件冒泡可以形象地比喻为把一颗石头投入水中，泡泡会一直从水底冒出水面。也就是说，事件会从最内层的元素开始发生，一直向上传播，直到document对象

上面的例子在事件冒泡的概念下发生click事件的顺序应该是

**p -> div -> body -> html -> document**

##### 样例

## 阻止事件冒泡

## 阻止默认事件

# 事件捕获

##### 概念

网景提出另一种事件流名为**事件捕获**(event capturing)。与事件冒泡相反，事件会从最外层开始发生，直到最具体的元素。

上面的例子在事件捕获的概念下发生click事件的顺序应该是

**document -> html -> body -> div -> p**

##### 样例

# 事件委托

##### 概念

##### 样例

# Vue按键修饰符

# 参考资料

> [你真的理解 事件冒泡 和 事件捕获 吗？](https://juejin.cn/post/6844903834075021326#heading-5)
>
> [浅谈JavaScript事件捕获事件冒泡与事件委托](https://www.cnblogs.com/sk-3/p/14695445.html)
>
> [JavaScript 事件冒泡、事件捕获和事件委托](https://www.jianshu.com/p/84622d166e67)
>
> [按键修饰符](https://cn.vuejs.org/v2/guide/events.html#按键修饰符)


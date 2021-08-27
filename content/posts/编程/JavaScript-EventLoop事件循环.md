---
title: "JavaScript-EventLoop事件循环"
date: "2021-08-26"
tags: [编程]
categories: JavaScript
---

# 概念

JavaScript 是一门单线程语言，即同一时间只能执行一个任务，即代码执行是同步并且阻塞的。

> 举例：这就像只有一个窗口的银行，客户需要一个一个排队办理业务。

只能同步执行肯定是有问题的，所以 JS 有了一个用来实现异步的函数：`setTimeout`

下面要讲的 Event Loop 就是为了确保 异步代码 可以在 同步代码 执行后继续执行的。

## 队列（Queue）

队列是一种FIFO(First In, First Out) 的数据结构，它的特点就是先进先出

> 举例：生活中最常见的例子就是排队啦，排在队伍最前面的人最先被提供服务

## 栈（Stack）

栈是一种 LIFO（Last In, First Out）的数据结构，特点即后进先出

> 样例：大家都吃过桶装薯片吧~薯片在包装的时候只能从顶部放入，而吃的时候也只能从顶部拿出，这就叫后进先出

## 调用栈（Stack）

调用栈本质上当然还是个栈，关键在于它里面装的东西，是一个个待执行的函数

Event Loop 会一直检查 Call Stack 中是否有函数需要执行，如果有，就从栈顶依次执行。同时，如果执行的过程中发现其他函数，继续入栈然后执行

先拿两个函数来说：

- 栈空
- 现在执行到一个函数A，函数A入栈
- 函数A 又调用了函数B，函数B入栈
- 函数B执行完后出栈
- 然后继续执行函数A，执行完后A也出栈
- 栈空

看一段代码：

```js
const bar = () => console.log('bar')
const baz = () => console.log('baz')
const foo = () => {
	console.log('foo')
	bar()
	baz()
}
foo()
```

这段代码在 调用栈中的运行顺序如下图：

![](/img/JavaScript-EventLoop事件循环/调用栈.png)

上面我们讨论的其实都是同步代码，代码在运行的时候只用 调用栈 解释就可以了

那么，假如我们发起了一个网络请求(request)，或者设置了一个定时器延时(setTimeout)，一段时间后的代码（回调函数）肯定不是直接被加到调用栈吧？

这时就要引出事件表格（Event Table）和事件队列 (Event Queue)了

## Event Table

Event Table 可以理解成一张 `事件->回调函数` 对应表

> 它就是用来存储 JavaScript 中的异步事件 (request, setTimeout, IO等) 及其对应的回调函数的列表

## Event Queue

Event Queue 简单理解就是 `回调函数 队列`，所以它也叫 Callback Queue

> 当 Event Table 中的事件被触发，事件对应的 **回调函数** 就会被 push 进这个 Event Queue，然后等待被执行

# Event Loop

![](/img/JavaScript-EventLoop事件循环/EventLoop.png)

- 开始，任务先进入 Call Stack
- 同步任务直接在栈中等待被执行，异步任务从 Call Stack 移入到 Event Table 注册
- 当对应的事件触发（或延迟到指定时间），Event Table 会将事件回调函数移入 Event Queue 等待
- 当 Call Stack 中没有任务，就从 Event Queue 中拿出一个任务放入 Call Stack

而Event Loop指的就是这一整个圈圈：

> 它不停检查 Call Stack 中是否有任务（也叫栈帧）需要执行，如果没有，就检查 Event Queue，从中弹出一个任务，放入 Call Stack 中，如此往复循环。

## 宏任务与微任务

微任务和宏任务皆为异步任务，它们都属于一个队列，主要区别在于他们的执行顺序，Event Loop的走向和取值

![](/img/JavaScript-EventLoop事件循环/宏任务、微任务.png)

> js异步有一个机制，就是遇到宏任务，先执行宏任务，将宏任务放入eventqueue，然后在执行微任务，将微任务放入eventqueue，这两个queue不是一个queue。
>
> 当你往外拿的时候先从微任务里拿这个回掉函数，然后再从宏任务的queue上拿宏任务的回掉函数

而宏任务一般是：包括整体代码script，setTimeout，setInterval、setImmediate。

微任务：原生Promise(有些实现的promise将then方法放到了宏任务中)、process.nextTick、Object.observe(已废弃)、 MutationObserver 记住就行了

# 参考资料

> [JS事件循环（Event Loop）](https://www.cnblogs.com/formercoding/p/12906640.html)
>
> [浅析 JS 中的 EventLoop 事件循环（新手向）](https://segmentfault.com/a/1190000019313028)
>
> [JS事件循环机制（event loop）之宏任务/微任务](https://juejin.cn/post/6844903638238756878)


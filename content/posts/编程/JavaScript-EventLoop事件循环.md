---
title: "JavaScript-EventLoop事件循环"
date: "2021-08-26"
tags: [编程]
categories: JavaScript
---

# 概念

JavaScript 是一门单线程语言，即同一时间只能执行一个任务，即代码执行是同步并且阻塞的

> 举例：这就像只有一个窗口的银行，客户需要一个一个排队办理业务

只能同步执行肯定是有问题的，所以 JS 有了一个用来实现异步的函数：`setTimeout`

Event Loop 就是为了确保 异步代码 可以在 同步代码 执行后继续执行的

## 队列（Queue）

队列是一种FIFO(First In, First Out) 的数据结构，它的特点就是先进先出

> 举例：生活中最常见的例子就是排队，排在队伍最前面的人最先被提供服务

## 栈（Stack）

栈是一种 LIFO（Last In, First Out）的数据结构，特点即后进先出

> 样例：大家都吃过桶装薯片吧~薯片在包装的时候只能从顶部放入，而吃的时候也只能从顶部拿出，这就叫后进先出

## 调用栈（Call Stack）

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

> 它就是用来存储 JavaScript 中的异步事件 (request, setTimeout, IO等) 及其对应的回调函数

## Event Queue

Event Queue 简单理解就是 `回调函数 队列`，所以它也叫 Callback Queue

> 当 Event Table 中的事件被触发，事件对应的回调函数就会被 push 进这个 Event Queue，然后等待被执行

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

> Js异步有一个机制，就是遇到宏任务，先执行宏任务，将宏任务放入Event Queue，然后在执行微任务，将微任务放入Event Queue，这两个Queue不是一个Queue。
>
> 当你往外拿的时候先从微任务里拿这个回掉函数，然后再从宏任务的Queue上拿宏任务的回掉函数

而宏任务一般是：包括整体代码script，setTimeout，setInterval、setImmediate。

微任务：原生Promise(有些实现的promise将then方法放到了宏任务中)、process.nextTick、Object.observe(已废弃)、 MutationObserver 记住就行了

## setTimeout

我们经常这么实现延时3秒执行

```js
setTimeout(() => {
    console.log('延时3秒')
},3000)
```

渐渐的setTimeout用的地方多了，问题也出现了，有时候明明写的延时3秒，实际却5，6秒才执行函数

```js
setTimeout(() => {
    task()
},3000)
console.log('执行console')
```

根据前面我们的结论，setTimeout是异步的，应该先执行console.log这个同步任务，所以我们的结论是：

```html
// 执行console
// task()
```

去验证一下，结果正确！ 然后我们修改一下前面的代码：

```js
setTimeout(() => {
    task()
},3000)
sleep(10000000)
```

乍一看其实差不多，但我们把这段代码在chrome执行一下，却发现控制台执行task()需要的时间远远超过3秒，说好的延时三秒，为啥现在需要这么长时间啊？ 

这时候我们需要重新理解setTimeout的定义。我们先说上述代码是怎么执行的：

- task()进入Event Table并注册,计时开始
- 执行sleep函数，很慢，非常慢，计时仍在继续
- 3秒到了，计时事件timeout完成，task()进入Event Queue，但是sleep也太慢了吧，还没执行完，只好等着
- sleep终于执行完了，task()终于从Event Queue进入了主线程执行

上述的流程走完，我们知道setTimeout这个函数，是经过指定时间后，把要执行的任务(本例中为task())加入到Event Queue中，又因为是单线程任务要一个一个执行，如果前面的任务需要的时间太久，那么只能等着，导致真正的延迟时间远大于3秒

------

我们还经常遇到setTimeout(fn,0)这样的代码，0秒后执行又是什么意思呢？是不是可以立即执行呢？ 答案是不会的，setTimeout(fn,0)的含义是，指定某个任务在主线程最早可得的空闲时间执行，意思就是不用再等多少秒了，只要主线程执行栈内的同步任务全部执行完成，栈为空就马上执行。举例说明：

```js
//代码1
console.log('先执行这里')
setTimeout(() => {
    console.log('执行啦')
},0)
//代码2
console.log('先执行这里')
setTimeout(() => {
    console.log('执行啦')
},3000)
```

代码1的输出结果是：

```html
先执行这里
执行啦
```

代码2的输出结果是：

```
//先执行这里
// ... 3s later
// 执行啦
```

关于setTimeout要补充的是，即便主线程为空，0毫秒实际上也是达不到的。根据HTML的标准，最低是4毫秒

## setInterval

上面说完了setTimeout，当然不能错过它的孪生兄弟setInterval。他俩差不多，只不过后者是循环的执行。对于执行顺序来说，setInterval会每隔指定的时间将注册的函数置入Event Queue，如果前面的任务耗时太久，那么同样需要等待

唯一需要注意的一点是，对于setInterval(fn,ms)来说，我们已经知道不是每过ms秒会执行一次fn，而是每过ms秒，会有fn进入Event Queue。一旦setInterval的回调函数fn执行时间超过了延迟时间ms，那么就完全看不出来有时间间隔了

## Promise与process.nextTick

- Promise的定义和功能本文不再赘述，可以学习一下 [阮一峰老师的Promise](https://link.juejin.cn/?target=http%3A%2F%2Fes6.ruanyifeng.com%2F%23docs%2Fpromise)
- 而process.nextTick(callback)类似node.js版的"setTimeout"，在事件循环的下一次循环中调用 callback 回调函数

不同类型的任务会进入对应的Event Queue，比如`setTimeout`和`setInterval`会进入相同的Event Queue

```js
setTimeout(()=>{
  console.log('setTimeout1')
},0)
let p = new Promise((resolve,reject)=>{
  console.log('Promise1')
  resolve()
})
p.then(()=>{
  console.log('Promise2')    
})
```

执行结果：

```html
Promise1
Promise2
setTimeout1
```

Promise参数中的Promise1是同步执行的 其次是因为Promise是microtasks，会在同步任务执行完后会去清空microtasks queues， 最后清空完微任务再去宏任务队列取值

```js
Promise.resolve().then(()=>{
  console.log('Promise1')  
  setTimeout(()=>{
    console.log('setTimeout2')
  },0)
})

setTimeout(()=>{
  console.log('setTimeout1')
  Promise.resolve().then(()=>{
    console.log('Promise2')    
  })
},0)
```

执行结果：

```html
Promise1
setTimeout1
Promise2
setTimeout2
```

- 一开始执行栈的同步任务执行完毕，会去 microtasks queues 找 清空 microtasks queues ，输出Promise1，同时会生成一个异步任务 setTimeout1

- 去宏任务队列查看此时队列是 setTimeout1 在 setTimeout2 之前，因为setTimeout1执行栈一开始的时候就开始异步执行,所以输出setTimeout1

- 在执行setTimeout1时会生成Promise2的一个 microtasks ，放入 microtasks queues 中，接着又是一个循环，去清空 microtasks queues ，输出Promise2

- 清空完 microtasks queues ，就又会去宏任务队列取一个，这回取的是setTimeout2

最后我们来分析一段较复杂的代码，掌握js的执行机制：

```js
console.log('1');

setTimeout(function() {
    console.log('2');
    process.nextTick(function() {
        console.log('3');
    })
    new Promise(function(resolve) {
        console.log('4');
        resolve();
    }).then(function() {
        console.log('5')
    })
})
process.nextTick(function() {
    console.log('6');
})
new Promise(function(resolve) {
    console.log('7');
    resolve();
}).then(function() {
    console.log('8')
})

setTimeout(function() {
    console.log('9');
    process.nextTick(function() {
        console.log('10');
    })
    new Promise(function(resolve) {
        console.log('11');
        resolve();
    }).then(function() {
        console.log('12')
    })
})
```

第一轮事件循环流程分析如下：

- 整体script作为第一个宏任务进入主线程，遇到console.log，输出1
- 遇到setTimeout，其回调函数被分发到宏任务Event Queue中。我们暂且记为setTimeout1
- 遇到process.nextTick()，其回调函数被分发到微任务Event Queue中。我们记为process1
- 遇到Promise，new Promise直接执行，输出7。then被分发到微任务Event Queue中。我们记为then1
- 又遇到了setTimeout，其回调函数被分发到宏任务Event Queue中，我们记为setTimeout2

| 宏任务Event Queue | 微任务Event Queue |
| ----------------- | ----------------- |
| setTimeout1       | process1          |
| setTimeout2       | then1             |

- 表是第一轮事件循环宏任务结束时各Event Queue的情况，此时已经输出了1和7

我们发现了process1和then1两个微任务

- 执行process1,输出6
- 执行then1，输出8

好了，第一轮事件循环正式结束，这一轮的结果是输出1，7，6，8。那么第二轮时间循环从setTimeout1宏任务开始：

- 首先输出2。接下来遇到了process.nextTick()，同样将其分发到微任务Event Queue中，记为process2
- new Promise立即执行输出4，then也分发到微任务Event Queue中，记为then2

| 宏任务Event Queue | 微任务Event Queue |
| ----------------- | ----------------- |
| setTimeout2       | process3          |
|                   | then3             |

第三轮事件循环宏任务执行结束，执行两个微任务process3和then3。

输出10

输出12

第三轮事件循环结束，第三轮输出9，11，10，12

整段代码，共进行了三次事件循环，完整的输出为1，7，6，8，2，4，3，5，9，11，10，12

node环境下的事件监听依赖libuv与前端环境不完全相同，输出顺序可能会有误差

# 参考资料

> [JS事件循环（Event Loop）](https://www.cnblogs.com/formercoding/p/12906640.html)
>
> [浅析 JS 中的 EventLoop 事件循环（新手向）](https://segmentfault.com/a/1190000019313028)
>
> [JS事件循环机制（event loop）之宏任务/微任务](https://juejin.cn/post/6844903638238756878)


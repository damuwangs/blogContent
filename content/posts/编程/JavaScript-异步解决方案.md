---
title: "JavaScript-异步解决方案"
date: "2021-09-01"
tags: [编程]
categories: JavaScript
---

# 概念

Javascript语言的执行环境是"单线程"。也就是指一次只能完成一件任务。如果有多个任务，就必须排队，前面一个任务完成，再执行后面一个任务。

这种模式虽然实现起来比较简单，执行环境相对单纯，但是只要有一个任务耗时很长，后面的任务都必须排队等着，会拖延整个程序的执行。常见的浏览器无响应（假死），往往就是因为某一段Javascript代码长时间运行（比如死循环），导致整个页面卡在这个地方，其他任务无法执行。

为了解决这个问题，Javascript语言将任务的执行模式分成两种：同步和异步

## 同步

所有的任务都处在同一队列中，不可以插队，一个任务执行完接着开始执行下一个，相对于浏览器而言，同步的效率过低

## 异步

将一个任务放入到异步队列中，当这个任务执行完成之后，再从异步队列中提取出来，插队到同步队列中，拿到异步任务的结果，可以提升代码执行的效率，不需要因为一个耗时长的代码而一直等待

# 回调函数

```javascript
ajax(url, () => {
    // 处理逻辑
})
```

假设多个请求存在依赖性，可能就会写出如下代码：

```javascript
ajax(url, () => {
    // 处理逻辑
    ajax(url1, () => {
        // 处理逻辑
        ajax(url2, () => {
            // 处理逻辑
        })
    })
})
```

优点：解决了同步的问题

缺点：回调地狱，不能用 try catch 捕获错误，不能 return

# 事件监听

这种方式下，异步任务的执行不取决于代码的顺序，而取决于某个事件是否发生

下面是两个函数f1和f2，编程的意图是f2必须等到f1执行完成，才能执行

f1方法执行完，通过$emit发送一个事件doSomething（vue写法）

```js
f1(){
	// ...
    // 发送事件
    this.$emit('doSomething', {data:'data'})
}

```

通过$on接收事件

```js
// 接收事件
this.$on(doSomething, (res) => {
    if (res) {
        this.f2()
    }    
})
```

优点：比较容易理解，可以绑定多个事件，每个事件可以指定多个回调函数，而且可以"去耦合"，有利于实现模块化

缺点：整个程序都要变成事件驱动型，运行流程会变得很不清晰。阅读代码的时候，很难看出主流程

# 发布订阅

我们假定，存在一个"信号中心"，某个任务执行完成，就向信号中心"发布"（publish）一个信号，其他任务可以向信号中心"订阅"（subscribe）这个信号，从而知道什么时候自己可以开始执行。这就叫做"发布/订阅模式"（publish-subscribe pattern），又称"观察者模式"（observer pattern）。

f2向信号中心jQuery订阅done信号

```js
jQuery.subscribe('done', f2)
```

jQuery.publish('done')的意思是，f1执行完成后，向信号中心jQuery发布done信号，从而引发f2的执行

```js
function f1() {
    setTimeout(function () {
        // ...
        jQuery.publish('done')
    }, 1000)
}
```

f2完成执行后，可以取消订阅（unsubscribe）

```js
jQuery.unsubscribe('done', f2)
```

# Promise

Promise本意是承诺，在程序中的意思就是承诺我过一段时间后会给你一个结果。 什么时候会用到过一段时间？答案是异步操作，异步是指可能比较长时间才有结果的才做，例如网络请求、读取本地文件等

## Promise的三种状态

- Pending----进行中
- Fulfilled----已成功
- Rejected----已失败

![](/img/JavaScript-异步解决方案/Promise.png)

这个承诺一旦从等待状态变成为其他状态就永远不能更改状态了，比如说一旦状态变为 resolved 后，就不能再次改变为Fulfilled

```js
let p = new Promise((resolve, reject) => {
  reject('reject')
  resolve('success')//无效代码不会执行
})
p.then(
  value => {
    console.log(value)
  },
  reason => {
    console.log(reason)//reject
  }
)
```

当我们在构造 Promise 的时候，构造函数内部的代码是立即执行的

```js
new Promise((resolve, reject) => {
  console.log('new Promise')
  resolve('success')
})
console.log('end')

```

输出：

```html
new Promise
end
```

## promise的链式调用

- 每次调用返回的都是一个新的Promise实例(这就是then可用链式调用的原因)

- 如果then中返回的是一个结果的话会把这个结果传递下一次then中的成功回调

- 如果then中出现异常,会走下一个then的失败回调

- 在 then中使用了return，那么 return 的值会被Promise.resolve() 包装(见例1，2)

- then中可以不传递参数，如果不传递会透到下一个then中

- catch 会捕获到没有捕获的异常

例1

```js
Promise.resolve(1)
    .then(res => {
        console.log(res)
        return 2 //包装成 Promise.resolve(2)
    })
    .catch(err => 3)
    .then(res => console.log(res))
```

输出：

```html
1
2
```

例2

```js
// 例2
Promise.resolve(1)
    .then(x => x + 1)
    .then(x => {
        throw new Error('My Error')
    })
    .catch(() => 1)
    .then(x => x + 1)
    .then(x => console.log(x))
    .catch(console.error)
```

输出：

```html
2
```

优点：解决了回调地狱的问题

缺点：无法取消 Promise ，错误需要通过回调函数来捕获

## Promise.all

Promise.all()方法用于将多个 Promise 实例，包装成一个新的 Promise 实例

```javascript
const p = Promise.all([p1, p2, p3]);
```

Promise.all可以将多个Promise实例包装成一个新的Promise实例。同时，成功和失败的返回值是不同的，成功的时候返回的是一个结果数组，而失败的时候则返回最先被reject失败状态的值

p的状态由p1、p2、p3决定，分成两种情况

（1）只有p1、p2、p3的状态都变成fulfilled，p的状态才会变成fulfilled，此时p1、p2、p3的返回值组成一个数组，传递给p的回调函数

（2）只要p1、p2、p3之中有一个被rejected，p的状态就变成rejected，此时第一个被reject的实例的返回值，会传递给p的回调函数

```js
let p1 = new Promise((resolve, reject) => {
  resolve('成功了')
})

let p2 = new Promise((resolve, reject) => {
  resolve('success')
})

let p3 = Promse.reject('失败')

Promise.all([p1, p2]).then((result) => {
  console.log(result)               //['成功了', 'success']
}).catch((error) => {
  console.log(error)
})

Promise.all([p1,p3,p2]).then((result) => {
  console.log(result)
}).catch((error) => {
  console.log(error)      // 失败了，打出 '失败'
})
```

需要特别注意的是，Promise.all获得的成功结果的数组里面的数据顺序和Promise.all接收到的数组顺序是一致的，即p1的结果在前，即便p1的结果获取的比p2要晚。这带来了一个绝大的好处：在前端开发请求数据的过程中，偶尔会遇到发送多个请求并根据请求顺序获取和使用数据的场景，使用Promise.all毫无疑问可以解决这个问题

## Promise.race

顾名思义，Promse.race就是赛跑的意思，意思就是说，Promise.race([p1, p2, p3])里面哪个结果获得的快，就返回那个结果，不管结果本身是成功状态还是失败状态

```js
let p1 = new Promise((resolve, reject) => {
  setTimeout(() => {
    resolve('success')
  },1000)
})

let p2 = new Promise((resolve, reject) => {
  setTimeout(() => {
    reject('failed')
  }, 500)
})

Promise.race([p1, p2]).then((result) => {
  console.log(result)
}).catch((error) => {
  console.log(error)  // 打开的是 'failed'
})
```

# Generator/yield

Generator 函数是 ES6 提供的一种异步编程解决方案，语法行为与传统函数完全不同，Generator 最大的特点就是可以控制函数的执行。

- 语法上，首先可以把它理解成，Generator 函数是一个状态机，封装了多个内部状态
- Generator 函数除了状态机，还是一个遍历器对象生成函数
- 可暂停函数, yield可暂停，next方法可启动，每次返回的是yield后的表达式结果
- yield表达式本身没有返回值，或者说总是返回undefined。next方法可以带一个参数，该参数就会被当作上一个yield表达式的返回值

例1

```js
function *foo(x) {
  let y = 2 * (yield (x + 1))
  let z = yield (y / 3)
  return (x + y + z)
}
let it = foo(5)
console.log(it.next())   // => {value: 6, done: false}
console.log(it.next(12)) // => {value: 8, done: false}
console.log(it.next(13)) // => {value: 42, done: true}
```

- 首先 Generator 函数调用和普通函数不同，它会返回一个迭代器

- 当执行第一次 next 时，传参会被忽略，并且函数暂停在 yield (x + 1) 处，所以返回 5 + 1 = 6

- 当执行第二次 next 时，传入的参数12就会被当作上一个yield表达式的返回值，如果你不传参，yield 永远返回 undefined。此时 let y = 2 * 12，所以第二个 yield 等于 2 * 12 / 3 = 8

- 当执行第三次 next 时，传入的参数13就会被当作上一个yield表达式的返回值，所以 z = 13, x = 5, y = 24，相加等于 42

例2：有三个本地文件，分别1.txt,2.txt和3.txt，内容都只有一句话，下一个请求依赖上一个请求的结果，想通过Generator函数依次调用三个文件

```html
//1.txt文件
2.txt
```

```html
//2.txt文件
3.txt
```

```html
//3.txt文件
结束
```

```js
let fs = require('fs')
function read(file) {
  return new Promise(function(resolve, reject) {
    fs.readFile(file, 'utf8', function(err, data) {
      if (err) reject(err)
      resolve(data)
    })
  })
}
function* r() {
  let r1 = yield read('./1.txt')
  let r2 = yield read(r1)
  let r3 = yield read(r2)
  console.log(r1)
  console.log(r2)
  console.log(r3)
}
let it = r()
let { value, done } = it.next()
value.then(function(data) { // value是个promise
  console.log(data) //data=>2.txt
  let { value, done } = it.next(data)
  value.then(function(data) {
    console.log(data) //data=>3.txt
    let { value, done } = it.next(data)
    value.then(function(data) {
      console.log(data) //data=>结束
    })
  })
})
```

输出结果：

```html
2.txt
3.txt
结束
```

从上例中我们看出手动迭代`Generator` 函数很麻烦，实现逻辑有点绕，而实际开发一般会配合 `co` 库去使用

co是一个为Node.js和浏览器打造的基于生成器的流程控制工具，借助于Promise，你可以使用更加优雅的方式编写非阻塞代码

安装co库只需

```bash
npm install co
```

上面例子只需两句话就可以轻松实现

```js
function* r() {
  let r1 = yield read('./1.txt')
  let r2 = yield read(r1)
  let r3 = yield read(r2)
  console.log(r1)
  console.log(r2)
  console.log(r3)
}
let co = require('co')
co(r()).then(function(data) {
  console.log(data)
})
```

输出结果：

```html
2.txt
3.txt
结束
undefined
```

例3：我们可以通过 Generator 函数解决回调地狱的问题，可以把之前的回调地狱例子改写为如下代码：

```js
function *fetch() {
    yield ajax(url, () => {})
    yield ajax(url1, () => {})
    yield ajax(url2, () => {})
}
let it = fetch()
let result1 = it.next()
let result2 = it.next()
let result3 = it.next()
```

特点：可以控制函数的执行，可以配合 co 函数库使用

# Async/await

## Async/Await简介

使用async/await，你可以轻松地达成之前使用生成器和co函数所做到的工作,它有如下特点：

- async/await是基于Promise实现的，它不能用于普通的回调函数。
- async/await与Promise一样，是非阻塞的。
- async/await使得异步代码看起来像同步代码，这正是它的魔力所在。

一个函数如果加上 async ，那么该函数就会返回一个 Promise

```js
async function async1() {
  return "1"
}
console.log(async1()) // -> Promise {<resolved>: "1"}
```

Generator函数依次调用三个文件那个例子用async/await写法，只需几句话便可实现

```js
let fs = require('fs')
function read(file) {
  return new Promise(function(resolve, reject) {
    fs.readFile(file, 'utf8', function(err, data) {
      if (err) reject(err)
      resolve(data)
    })
  })
}
async function readResult(params) {
  try {
    let p1 = await read(params, 'utf8')//await后面跟的是一个Promise实例
    let p2 = await read(p1, 'utf8')
    let p3 = await read(p2, 'utf8')
    console.log('p1', p1)
    console.log('p2', p2)
    console.log('p3', p3)
    return p3
  } catch (error) {
    console.log(error)
  }
}
readResult('1.txt').then( // async函数返回的也是个promise
  data => {
    console.log(data)
  },
  err => console.log(err)
)
```

输出结果：

```html
p1 2.txt
p2 3.txt
p3 结束
```

## Async/Await并发请求

如果请求两个文件，毫无关系，可以通过并发请求

```js
let fs = require('fs')
function read(file) {
  return new Promise(function(resolve, reject) {
    fs.readFile(file, 'utf8', function(err, data) {
      if (err) reject(err)
      resolve(data)
    })
  })
}
function readAll() {
  read1()
  read2()//这个函数同步执行
}
async function read1() {
  let r = await read('1.txt','utf8')
  console.log(r)
}
async function read2() {
  let r = await read('2.txt','utf8')
  console.log(r)
}
readAll() 
```

输出结果：

```html
2.txt 
3.txt
```

优点：代码清晰，不用像 Promise 写一大堆 then 链，处理了回调地狱的问题

缺点：await 将异步代码改造成同步代码，如果多个异步操作没有依赖性而使用 await 会导致性能上的降低

# 参考资料

> [JS 异步编程六种方案](https://juejin.cn/post/6844903760280420366#heading-12)
>
> [JS异步解决方案的发展历程以及优缺点](https://blog.csdn.net/lunahaijiao/article/details/87167417)


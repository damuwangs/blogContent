---
title: "JavaScript-this指向"
date: "2021-08-31"
tags: [编程]
categories: JavaScript
---

# this的指向

> 在 ES5 中，其实 this 的指向，始终坚持一个原理：this 永远指向最后调用它的那个对象

看几个简单的例子:[this指向](https://codepen.io/damuwangs/pen/OJgMPxe?editors=0012)

# 改变this的指向

```js
var name = "windowsName";

var a = {
    name : "Cherry",

    func1: function () {
        console.log(this.name)     
    },

    func2: function () {
        setTimeout(  function () {
            this.func1()
        },100)
    }
}

a.func2()     // this.func1 is not a function
```

在不使用箭头函数的情况下，是会报错的，因为最后调用setTimeout的对象是 window，但是在 window 中并没有 func1 函数

我们在改变 this 指向这一节将把这个例子作为 demo 进行改造

## 箭头函数

先看箭头函数和普通函数的重要区别：

> 1、没有自己的this、super、arguments和new.target绑定
>
> 2、不能使用new来调用
>
> 3、没有原型对象
>
> 4、不可以改变this的绑定
>
> 5、形参名称不能重复

箭头函数的 this 始终指向函数定义时的 this，而非执行时，箭头函数需要记着这句话：“箭头函数中没有 this 绑定，必须通过查找作用域链来决定其值，如果箭头函数被非箭头函数包含，则 this 绑定的是最近一层非箭头函数的 this，否则，this 为 undefined”

```js
var name = "windowsName"
var a = {
    name : "Cherry",

    func1: function () {
        console.log(this.name)     
    },

    func2: function () {
        setTimeout( () => {
            this.func1()
        },100)
    }
}

a.func2()     // Cherry
```

## 函数内部使用_this = this

先将调用这个函数的对象保存在变量_this中，然后在函数中都使用这个_this，这样_this就不会改变了

```js
var name = "windowsName";

var a = {
    name : "Cherry",
    
    func1: function () {
        console.log(this.name)     
    },
    
    func2: function () {
        var _this = this
        setTimeout( function() {
            _this.func1()
        },100)
    }
}

a.func2()       // Cherry
```

这个例子中，在 func2 中，首先设置var _this = this，这里的this 是调用func2的对象 a，为了防止在func2中的 setTimeout 被 window 调用而导致的在 setTimeout 中的 this 为 window。我们将this(指向变量 a)赋值给一个变量 _this，这样，在func2中我们使用this就是指向对象 a 了。

## 使用apply、call、bind

### 使用 apply

```js
var a = {
    name : "Cherry",

    func1: function () {
        console.log(this.name)
    },

    func2: function () {
        setTimeout(  function () {
            this.func1()
        }.apply(a),100)
    }
}

a.func2()            // Cherry
```

### 使用 call

```js
    var a = {
        name : "Cherry",

        func1: function () {
            console.log(this.name)
        },

        func2: function () {
            setTimeout(  function () {
                this.func1()
            }.call(a),100)
        }
    }

    a.func2()            // Cherry
```

### 使用 bind

```js
    var a = {
        name : "Cherry",

        func1: function () {
            console.log(this.name)
        },

        func2: function () {
            setTimeout(  function () {
                this.func1()
            }.bind(a)(),100)
        }
    }

    a.func2()            // Cherry
```

## apply、call、bind区别

其实 apply 和 call 基本类似，他们的区别只是传入的参数不同。所以 apply 和 call 的区别是 call 方法接受的是若干个参数列表，而 apply 接收的是一个包含多个参数的数组

[MDN](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.mozilla.org%2Fzh-CN%2Fdocs%2FWeb%2FJavaScript%2FReference%2FGlobal_Objects%2FFunction%2Fapply)中定义 apply 如下

> apply() 方法调用一个函数, 其具有一个指定的this值，以及作为一个数组（或类似数组的对象）提供的参数
>
> 语法：fun.apply(thisArg, [argsArray])
>
> 参数：
>
> - thisArg：在 fun 函数运行时指定的 this 值
>
> - argsArray：一个数组或者类数组对象，其中的数组元素将作为单独的参数传给 fun 函数

[MDN](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/call)中定义call如下

> call()方法使用一个指定的this值和单独给出的一个或多个参数来调用一个函数
>
> 语法：function.call(thisArg, arg1, arg2, ...)
>
> 参数：
>
> - thisArg：在function函数运行时使用的this值
>
> - arg1, arg2, ...：指定的参数列表

------

我们先来将刚刚的例子使用 bind 试一下

```js
var a ={
    name : "Cherry",
    fn : function (a,b) {
        console.log( a + b)
    }
}

var b = a.fn;
b.bind(a,1,2)
```

我们会发现并没有输出，[MDN](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/bind)中定义bind如下

> 创建一个新的函数, 当被调用时，将其this关键字设置为提供的值，在调用新函数时，在任何提供之前提供一个给定的参数序列

所以我们可以看出，bind 是创建一个新的函数，我们必须要手动去调用

```js
var a ={
	name : "Cherry",
	fn : function (a,b) {
    	console.log( a + b)
    }
}

var b = a.fn
b.bind(a,1,2)()           // 3
```

# JS中的函数调用

### 普通函数调用模式

```js
var name = "windowsName"
function a() {
	var name = "Cherry"
	console.log(this.name)          // windowsName
}
a()
```

这样一个最简单的函数，不属于任何一个对象，就是一个函数，这样的情况在 JavaScript 的在浏览器中的非严格模式默认是属于全局对象 window 的，在严格模式，就是 undefined

但这是一个全局的函数，很容易产生命名冲突，所以不建议这样使用

### 对象中的函数（方法）调用模式

```js
var name = 'window'
var doSth = function(){
    console.log(this.name)
}
var student = {
    name: '若川',
    doSth: doSth,
    other: {
        name: 'other',
        doSth: doSth,
    }
}
student.doSth() // '若川'
student.other.doSth() // 'other'
```

### call、apply、bind模式

同上[使用apply、call、bind](http://localhost:1313/posts/编程/javascript-this指向/#使用applycallbind)

### 构造函数调用模式

> 如果函数调用前使用了 new 关键字, 则是调用了构造函数
> 这看起来就像创建了新的函数，但实际上 JavaScript 函数是重新创建的对象：

```js
// 构造函数:
function myFunction(arg1, arg2) {
    this.firstName = arg1
    this.lastName  = arg2
}

var a = new myFunction("Li","Cherry");
a.lastName  // 返回 "Cherry"
```

这就有要说另一个面试经典问题：new 的过程了，(ಥ_ಥ)
这里就简单的来看一下 new 的过程吧：
伪代码表示：

```js
var a = new myFunction("Li","Cherry");

new myFunction{
    var obj = {};
    obj.__proto__ = myFunction.prototype;
    var result = myFunction.call(obj,"Li","Cherry");
    return typeof result === 'obj'? result : obj;
}
```

1. 创建一个空对象 obj

2. 将新创建的空对象的隐式原型指向其构造函数的显示原型

3. 使用 call 改变 this 的指向

4. 如果无返回值或者返回一个非对象值，则将 obj 返回作为新对象；

   如果返回值是一个新对象的话那么直接直接返回该对象

所以我们可以看到，在 new 的过程中，我们是使用 call 改变了 this 的指向。

### 原型链中的调用模式

```js
function Student(name){
    this.name = name
}
var s1 = new Student('若川')
Student.prototype.doSth = function(){
    console.log(this.name)
}
s1.doSth() // '若川'
```

### 箭头函数调用模式

同上[箭头函数](http://localhost:1313/posts/编程/javascript-this指向/#箭头函数)

# 参考资料

> [JavaScript 的 this 原理](http://www.ruanyifeng.com/blog/2018/06/javascript-this.html)
>
> [this、apply、call、bind](https://juejin.cn/post/6844903496253177863)
>
> [面试官问：JS的this指向](https://juejin.cn/post/6844903746984476686#heading-13)


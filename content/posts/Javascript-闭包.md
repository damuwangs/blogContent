---
title: "JavaScript-闭包"
date: "2021-06-21"
tags: [编程]
categories: 前端
---

# 概念

- ## 变量的作用域

  要理解闭包，首先必须理解Javascript特殊的变量作用域

  变量的作用域无非就是两种：全局变量和局部变量

  Javascript语言的特殊之处，就在于函数内部可以直接读取全局变量

  ```
  var n=999
  function f1(){
  	alert(n)
  }
  f1() // 999
  ```

  在函数外部无法读取函数内的局部变量

  ```
  function f1(){
  	var n=999
  }
  alert(n); // error
  ```

- ## 闭包的描述

  闭包就是能够读取其他函数内部变量的函数

  由于在Javascript语言中，只有函数内部的子函数才能读取局部变量，因此可以把闭包简单理解成"定义在一个函数内部的函数"

  所以，在本质上，闭包就是将函数内部和函数外部连接起来的一座桥梁，f2函数，就是闭包

  ```
  function f1(){
  	var n=999
  	function f2(){
      	alert(n)
      }
  　　return f2
  }
  var result = f1()
  result() // 999
  ```

- ## 闭包优缺点

  优点：

  1. 希望一个变量长期驻扎在内存中

  2. 避免全局变量的污染

  3. 私有成员的存在

     

  缺点：闭包会使变量始终保存在内存中，如果不当使用会增大内存消耗

# 应用场景

- ## 匿名自执行函数

  我们知道所有的变量，如果不加上var关键字，则默认的会添加到全局对象的属性上去，这样的临时变量加入全局对象有很多坏处，比如：别的函数可能误用这些变量；造成全局对象过于庞大，影响访问速度(因为变量的取值是需要从原型链上遍历的)。除了每次使用变量都是用var关键字外，我们在实际情况下经常遇到这样一种情况，即有的函数只需要执行一次，其内部变量无需维护，比如UI的初始化，那么我们可以使用闭包

  ```
  var data= {    
      table : [],    
      tree : {}    
  };    
       
  (function(dm){    
      for(var i = 0; i < dm.table.rows; i++){    
         var row = dm.table.rows[i]  
         for(var j = 0; j < row.cells; i++){    
             drawCell(i, j)
         }    
      }    
         
  })(data);   
  ```

  我们创建了一个匿名的函数，并立即执行它，由于外部无法引用它内部的变量，因此在函数执行完后会立刻释放资源，关键是不污染全局对象

- ## 结果缓存

  我们开发中会碰到很多情况，设想我们有一个处理过程很耗时的函数对象，每次调用都会花费很长时间，那么我们就需要将计算出来的值存储起来，当调用这个函数的时候，首先在缓存中查找，如果找不到，则进行计算，然后更新缓存并返回值，如果找到了，直接返回查找到的值即可。闭包正是可以做到这一点，因为它不会释放外部的引用，从而函数内部的值可以得以保留

  ```
  var CachedSearchBox = (function(){    
      var cache = {},count = [];    
      return {    
         attachSearchBox : function(dsid){    
  	       //如果结果在缓存中
             if(dsid in cache){   
                //直接返回缓存中的对象
                return cache[dsid]    
             }    
             //新建 
             var fsb = new uikit.webctrl.SearchBox(dsid)   
  		  //更新缓存
             cache[dsid] = fsb
             return fsb     
         }  
      }
  })()
  CachedSearchBox.attachSearchBox("input")
  ```

  这样我们在第二次调用的时候，就会从缓存中读取到该对象

- ## 减少全局变量的污染

  ```
  //abc为外部匿名函数的返回值
  var abc = (function(){      
      var a = 1
      return function(){
          a++
          alert(a)
      }
  })()
  //2 调用一次abc函数，其实是调用里面内部函数的返回值  
  abc()  
  //3
  abc() 
  ```

- ## 封装

  ```
  var person = function(){    
      //变量作用域为函数内部，外部无法访问    
      var name = "default";              
      return {    
         getName : function(){    
             return name;    
         },    
         setName : function(newName){    
             name = newName  
         }    
      }    
  }() 
  // 直接访问，结果为undefined         
  print(person.name) 
  print(person.getName())  
  person.setName("abruzzi")   
  print(person.getName()) 
     
  得到结果如下：  
  undefined  
  default  
  abruzzi  
  ```

- ## 实现类和继承

  ```
  function Person(){    
      var name = "default"       
      return {    
         getName : function(){    
             return name;    
         },    
         setName : function(newName){    
             name = newName;    
         }    
      }    
  }   
  
  var p = new Person()
  p.setName("Tom")
  alert(p.getName())
  
  var Jack = function(){}
  //继承自Person
  Jack.prototype = new Person()
  //添加私有方法
  Jack.prototype.Say = function(){
  	alert("Hello,my name is Jack")
  }
  var j = new Jack()
  j.setName("Jack")
  j.Say()
  alert(j.getName())
  ```

  我们定义了Person，它就像一个类，我们new一个Person对象，访问它的方法。下面我们定义了Jack，继承Person，并添加自己的方法。

- ## setTimeout传参

  ```
  setTimeout(function(param){
      alert(param)
  },1000)
  
  //通过闭包可以实现传参效果
  function func(param){
  	return function(){
  		alert(param)
  	}
  }
  var f1 = func(1)
  setTimeout(f1,1000)
  ```

- ## 为节点循环绑定click事件

  ```
  function count() {
      var arr = []
      for (var i=1; i<=3; i++) {
          arr.push(function () {
              return i * i
          })
      }
      return arr
  }
  
  var results = count()
  var f1 = results[0]
  var f2 = results[1]
  var f3 = results[2]
  ```

  在上面的例子中，每次循环，都创建了一个新的函数，然后，把创建的3个函数都添加到一个Array中返回了。

  你可能认为调用f1()，f2()和f3()结果应该是 `1 4 9`， 但实际结果是：

  ```
  f1() // 16
  f2() // 16
  f3() // 16
  ```

  全部都是16！原因就在于返回的函数引用了变量i，但它并非立刻执行。等到3个函数都返回时，它们所引用的变量i已经变成了4，因此最终结果为16

  **返回闭包时牢记的一点就是：返回函数不要引用任何循环变量，或者后续会发生变化的变量**

  如果一定要引用循环变量怎么办？方法是再创建一个函数，用该函数的参数绑定循环变量当前的值，无论该循环变量后续如何更改，已绑定到函数参数的值不变：

  ```
  function count() {
      var arr = []
      for (var i=1; i<=3; i++) {
          arr.push((function (n) {
              return function () {
                  return n * n
              }
          })(i))
      }
      return arr
  }
  
  var results = count()
  var f1 = results[0]
  var f2 = results[1]
  var f3 = results[2]
  
  f1() // 1
  f2() // 4
  f3() // 9
  ```

  注意这里用了一个“创建一个匿名函数并立刻执行”的语法：

  ```
  (function (x) {
      return x * x
  })(3) // 9
  ```

# 参考资料

> [学习Javascript闭包（Closure）](http://www.ruanyifeng.com/blog/2009/08/learning_javascript_closures.html)
>
> [详解JS闭包](https://segmentfault.com/a/1190000000652891)
>
> [全面理解Javascript闭包和闭包的几种写法及用途](https://www.cnblogs.com/yunfeifei/p/4019504.html)
>
> [javascript之闭包七（闭包的应用场景）](https://juejin.cn/post/6844903910902087688)
>
> [闭包与setTimeout](https://juejin.cn/post/6844903841888993287)
>
> [对JS闭包的理解及常见应用场景](https://blog.csdn.net/qq_21132509/article/details/80694517)


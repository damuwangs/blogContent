---
title: "JavaScript-防抖、节流"
date: "2021-07-16"
tags: [编程]
categories: JavaScript
---

# 防抖

## 概念

任务频繁触发的情况下，只有任务触发的间隔超过制定的时间间隔的时候，任务才会被执行

将一段时间内连续的多次触发转化为一次触发。

## 应用场景

- 用户在输入框中连续输入一串字符后，只会在输入完后去执行最后一次的查询ajax请求，这样可以有效减少请求次数，节约请求资源；

- window的resize、scroll事件，不断地调整浏览器的窗口大小、或者滚动时会触发对应事件，防抖让其只触发一次；

## 实例

- ### 非立即执行版

  ```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>防抖</title>
  </head>
  <body>
    <button id="debounce">点我防抖！</button>
  
    <script>
      window.onload = function() {
        // 1、获取这个按钮，并绑定事件
        var myDebounce = document.getElementById("debounce");
        myDebounce.addEventListener("click", debounce(sayDebounce));
      }
  
      // 2、防抖功能函数，接受传参
      function debounce(fn) {
        // 4、创建一个标记用来存放定时器的返回值
        let timeout = null;
        return function() {
          // 5、每次当用户点击/输入的时候，把前一个定时器清除
          clearTimeout(timeout);
          // 6、然后创建一个新的 setTimeout，
          // 这样就能保证点击按钮后的 interval 间隔内
          // 如果用户还点击了的话，就不会执行 fn 函数
          timeout = setTimeout(() => {
            fn.call(this, arguments);
          }, 1000);
        };
      }
  
      // 3、需要进行防抖的事件处理
      function sayDebounce() {
        // ... 有些需要防抖的工作，在这里执行
        console.log("防抖成功！");
      }
  
    </script>
  </body>
  </html>
  ```

  创建一个定时器，如果在规定时间内重复触发该事件，就会调用clearTimeout清除掉上一个定时器，重置定时器

  也就是说，这件事本来就是需要等待的，并非立即执行的，如果用户反复点击，那只好重新等待了

- ### 立即执行版

  ```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>防抖</title>
  </head>
  <body>
    <button id="debounce">点我防抖！</button>
  
    <script>
      window.onload = function() {
        // 1、获取这个按钮，并绑定事件
        var myDebounce = document.getElementById("debounce");
        myDebounce.addEventListener("click", debounce(sayDebounce));
      }
  
      // 2、防抖功能函数，接受传参
      function debounce(fn) {
        // 4、创建一个标记用来存放定时器的返回值
        let timeout = null;
        //5.创建一个判断是否可点击值
        let doit = true;
        return function() {
          // 5、当doit为真，既用户重复点击时，清除定时器
          if(doit)clearTimeout(timeout);
          //6.当doit为false时，既用户可点击，再将doit设为true，防止用户重复点击
          else{
              fn();
              doit = true;
          }
          //7.设置定时器，这样就能保证点击按钮后的 interval 间隔内
          // 如果用户还点击了的话，就不会执行 将doit设为false函数
          timeout = setTimeout(() => {
            doit = false;
          }, 1000);
        };
      }
  
      // 3、需要进行防抖的事件处理
      function sayDebounce() {
        // ... 有些需要防抖的工作，在这里执行
        console.log("防抖成功！");
      }
  
    </script>
  </body>
  </html>

# 节流

## 概念

指定时间间隔内只会执行一次任务

## 应用场景

- 这有点像我们刷抢购一样，当我们在某段时间间隔内触发了多次事件，其实，它只执行一次请求
- 鼠标连续不断地触发某事件（如点击），只在单位时间内只触发一次
- 在页面的无限加载场景下，需要用户在滚动页面时，每隔一段时间发一次 ajax 请求，而不是在用户停下滚动页面操作时才去请求数据
- 监听滚动事件，比如是否滑到底部自动加载更多，用throttle来判断；

## 实例

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>节流</title>
</head>
<body>

  <button id="throttle">点我节流！</button>

  <script>
    window.onload = function() {
      // 1、获取按钮，绑定点击事件
      var myThrottle = document.getElementById("throttle");
      myThrottle.addEventListener("click", throttle(sayThrottle));
    }

    // 2、节流函数体
    function throttle(fn) {
      // 4、通过闭包保存一个标记
      let canRun = true;
      return function() {
        // 5、在函数开头判断标志是否为 true，不为 true 则中断函数
        if(!canRun) {
          return;
        }
        // 6、将 canRun 设置为 false，防止执行之前再被执行
        canRun = false;
        // 7、定时器
        setTimeout( () => {
          fn.call(this, arguments);
          // 8、执行完事件（比如调用完接口）之后，重新将这个标志设置为 true
          canRun = true;
        }, 1000);
      };
    }

    // 3、需要节流的事件
    function sayThrottle() {
      console.log("节流成功！");
    }

  </script>
</body>
</html>
```

从这个例子可以看出，节流可以防止在某时间间隔内重复发送请求！其和防抖有点相似，但其有本质的区别，虽然都是防止重复触发事件！

**防抖是需要等待多久时间才能再触发一次事件！**

**节流是多久时间内只能触发一次事件！**

# 参考资料

> [闲聊前端性能----防抖、节流、重绘与回流。](https://www.cnblogs.com/binguo666/p/10535948.html)


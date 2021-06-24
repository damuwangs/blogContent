---
title: "Javascript - 原型链"
date: "2021-06-24"
tags: [编程]
categories: 前端
---

# 概念

- ## 图示

![hugo下载版本](/img/Javascript-原型链/原型链图示.png)

- ## 原型、原型链相等关系理解

  1. js分为函数对象和普通对象，每个对象都有____proto____属性，但是只有函数对象才有prototype属性
  2. ____proto____是任何对象的属性，指向该对象的构造函数的原型对象
  3. prototype是构造函数的属性，指向属于该构造函数的原型对象
  4. 属性____proto____是一个对象，它有两个属性，constructor和____proto____
  5. 原型对象prototype有一个默认的constructor属性，用于记录实例是由哪个构造函数创建
  6. Object、Function都是js内置的函数, 类似的还有我们常用到的Array、RegExp、Date、Boolean、Number、String

# 参考资料

> https://juejin.cn/post/6844903989088092174

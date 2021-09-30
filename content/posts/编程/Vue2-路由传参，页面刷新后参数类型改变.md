---
title: "Vue2-路由传参，页面刷新后参数类型改变"
date: "2021-09-30"
tags: [编程]
categories: VUE
---

# 问题描述

今天发现一个小问题，列表通过路由传递的 number 类型参数，用 === 来判断 

```js
Number(this.$route.query.type) !== 1
```

结果发现有时候为 true ，有时候为 false

进入页面，打印参数类型：

```js
number
```

刷新页面，打印参数类型：

```js
string
```

后来发现，原因是：

> vue-router 传参，不管是 params 形式还是query形式传参，在页面刷新后，params 和 query
> 对象中的属性所对应的属性值都会被浏览器自身强制转换为string类型
> (这一点与浏览器的sessionStorage和localStorage存储对象，对象会被转为string类型，不谋而合)，破环原先属性值的数据类型

# 解决方案

将参数强制转为 Number类型：

```js
Number(this.$route.query.type)
```

# 总结

1、number数据类型：页面刷新后，其类型会转换为 string 类型。

所以，在路由刷新页面，在使用时，不管页面是否刷新，都对传递过来的属性值做一次Number()转换；

2、string数据类型：页面刷新后，其类型依然为string类型；

3、boolean数据类型：页面刷新后，其类型会转换为string类型。

所以，在路由刷新页面，在使用时，不管页面是否刷新，都对传递过来的属性值做一次Boolean()转换；

4、undefined数据类型：页面刷新后，其类型依然为undefined类型；

5、null数据类型：页面刷新后，其类型依然为null类型；

6、object数据类型：页面刷新后，其类型会转换为string类型；

所以，在路由跳转传参页面对属性值做一次JSON.stringify()预处理，然后在路由刷新页面对该值进行JSON.parse()转换。

# 参考资料

> [vue 路由传参，页面刷新后参数类型改变_且听风吟的博客-CSDN博客](https://blog.csdn.net/HH18700418030/article/details/119576206)


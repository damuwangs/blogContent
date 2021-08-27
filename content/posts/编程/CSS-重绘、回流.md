---
title: "重绘、回流"
date: "2021-08-09"
tags: [编程]
categories: CSS

---

# 浏览器渲染

浏览器在渲染页面的时候，大致是以下几个步骤：

1. 解析html生成DOM树，解析css，生成CSSOM树，将DOM树和CSSOM树结合，生成渲染树；
2. 根据渲染树，浏览器可以计算出网页中有哪些节点，各节点的CSS以及从属关系 - 【回流】
3. 根据渲染树以及回流得到的节点信息，计算出每个节点在屏幕中的位置 - 【重绘】
4. 最后将得到的节点位置信息交给浏览器的图形处理程序，让浏览器中显示页面

# 回流

## 概念

英文叫reflow，指的是当渲染树中的节点信息发生了大小、边距等问题，需要重新计算各节点和css具体的大小和位置

例：在css中对一个div修饰的样式中，使用了宽度50%，此时需要将50%转换为具体的像素，这个计算的过程，就是回流的过程

## 容易造成回流的操作

### 1、布局流相关操作

- 盒模型的相关操作会触发重新布局
- 定位相关操作会触发重新布局
- 浮动相关操作会触发重新布局

### 2、改变节点内的内容

改变节点的结构或其中的文本结构会触发重新布局

### 3、css

- width
- height
- padding
- border
- margin
- position
- top
- left
- bottom
- right
- float
- clear
- text-align
- vertical-align
- line-height
- font-weight
- font-size
- font-family
- overflow
- white-space

# 重绘

## 概念

重绘：英文叫repaint，当节点的部分属性发生变化，但不影响布局，只需要重新计算节点在屏幕中的绝对位置并渲染的过程，就叫重绘

例：改变元素的背景颜色、字体颜色等操作会造成重绘

## 容易造成重绘操作的CSS

- color
- border-style
- border-radius
- text-decoration
- box-shadow
- outline
- background

# 优化机制

## 1、浏览器优化

每次回流都会对浏览器造成额外的计算消耗，所以浏览器对于回流和重绘有一定的优化机制

浏览器通常都会将多次回流操作放入一个队列中，等过了一段时间或操作达到了一定的临界值，然后才会挨个执行，这样能节省一些计算消耗。

但是在获取布局信息操作的时候，会强制将队列清空，也就是强制回流，比如访问或操作以下或方法时：

- offsetTop
- offsetLeft
- offsetWidth
- offsetHeight
- scrollTop
- scrollLeft
- scrollWidth
- scrollHeight
- clientTop
- clientLeft
- clientWidth
- clientHeight
- getComputedStyle()

这些属性或方法都需要得到最新的布局信息，所以浏览器必须去回流执行。因此，在项目中，尽量避免使用上述属性或方法，如果非要使用的时候，也尽量将值缓存起来，而不是一直获取

## 2、合并样式修改

减少造成回流的次数，如果要给一个节点操作多个css属性，而每一个都会造成回流的话，尽量将多次操作合并成一个，例：

```js
var oDiv = document.querySelector('.box')
oDiv.style.padding = '5px'
oDiv.style.border = '1px solid #000'
oDiv.style.margin = '5px'
```

操作div的3个css属性，分别是padding、border、margin，此时就可以考虑将多次操作合并为一次

方法一：使用style的cssText

```js
oDiv.style.cssText = 'padding:5px; border:1px solid #000; margin:5px;'
```

方法二：将这几个样式定义给一个类名，然后给标签添加类名

```html
<style>
    .pbm{
        padding:5px; 
        border:1px solid #000; 
        margin:5px;
    }
</style>
<script>
    var oDiv = document.querySelector('.box');
    oDiv.classList.add('pbm');
</script>
```

## 3、批量操作DOM

当对DOM有多次操作的时候，需要使用一些特殊处理减少触发回流，其实就是对DOM的多次操作，在脱离标准流后，对元素进行的多次操作，不会触发回流，等操作完成后，再将元素放回标准流

脱离标准流的操作有以下3中：

1. 隐藏元素
2. 使用文档碎片
3. 拷贝节点

例：下面对DOM节点的多次操作，每次都会触发回流

```js
var data = [
    {
        id:1,
        name:"商品1"
    },
    {
        id:2,
        name:"商品1"
    },
    {
        id:3,
        name:"商品1"
    },
    {
        id:4,
        name:"商品1"
    }
    // 假设后面还有很多
]
var oUl = document.querySelector("ul")
for(var i=0;i<data.length;i++){
    var oLi = document.createElement("li")
    oLi.innerText = data[i].name
    oUl.appendChild(oLi)
}
```

这样每次给ul中新增一个li的操作，每次都会触发回流。

方法一：隐藏ul后，给ul添加节点，添加完成后再将ul显示

```js
oUl.style.display = 'none'
for(var i=0;i<data.length;i++){
    var oLi = document.createElement("li")
    oLi.innerText = data[i].name
    oUl.appendChild(oLi)
}
oUl.style.display = 'block'
```

此时，在隐藏ul和显示ul的时候，触发了两次回流，给ul添加每个li的时候没有触发回流。

方法二：创建文档碎片，将所有li先放在文档碎片中，等都放进去以后，再将文档碎片放在ul中

```js
var fragment = document.createDocumentFragment()
for(var i=0;i<data.length;i++){
    var oLi = document.createElement("li")
    oLi.innerText = data[i].name
    fragment.appendChild(oLi)
}
oUl.appendChild(fragment)
```

方法三：将ul拷贝一份，将所有li放在拷贝中，等都放进去以后，使用拷贝替换掉ul

```js
var newUL = oUl.cloneNode(true);
for(var i=0;i<data.length;i++){
    var oLi = document.createElement("li");
    oLi.innerText = data[i].name;
    newUL.appendChild(oLi);
}
oUl.parentElement.replaceChild(newUl, oUl);
```

## 4、避免多次触发布局

例：如下回到顶部的操作

```js
goBack.onclick = function(){
    setInterval(function(){
        var t = document.documentElement.scrollTop || document.body.scrollTop
        t += 10
        document.documentElement.scrollTop = document.body.scrollTop = t
    },20)
}
```

每隔20毫秒都会重新获取滚动过的距离，每次都会触发回流，代码优化如下：

```js
goBack.onclick = function(){
    var t = document.documentElement.scrollTop || document.body.scrollTop
    setInterval(function(){
        t += 10
        document.documentElement.scrollTop = document.body.scrollTop = t
    },20)
}
```

只获取一次，每次都让数字递增，避免每次都获取滚动过的距离

对于页面中比较复杂的动画，尽量将元素设置为绝对定位，操作元素的定位属性，这样只有这一个元素会回流，如果不是定位的话，容易引起其父元素以及子元素的回流

# 参考资料

> [讲清楚重排或回流、重绘](https://zhuanlan.zhihu.com/p/342371522)


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

##### 概念

微软提出了名为**事件冒泡**(event bubbling)的事件流。事件冒泡可以形象地比喻为把一颗石头投入水中，泡泡会一直从水底冒出水面。也就是说，事件会从最内层的元素开始发生，一直向上传播，直到document对象

##### 样例：[事件冒泡](https://codepen.io/damuwangs/pen/wveBZgG?editors=1000)

# 阻止事件冒泡

事件的对象有一个stopPropagation()方法可以阻止事件冒泡，我们只需要把上个例子中button的事件处理程序修改如下：

```js
document.getElementById("button").addEventListener("click",function(event){
	alert("button")
	event.stopPropagation()
},false)
```



# 事件捕获

##### 概念

网景提出另一种事件流名为**事件捕获**(event capturing)。与事件冒泡相反，事件会从最外层开始发生，直到最具体的元素

##### 样例：[事件捕获](https://codepen.io/damuwangs/pen/OJgPGxN)

# 阻止事件捕获

但是我们可以使用DOM3级新增事件stopImmediatePropagation()方法来阻止事件捕获，另外此方法还可以阻止事件冒泡。应用如下

```js
document.getElementById("second").addEventListener("click",function(event){
    alert("second")
    event.stopImmediatePropagation()
},true)
```

那么 stopImmediatePropagation() 和 stopPropagation()的区别在哪儿呢？

后者只会阻止冒泡或者是捕获。 但是前者除此之外还会阻止该元素的其他事件发生，但是后者就不会阻止其他事件的发生

# 事件委托

在实际的开发当中，利用事件流的特性，我们可以使用一种叫做事件代理的方法

##### 样例

```html
<ul class="color_list">        
    <li>red</li>        
    <li>orange</li>        
    <li>yellow</li>        
    <li>green</li>        
    <li>blue</li>        
    <li>purple</li>    
</ul>
<div class="box"></div>
```

```css
.color_list{            
    display: flex;            
    display: -webkit-flex;        
}        
.color_list li{            
    width: 100px;            
    height: 100px;            
    list-style: none;            
    text-align: center;            
    line-height: 100px;        
}
//每个li加上对应的颜色，此处省略
.box{            
    width: 600px;            
    height: 150px;            
    background-color: #cccccc;            
    line-height: 150px;            
    text-align: center;        
}

```

![](/img/JavaScript-事件冒泡、事件捕获和事件委托/事件代理.png)

我们想要在点击每个 li 标签时，输出li当中的颜色（innerHTML） 。常规做法是遍历每个 li ,然后在每个 li 上绑定一个点击事件：

```js
let color_list=document.querySelector(".color_list")     
let colors=color_list.getElementsByTagName("li")         
let box=document.querySelector(".box")     
for(let n=0;n<colors.length;n++){                
    colors[n].addEventListener("click",function(){                    
        console.log(this.innerHTML)                    
        box.innerHTML="该颜色为 "+this.innerHTML         
    })            
}
```

这种做法在 li 较少的时候可以使用，但如果有一万个li，那就会导致性能降低（少了遍历所有 li 节点的操作，性能上肯定更加优化）。这时就需要事件代理出场了，利用事件流的特性，我们只绑定一个事件处理函数也可以完成：

```js
function colorChange(e){                   
    if(e.target.nodeName.toLowerCase()==="li"){                    
        box.innerHTML="该颜色为 "+e.target.innerHTML          
    }                            
}            
color_list.addEventListener("click",colorChange,false)
```

由于事件冒泡机制，点击了li后会冒泡到ul，此时就会触发绑定在ul上的点击事件，再利用target找到事件实际发生的元素，就可以达到预期的效果

使用事件代理的好处不仅在于将多个事件处理函数减为一个，而且对于不同的元素可以有不同的处理方法。假如上述列表元素当中添加了其他的元素节点（如：a、span等），我们不必再一次循环给每一个元素绑定事件，直接修改事件代理的事件处理函数即可

（1）toLowerCase()方法用于把字符串转换为小写。语法：stringObject.toLowerCase()

返回值：一个新的字符串，在其中 stringObject 的所有大写字符全部被转换为了小写字符。

（2）nodeName属性指定节点的节点名称。如果节点是元素节点，则 nodeName 属性返回标签名。如果节点是属性节点，则 nodeName 属性返回属性的名称。对于其他节点类型，nodeName 属性返回不同节点类型的不同名称。

所有主流浏览器均支持 nodeName 属性

# Vue事件修饰符

在事件处理程序中调用 event.preventDefault()或event.stopPropagation()是非常常见的需求。尽管我们可以在方法中轻松实现这点，但更好的方式是：方法只有纯粹的数据逻辑，而不是去处理 DOM 事件细节

为了解决这个问题，Vue.js 为v-on提供了事件修饰符。之前提过，修饰符是由点开头的指令后缀来表示的

详情参考[Vue事件修饰符](https://cn.vuejs.org/v2/guide/events.html#事件修饰符)

# 参考资料

> [你真的理解 事件冒泡 和 事件捕获 吗？](https://juejin.cn/post/6844903834075021326#heading-5)
>
> [JavaScript中捕获/阻止捕获、冒泡/阻止冒泡](https://www.cnblogs.com/zhuzhenwei918/p/6139880.html)


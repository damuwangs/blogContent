---
title: "Html-meta标签"
date: "2021-11-26"
tags: [编程]
categories: Html
---

# 概念

> 元数据(metadata)是关于数据的信息
>
> 标签提供关于HTML文档的元数据。元数据不会显示在页面上，但是对于机器是可读的。
>
> 典型的情况是，meta元素被用于规定页面的描述、关键词、文档的作者、最后修改时间以及其他元数据。
>
> 标签始终位于head元素中。
>
> 元数据可用于浏览器（如何显示内容或重新加载页面），搜索引擎（关键词），或者其他web服务

# 属性

## 必需属性

meta的必须属性是content，并不是说meta标签里一定要有content，而是当有http-equiv或name属性的时候，一定要有content属性对其进行说明。

例：

```html
<meta name="keywords" content="HTML,ASP,PHP,SQL">
```



## 可选属性

### http-equiv

添加http头部内容，对一些自定义的，或者需要额外添加的http头部内容，需要发送到浏览器中，我们就可以使用这个属性。

例如我们不想使用js来重定向，用http头部内容控制，就可以这样控制

```html
<meta http-equiv="Refresh" content="5;url=http://www.baidu.com" />
```

在页面head中加入这个后，5秒钟后就会跳转到指定的页面

### name

供浏览器进行解析，对于一些浏览器兼容性问题，name是最常用的，当然有个前提就是浏览器能够解析你写进去的name属性才可以

例：

```html
<meta name="renderer" content="webkit">
```

这个meta标签的意思就是告诉浏览器，用webkit内核进行解析，前提是浏览器有webkit内核才可以。当然看到这个你可能会有疑问，这个renderer是从哪里冒出来的？这个就是在对应的浏览器的开发文档里就会有表明的，例如这个renderer是在360浏览器里说明的。[360浏览器内核控制Meta标签说明文档](http://se.360.cn/v6/help/meta.html)

# meta标签总结

## charset

声明文档使用的字符编码，解决乱码问题主要用的就是它，值得一提的是，这个charset一定要写第一行，不然可能会产生乱码了。

chartset有两种写法

```html
<meta charset="utf-8">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
```

## SEO 优化部分

```html
<!-- 页面标题<title>标签(head 头部必须) -->
<title>your title</title>
<!-- 页面关键词 keywords -->
<meta name="keywords" content="your keywords">
<!-- 页面描述内容 description -->
<meta name="description" content="your description">
<!-- 定义网页作者 author -->
<meta name="author" content="author,email address">
<!-- 定义网页搜索引擎索引方式，robotterms 是一组使用英文逗号「,」分割的值，通常有如下几种取值：none，noindex，nofollow，all，index和follow。 -->
<meta name="robots" content="index,follow">
```

## viewport

主要影响移动端布局的

之前用h5开发移动项目遇到过字体被缩放的特别小的问题，后来新增了viewport属性解决了，具体如下：

```html
<meta name="viewport" content="width=device-width, user-scalable=no">
```

content参数：

- width viewport 宽度(数值/device-width)
- height viewport 高度(数值/device-height)
- initial-scale 初始缩放比例
- maximum-scale 最大缩放比例
- minimum-scale 最小缩放比例
- user-scalable 是否允许用户缩放(yes/no)

## 各浏览器平台

一些常用的浏览器meta标签设置参考下方链接

# 参考资料

> [meta标签的作用及整理](https://blog.csdn.net/yc123h/article/details/51356143)
>
> [chrome手机模拟器显示尺寸不正确](https://www.cnblogs.com/argenbarbie/p/8026595.html)


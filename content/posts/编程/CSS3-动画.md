---
title: "CSS3-动画"
date: "2021-07-30"
tags: [编程]
categories: CSS
---

# 一、素转换transform

##  1.元素位置移动translate()

参数：左(X轴)，顶部(Y轴)单位px

样例：[元素位置移动](https://codepen.io/damuwangs/pen/LYymGqJ)

## 2.元素旋转rotate()

参数：旋转度数(负值是允许的，这样是元素逆时针旋转)，单位deg

样例：[元素旋转](https://codepen.io/damuwangs/pen/qBmYZdQ)

## 3.元素缩放scale()

参数：宽度缩放倍数、高度缩放倍数无参数

样例：[元素缩放](https://codepen.io/damuwangs/pen/oNWdxGr)

## 4.元素倾斜skew()

通过设置倾斜将正方形转化成菱形

参数：X轴，Y轴单位deg

样例：[元素倾斜](https://codepen.io/damuwangs/pen/mdmLPKP)

## 5.元素转换matrix()

方法：将上面的方法合并成一个，matrix 方法有六个参数，包含旋转，缩放，移动（平移）和倾斜功能

# 二、过渡transition

属性：

- transition-property：规定应用过渡的 CSS 属性的名称

- transition-duration：定义过渡效果花费的时间。默认是 0

- transition-timing-function：规定过渡效果的时间曲线。默认是 "ease"
  - linear：规定以相同速度开始至结束的过渡效果（等于 cubic-bezier(0,0,1,1)）
  - ease：规定慢速开始，然后变快，然后慢速结束的过渡效果（cubic-bezier(0.25,0.1,0.25,1)）
  - ease-in：规定以慢速开始的过渡效果（等于 cubic-bezier(0.42,0,1,1)）
  - ease-out：规定以慢速结束的过渡效果（等于 cubic-bezier(0,0,0.58,1)）
  - ease-in-out：规定以慢速开始和结束的过渡效果（等于 cubic-bezier(0.42,0,0.58,1)）
  - cubic-bezier(n,n,n,n)：在 cubic-bezier 函数中定义自己的值。可能的值是 0 至 1 之间的数值

- transition-delay：规定过渡效果何时开始。默认是 0

样例：[blog - CSS3动画 - 过渡](https://codepen.io/damuwangs/pen/ExmLyJy)

# 三、动画animation

属性：

- @keyframes：声明动画
- animation-name：引入动画
- animation-duration： 规定动画完成一个周期所花费的秒或毫秒。默认是 0，单位s
- animation-timing-function：规定动画的速度曲线。默认是 "ease"，设置同上
- animation-fill-mode：规定当动画不播放时，要应用到元素的样式。
- animation-delay：规定动画何时开始。默认是 0，单位s
- animation-iteration-count：规定动画被播放的次数。
  - 填写一个数字，默认是 1
  - infinite指定动画应该播放无限次
- animation-direction：规定动画是否在下一周期逆向地播放，默认是 "normal"
  - normal：默认值。动画按正常播放
  - reverse：动画反向播放
  - alternate：动画在奇数次（1、3、5...）正向播放，在偶数次（2、4、6...）反向播放
  - reverse：动画在奇数次（1、3、5...）反向播放，在偶数次（2、4、6...）正向播放
  - initial：设置该属性为它的默认值
  - inherit：从父元素继承该属性
- animation-play-state：规定动画是否正在运行或暂停，默认是 "running"
  - paused：指定暂停动画
  - running：指定正在运行的动画

样例：[blog - CSS3动画 - 动画](https://codepen.io/damuwangs/pen/xxdjEoz)

# 参考资料

> [如何理解animation-fill-mode及其使用？](https://segmentfault.com/q/1010000003867335)
>
> [HTML+CSS 绘制太阳系各个行星运行轨迹](https://c.runoob.com/codedemo/5528)
>
> [CSS 太极旋转图](https://c.runoob.com/codedemo/5645)


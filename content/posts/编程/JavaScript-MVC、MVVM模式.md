---
title: "JavaScript-MVC、MVVM模式"
date: "2021-11-08"
tags: [编程]
categories: JavaScript

---

# 概念

模型（Model）：指数据模型，泛指后端进行的各种业务逻辑处理和数据操控，主要围绕数据库系统展开。后端的处理通常会非常复杂

视图（View）：视图部分，通常指html等用来对用户展示的一部分

控制器（Controller）：负责根据用户从"视图层"输入的指令，选取"数据层"中的数据，然后对其进行相应的操作，产生最终结果

视图模型（ViewModel）：由前端开发人员组织生成和维护的视图数据层。在这一层，前端开发者对从后端获取的 Model 数据进行转换处理，做二次封装，以生成符合 View 层使用预期的视图数据模型。需要注意的是 ViewModel 所封装出来的数据模型包括视图的状态和行为两部分，而 Model 层的数据模型是只包含状态的，比如页面的这一块展示什么，那一块展示什么这些都属于视图状态（展示），而页面加载进来时发生什么，点击这一块发生什么，这一块滚动时发生什么这些都属于视图行为（交互），视图状态和行为都封装在了 ViewModel 里。这样的封装使得 ViewModel 可以完整地去描述 View 层。由于实现了双向绑定，ViewModel 的内容会实时展现在 View 层，这是激动人心的，因为前端开发者再也不必低效又麻烦地通过操纵 DOM 去更新视图，MVVM 框架已经把最脏最累的一块做好了，我们开发者只需要处理和维护 ViewModel，更新数据视图就会自动得到相应更新，真正实现数据驱动开发。看到了吧，View 层展现的不是 Model 层的数据，而是 ViewModel 的数据，由 ViewModel 负责与 Model 层交互，这就完全解耦了 View 层和 Model 层，这个解耦是至关重要的，它是前后端分离方案实施的重要一环

# MVC

![](/img/JavaScript-MVC、MVP、MVVM模式/MVC.png)

- 用户端操作View ，Js监听事件绑定DOM数据，传送指令到 Controller
- Controller 完成业务逻辑后，要求 Model 改变数据状态
- Model 将新的数据发送到 View，通过JS操作DOM为View赋值，用户得到反馈

> 如果前端没有框架，只使用原生的html+js，MVC模式可以这样理解：
>
> - 将html看成view
>
> - js看成controller，负责处理用户与应用的交互，响应对view的操作（对事件的监听），调用Model对数据进行操作，完成model与view的同步（根据model的改变，通过选择器对view进行操作）
>
> - 将js的ajax当做Model，也就是数据层，通过ajax从服务器获取数据

# MVVM

就像分析MVC是如何合理分配工作的一样，我们需要数据所以有了M，我们需要界面所以有了V，而我们需要找一个地方把M赋值给V来显示，所以有了C，然而我们忽略了一个很重要的操作：**数据解析**。在MVC出生的年代，手机APP的数据往往都比较简单，没有现在那么复杂，所以那时的数据解析很可能一步就解决了，所以既然有这样一个问题要处理，而面向对象的思想就是用类和对象来解决问题，显然V和M早就被定义死了，它们都不应该处理“解析数据”的问题，理所应当的，“解析数据”这个问题就交给C来完成了。而现在的手机App功能越来越复杂，数据结构也越来越复杂，所以数据解析也就没那么简单了。如果我们继续按照MVC的设计思路，将数据解析的部分放到了Controller里面，那么Controller就将变得相当臃肿。还有相当重要的一点：Controller被设计出来并不是处理数据解析的。1、管理自己的生命周期；2、处理Controller之间的跳转；3、实现Controller容器。这里面根本没有“数据解析”这一项，所以显然，数据解析也不应该由Controller来完成。那么我们的MVC中，M、V、C都不应该处理数据解析，那么由谁来呢？这个问题实际上在面向对象的时候相当好回答：既然目前没有类能够处理这个问题，那么就创建一个新的类出来解决不就好了？所以我们聪明的开发者们就专门为数据解析创建出了一个新的类：ViewModel。这就是MVVM的诞生

![](/img/JavaScript-MVC、MVP、MVVM模式/MVVM.png)

- 用户端操作View，ViewModel监听视图变化，触发绑定事件
- ViewModel组织好数据，请求服务端处理业务逻辑调用Model层操作数据
- 服务端处理完数据及逻辑后，要求 Model 改变数据状态
- ViewModel组装结果数据后自动绑定到View层，用户得到反馈

![](/img/JavaScript-MVC、MVP、MVVM模式/MVVM组成部分.png)

# 思考

1. ViewModel和Controller的区别

   Controller所要担任的任务更加全面，包括了很多的业务逻辑。而ViewModel则简化甚至剔除了业务逻辑，主要的工作就只是把Model中的数据组装成适合View使用的数据

2. 前端MVVM对比MVC的优点

   - MVC开发者在代码中大量调用相同的 DOM API, 处理繁琐 ，操作冗余，使得代码难以维护

     大量的DOM 操作使页面渲染性能降低，加载速度变慢，影响用户体验

     当 Model 频繁发生变化，开发者需要主动更新到View ；当用户的操作导致 Model 发生变化，开发者同样需要将变化的数据同步到Model 中，这样的工作不仅繁琐，而且很难维护复杂多变的数据状态

   - 数据驱动： 在以前的模式中，总是先处理业务数据，然后根据的数据变化，去获取DOM的引用然后更新DOM，也是通过DOM来获取用户输入，最后再进行数据的更新。而在MVVM中数据和业务逻辑处于一个独立且抽象的View Model中，ViewModel只要关注数据和业务逻辑，不需要和DOM之间打交道。由数据自动去驱动DOM去自动更新DOM，DOM的改变又同时自动反馈到数据，数据成为主导因素，这样使得在业务逻辑处理只要关心数据，方便且简单

# 参考资料

> [MVC，MVP 和 MVVM 的图示](http://www.ruanyifeng.com/blog/2015/02/mvcmvp_mvvm.html)
>
> [前后端分手大师——MVVM 模式](https://www.cnblogs.com/iovec/p/7840228.html)
>
> [前端MVVM理论-MVVM](https://www.jianshu.com/p/7088249276de)
>
> [MVC和MVVM的区别](https://blog.csdn.net/qq_42068550/article/details/89480350)


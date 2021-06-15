---
title: "GitHub Pages+Hugo构建个人博客"
date: 2019-05-12 23:20:00
tags: [编程]
categories: 环境搭建
---

# hugo配置

### 1、安装

- 下载地址：<https://github.com/gohugoio/hugo/releases>


- 我使用的版本：![hugo下载版本](/img/GitHubPages+Hugo构建个人博客/hugo下载版本.png)

- 解压后即可使用hugo命令，不过只能在当前文件夹下使用，所以需要配置环境变量

  ![查看hugo版本](/img/GitHubPages+Hugo构建个人博客/查看hugo版本.png)

### 2、配置环境变量

- 在系统变量Path后面追加一条，为hugo.exe的解压地址我的在D盘

  ```
  D:\hugo_0.83.1_Windows-64bit
  ```

### 3、项目创建

- 通过hugo命令创建站点目录并切换到该目录

  ```
  hugo new site hugo-blog
  cd hugo-blog
  ```

  目录结构如下，此时如果运行的话浏览器会白屏，因为此时只是一个空的站点需要下载主题后才能看到内容

  ![hugo项目结构](/img/GitHubPages+Hugo构建个人博客/hugo项目结构.png)

### 4、主题配置

- 主题网站：<https://themes.gohugo.io/>

- 我用的是这个主题：<https://github.com/AmazingRise/hugo-theme-diary>

- 选好主题一般都会直接指向GitHub仓库，下载zip到本地就行

- 将下载好的主题解压移动到项目目录下的themes文件夹

- 配置站点根目录下的config.toml文件

  我用的主题里面有作者提供的实例网站配置，把里面的内容复制到站点根目录的config.toml就完美运行了

  这里需要注意config.toml配置的theme名称必须和themes下的文件夹名称保持一致

  `具体hugo的配置还没仔细研究，本篇就简单介绍一下大体的搭建流程，以后可能会写一篇hugo配置/开发相关的`

### 5、本地编译

- 启动 Hugo 预览服务器，构建站点内容到内存中并在检测到文件更改后重新渲染

  ```
  hugo server
  ```

### 6、内容发布

- 在站点目录下有一个content文件夹，在该文件夹下创建一个posts，posts下创建.md格式的文章就可以自动识别发布了

  ![hugo项目结构2](/img/GitHubPages+Hugo构建个人博客/hugo项目结构2.png)

- 同理图片静态资源需要放在站点根目录static下，内容中图片引用也是以static为根目录进行读取的

  `目前没有处理图片在typora中不能显示，只能在网页预览站点中显示的问题`

# GitHub配置

### 1、仓库配置

- 创建一个新仓库，仓库需要命名为xxx.github.io，一个账户只能创建一个GitHub Pages

  ![创建博客项目](/img/GitHubPages+Hugo构建个人博客/创建博客项目.png)

- 创建好之后顶部点击settings，左侧菜单栏选择pages，点击choose a theme选择一个官方指定主题

  ![创建博客项目2](/img/GitHubPages+Hugo构建个人博客/创建博客项目2.png)

- 选择完主题后，访问仓库名就可以访问GitHub Pages主页了

### 2、GitHub加速

### 3、提交和版本同步




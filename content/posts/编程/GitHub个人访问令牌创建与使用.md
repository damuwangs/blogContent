---
title: "GitHub个人访问令牌创建与使用"
date: "2021-09-27"
tags: [编程]
categories: 环境搭建
---

# 前言

[2020 年 7 月](https://github.blog/2020-07-30-token-authentication-requirements-for-api-and-git-operations/)，GitHub官方宣布对所有经过身份验证的 Git 操作，使用基于令牌的身份验证（例如，个人访问、OAuth 或 GitHub 应用程序安装令牌）。

**从 2021 年 8 月 13 日开始，将在 GitHub.com 上对 Git 操作进行身份验证时不再接受帐户密码**

因此对于开发人员来说，如果无法再用密码对 GitHub.com 的 Git 操作进行身份验证，则必须通过 HTTPS（推荐）或 SSH 密钥开始使用个人访问令牌，以避免中断

# 创建个人访问令牌

1. ##### 登录GitHub点击头像，下拉选择settings选项

   ![](/img/GitHub个人访问令牌创建与使用/Settings.png)

2. ##### 点击Developer settings菜单进入开发者设置

   ![](/img/GitHub个人访问令牌创建与使用/DeveloperSettings.png)

3. ##### 点击PersonAccessTokens菜单进入个人令牌界面

   ![](/img/GitHub个人访问令牌创建与使用/PersonalAccessTokens.png)

5. ##### 点击GenerateNewToken生成新的令牌

   ![](/img/GitHub个人访问令牌创建与使用/newToken.png)

   令牌过期使用git拉取代码会报一个鉴权失败的错误，无法推送代码

# 修改本地Git账户配置

1. ##### 进入控制面板-凭据管理器，点击Windows凭据

   ![](/img/GitHub个人访问令牌创建与使用/Windows凭据.png)

2. ##### 可以看到普通凭据列表有一堆地址，找到GitHub对应的普通凭据

   ![](/img/GitHub个人访问令牌创建与使用/普通凭据.png)

   点击编辑设置密码为GitHub申请的个人令牌

# 参考资料

> [GitHub创建个人访问令牌教程]([Github创建个人访问令牌教程_这也太南了趴的博客-CSDN博客_github个人访问令牌](https://blog.csdn.net/qq_46941656/article/details/119737804))


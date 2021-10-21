---
title: "UniApp-原生插件开发"
date: "2021-10-20"
tags: [编程]
categories: UniApp

---

# 开发环境

## Java环境1.8

参考：[jdk1.8下载与安装教程](https://blog.csdn.net/weixin_44084189/article/details/98966787/)

## android环境

1. 软件下载

- 进入https://www.androiddevtools.cn/下载SDK Tools

  ![](/img/UniApp-原生插件开发/SDKTools.png)

- 下载完成点击SDK Manager.exe运行

  ![](/img/UniApp-原生插件开发/SDKManager.png)

- 需要下载以下插件

  ![](/img/UniApp-原生插件开发/插件下载.png)

2. 环境变量配置

- 系统变量下添加变量

  ```bash
  ANDROID_SDK_HOME，指向Android SDK根目录
  ```

- Path新增:

  ```bash
  Android SDK根目录\platform-tools;
  Android SDK根目录\tools;
  ```

- 命令行测试是否配置成功

  ```bash
  adb (成功后可以看到adb的版本号及命令行说明等信息)
  ```

## AndroidStudio

参考：[Android Studio官网](https://developer.android.google.cn/studio/index.html)

## demo下载

参考：[Android 离线SDK - 正式版](https://nativesupport.dcloud.net.cn/AppDocs/download/android?id=android-离线sdk-正式版)

# AndroidStudio运行

## 项目导入

- 点击Android Studio菜单选项File—>New—>Import Project

  ![](/img/UniApp-原生插件开发/导入1.png)

- 导入选择UniPlugin-Hello-As工程，点击OK！等待工程导入完毕

  ![](/img/UniApp-原生插件开发/导入2.png)

- 导入后切换为Android项目结构，目录如下

  ![](/img/UniApp-原生插件开发/目录.png)

## 生成签名文件

- 点击Build—>Generate Signed Apk

  ![](/img/UniApp-原生插件开发/生成签名.png)

- 默认选择APK点击下一步

  ![](/img/UniApp-原生插件开发/生成签名2.png)

- 选择生成位置（选择为app模块根目录），输入密码和别名点击下一步

  ![](/img/UniApp-原生插件开发/生成签名3.png)

- 选择类型（默认为debug）点击完成，成功生成.jks文件

  ![](/img/UniApp-原生插件开发/生成签名4.png)

## 申请Appkey

- 进入jdk bin目录执行指令输入密码读取签名信息

  ```bash
  keytool -list -v -keystore d:\123.jks -- d:\123.jks为签名文件位置
  ```

  ![](/img/UniApp-原生插件开发/读取签名信息.png)

- 登录[开发者中心](https://dev.dcloud.net.cn/)

- 在左侧菜单中选择我创建的应用，点击需要申请的应用

  ![](/img/UniApp-原生插件开发/我创建的应用.png)

- 在应用管理界面选择离线打包Key管理，根据需要选择对应平台，输入包名和SHA1，确认无误点击保存，即可获取到对应平台的App 

  ![](/img/UniApp-原生插件开发/生成appKey.png)

## 配置及运行

- app模块下的AndroidMainfest.xml替换dcloud_appkey对应值

  ```xml
  <meta-data
      android:name="dcloud_appkey"
      android:value="decloud开发者中心申请的appkey" />
  ```

- app模块下build.gradle修改签名配置

  ```js
  signingConfigs {
      config {
      	keyAlias 'jks别名'
      	keyPassword 'jks密码'
      	storeFile file('xxx.jks')
  	storePassword 'jks密码'
  	v1SigningEnabled true
  	v2SigningEnabled true
  	}
  }
  ```

- app模块下asssets—>data—>dcloud_control.xml—>appid替换

  ```xml
  <hbuilder>
  <apps>
      <app appid="decloud开发者中心申请的appid" appver=""/>
  </apps>
  </hbuilder>

# 插件开发

# 插件调试

## 本地插件注册

## 集成uni-app项目

# 集成运行HbuliderX项目

## 插件编译及配置

## 插件引入

## 自定义调试基座

## 插件使用

# 注意

1. 如果出现Android SDK路径不对问题，请在Android Studio中鼠标右键UniPlugin-Hello-AS选择Open Module Settings, 在SDK Location 中设置相关环境路径

   ![](/img/UniApp-原生插件开发/SDKLocation.png)

1. 项目初始化时如果下方一直提示gradle下载中,则可以手动下载放到gradle安装目录(默认为：C:\Users\Administrator\.gradle\wrapper\dists)
   替换后重启android Studio正常编译项目

# 参考资料

> [申请Appkey](https://nativesupport.dcloud.net.cn/AppDocs/usesdk/appkey)
>
> [安卓打包,显示未配置appkey或配置错误](https://ask.dcloud.net.cn/question/122811)

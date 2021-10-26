---
title: "UniApp-原生插件开发"
date: "2021-10-20"
tags: [编程]
categories: UniApp
---

# 一、开发环境

## Java环境1.8

参考：[jdk1.8下载与安装教程](https://blog.csdn.net/weixin_44084189/article/details/98966787/)

## Android环境

1. 软件下载

- [下载SDK Tools](https://www.androiddevtools.cn)

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

# 二、AndroidStudio运行

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
  ```
  
- 点击Android Studio菜单选项Build—>Rebuild Project编译项目

  ![](/img/UniApp-原生插件开发/编译项目.png)

- 安装模拟器后点击运行，启动项目

  ![](/img/UniApp-原生插件开发/启动项目.png)

  启动成功弹出模拟器

  ![](/img/UniApp-原生插件开发/模拟器.png)

# 三、插件开发

## 插件注册

- 第一种方式

  在UniPlugin-Hello-AS工程下 “app” Module根目录assets/dcloud_uniplugins.json文件。 在moudles节点下 添加你要注册的Module 或 Component

  ```js
  {
    "nativePlugins": [
      {
        "plugins": [
          {
            "type": "module",
            "name": "DCloud-RichAlert",
            "class": "uni.dcloud.io.uniplugin_richalert.RichAlertModule"
          }
        ]
      }
    ]
  }

- 第二种方式
  创建一个实体类并实现UniAppHookProxy接口，在onCreate函数中添加组件注册相关参数 或 填写插件需要在启动时初始化的逻辑。

  在UniPlugin-Hello-AS工程下 “app” Module根目录assets/dcloud_uniplugins.json文件，在hooksClass节点添加你创建实现UniAppHookProxy接口的实体类完整名称填入其中即可 (有些需要初始化操作的需求可以在此处添加逻辑，无特殊操作仅使用第一种方式注册即可无需集成UniAppHookProxy接口)

  ```java
  public class RichAlert_AppProxy implements UniAppHookProxy {
      @Override
      public void onCreate(Application application) {
          //当前uni应用进程回调 仅触发一次 多进程不会触发
        //可通过UniSDKEngine注册UniModule或者UniComponent
      }
  
    @Override
    public void onSubProcessCreate(Application application) {
        //其他子进程初始化回调 可用于初始化需要子进程初始化需要的逻辑
    }
  }
  ```

  ```js
  {
    "nativePlugins": [
      {
        "hooksClass": "uni.dcloud.io.uniplugin_richalert.RichAlert_AppProxy",
        "plugins": [
          {
            "type": "module",
            "name": "DCloud-RichAlert",
            "class": "uni.dcloud.io.uniplugin_richalert.RichAlertModule"
          }
        ]
      }
    ]
  }
  ```

  dcloud_uniplugins.json说明

  - nativePlugins： 插件跟节点 可存放多个插件
  - hooksClass： 生命周期代理（实现AppHookProxy接口类）格式(完整包名加类名)
  - plugins: 插件数组
  - name : 注册名称
  - class : module 或 component 实体类完整名称
  - type : module 或 component类型

## 插件类型

### 1、扩展Module

扩展非UI的特定功能，调用原生android方法

### 2、扩展组件 Component

使用Android原生控件

向JS环境发送一些事件，比如click事件，通过uniapp触发事件，在android进行响应

### 3、UniJSCallback结果回调

JS调用时，有的场景需要返回一些数据，比如以下例子，返回x、y坐标

### 5、globalEvent 事件

用于页面监听持久性事件，例如定位信息，陀螺仪等的变化

## 插件示例

封装了一个 RichAlertModule, 富文本alert弹窗Module，代码可参考UniPlugin-Hello-AS工程中的uniplugin_richalert模块

```java
public class RichAlertModule extends UniDestroyableModule {
    ...
    @UniJSMethod(uiThread = true)
    public void show(JSONObject options, UniJSCallback jsCallback) {
        if (mUniSDKInstance.getContext() instanceof Activity) {
            ...
            RichAlert richAlert = new RichAlert(mUniSDKInstance.getContext());
            ...
            richAlert.show();
            ...
        }
    }
    ...
    ...
    @UniJSMethod(uiThread = true)
    public void dismiss() {
        destroy();
    }

    @Override
    public void destroy() {
        if (alert != null && alert.isShowing()) {
            UniLogUtils.w("Dismiss the active dialog");
            alert.dismiss();
        }
    }

}
```

HBuilderX 项目中使用RichAlert示例

```js
// require插件名称  
const dcRichAlert = uni.requireNativePlugin('DCloud-RichAlert');              
// 使用插件  
dcRichAlert.show({  
    position: 'bottom',  
    title: "提示信息",  
    titleColor: '#FF0000',  
    content: "<a href='https://uniapp.dcloud.io/' value='Hello uni-app'>uni-app</a> 是一个使用 Vue.js 开发跨平台应用的前端框架!\n免费的\n免费的\n免费的\n重要的事情说三遍",  
    contentAlign: 'left',  
    checkBox: {  
        title: '不再提示',  
        isSelected: true  
    },  
    buttons: [{  
        title: '取消'  
    },  
    {  
        title: '否'  
    },  
    {  
        title: '确认',  
        titleColor: '#3F51B5'  
    }  
    ]  
}, result => {  
    switch (result.type) {  
        case 'button':  
            console.log("callback---button--" + result.index);  
            break;  
        case 'checkBox':  
            console.log("callback---checkBox--" + result.isSelected);  
            break;  
        case 'a':  
            console.log("callback---a--" + JSON.stringify(result));  
            break;  
        case 'backCancel':  
            console.log("callback---backCancel--");  
            break;  
   }  
})
```

# 四、调试与发布

## AndroidStudio调试

这种用于上层调用已完成，调试底层android插件

- 点击发行—>原生APP-本地打包—>生成本地打包App资源

  ![](/img/UniApp-原生插件开发/生成本地打包App资源.png)

  编译成功在unpackage目录下生成资源

  ![](/img/UniApp-原生插件开发/本地打包成功.png)

- 把APP资源文件放入到UniPlugin-Hello-AS工程下app  Module根目录assets/apps目录下

  ![](/img/UniApp-原生插件开发/导入AndroidStudio.png)

- appid注意 一定要统一否则会导致应用无法正常运行

  以dcloud_control.xml配置的appid为准

  ![](/img/UniApp-原生插件开发/AppID一致性.png)

- 配置好运行项目即可

## HbuilderX调试

这种用于底层插件开发完成，调试上层uniapp调用

- androidStudio编译成功，生成aar

  ![](/img/UniApp-原生插件开发/生成aar.png)

- 创建[package.json](https://nativesupport.dcloud.net.cn/NativePlugin/course/package)文件并填写必要的信息

  ```js
  {
  	"name": "RichAlert",// 插件名称
  	"id": "DCloud-RichAlert",// 插件标识，需要保证唯一性
  	"version": "0.1.3",// 插件版本号
  	"description": "示例插件",// 插件描述信息
  	"_dp_type":"nativeplugin",
  	"_dp_nativeplugin":{
  		"android": {
  			"plugins": [
  				{
  					"type": "module",// 根据上文插件类型填写module或component
  					"name": "DCloud-RichAlert",// 注册插件的名称, 注意：module 的 name 必须以插件id为前缀或和插件id相同
  					"class": "uni.dcloud.io.uniplugin_richalert.RichAlertModule"// Android项目中dcloud_uniplugins.json中配置的类名
  				}
  			],
  			"integrateType": "aar",// 可取值aar|jar
  			"minSdkVersion" : 16// 支持的Android最低版本，如21
  		}
  	}
  }
  ```

- 创建插件文件夹，目录格式如下

  Dcloud-RichAlert为自定义插件名称，aar文件放在android目录下

  ![](/img/UniApp-原生插件开发/插件目录.png)

- 配置到uni-app项目下的“nativeplugins”目录

  ![](/img/UniApp-原生插件开发/插件引入.png)

- 在manifest.json文件的“App原生插件配置”项下点击“选择本地插件”，在列表中选择需要打包生效的插件

  ![](/img/UniApp-原生插件开发/加载插件.png)

- 点击运行—>运行到手机或模拟器—>制作自定义调试基座

  **APPID与开发者中心的相同**

  ![](/img/UniApp-原生插件开发/制作自定义基座.png)

  制作成功输出以下内容

  ![](/img/UniApp-原生插件开发/自定义基座生成.png)

- uniapp打包时需要点击运行—>运行到手机或模拟器—>运行基座选择—>自定义调试基座

# 注意

1. 如果出现Android SDK路径不对问题，请在Android Studio中鼠标右键UniPlugin-Hello-AS选择Open Module Settings, 在SDK Location 中设置相关环境路径

   ![](/img/UniApp-原生插件开发/SDKLocation.png)

1. 项目初始化时如果下方一直提示gradle下载中,则可以手动下载放到gradle安装目录(默认为：C:\Users\Administrator\.gradle\wrapper\dists)
   替换后重启android Studio正常编译项目
   
1. 关于uniapp自定义基座

   使用HBuilder/HBuilderX开发应用时，可在手机/模拟器上查看运行效果，点击菜单栏“运行”->“运行到手机或模拟器”使用。
   此功能会在手机/模拟器上安装“HBuilder”应用（或者叫HBuilder标准运行基座），在应用开发过程中HBuilder/HBuilderX会将应用资源实时同步到基座并刷新，从而实时查看到修改效果。
   上述HBuilder标准运行基座，是由DCloud提前打包好的，使用的是DCloud申请的第三方SDK配置，manifest里大多数设置都无法动态生效，需要再次打包才可以生效。
   例如微信分享，不管开发者在manifest里如何配置，使用HBuilder标准运行基座分享后显示的来源一定是“HBuilder”。
   但开发者真实打包后的手机应用又无法通过运行方式来调试，这导致涉及manifest配置的内容调测变的很困难。

   为了解决manifest配置相关调试的便利性问题，DCloud提供了制作自定义运行基座的功能，也就是开发者可类似DCloud一样，自己做一个运行基座，里面使用的是自定义的manifest配置。
   开发者打包了自定义运行基座，就可以把这个基座运行到手机/Android模拟器上，进行日志查看。

   **在uni-app应用中调用uni-app原生插件也必须使用自定义调试基座**

# 参考资料

> [uniapp原生插件开发](https://nativesupport.dcloud.net.cn/NativePlugin/course/android)
>
> [申请Appkey](https://nativesupport.dcloud.net.cn/AppDocs/usesdk/appkey)
>
> [安卓打包,显示未配置appkey或配置错误](https://ask.dcloud.net.cn/question/122811)


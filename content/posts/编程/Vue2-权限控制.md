---
title: "Vue2-权限控制"
date: "2022-02-09"
tags: [编程]
categories: VUE

---

# 权限配置

## devTools

是一个独立部署的前端权限，接口配置工具。主要分为四层

- 平台Platform：确保此工具可以跨项目使用，不用每一个项目再部署一套
- 系统system：每个平台下的左侧系统，一般同一个类型的功能会放在一个系统里
- 菜单menu：点击后跳转页面的具体菜单
- 功能function：主要指页面上的操作按钮，这里会配置对应的后台服务和接口名称

## 配置

1. 在devTools依次维护平台、系统、菜单和功能项
2. 系统会预留一个拥有所有权限的管理账户
3. 登录管理员账户进入系统管理功能新增角色，权限会以树的形式进行多选展示
4. 进入员工管理功能录入基本信息，角色信息会以一个多选的checkbox进行勾选
5. 将创建好的员工分配给具体用户

# 权限实现

用户登录成功时会调用GetMenuInfo，获取当前登录账户的所有权限，并将权限放入全局状态和缓存

```javascript
/**
 * @description: 查询当前登录用户权限数据
 * @param {object} data 登录返回token
 * @return {promise}
 */
GetMenuInfo: ({ commit }, data) => {
	return new Promise((resolve, reject) => {
        let subData = {
        	'tk': data.v.token
      	}
      	// 请求服务端返回当前登录用户的权限数据
      	base.getMenuInfo(subData).then(response => {
        	// 保存system到state中
        	commit('SET_SYSTEMS', response.data.v.SystemList)
        	storage.setLocalStorage('SYSTEMS', response.data.v.SystemList)
        	// 保存menu到state中
        	commit('SET_MENUS', response.data.v.MenuList)
        	storage.setLocalStorage('MENUS', response.data.v.MenuList)
        	// 保存function到state中
        	commit('SET_FUNCTIONS', response.data.v.FunctionList)
        	storage.setLocalStorage('FUNCTIONS', response.data.v.FunctionList)
        	resolve()
     	 }).catch(error => {
        	reject(error)
      	})
    })
```

退出时会清空所有全局状态和缓存

## 菜单权限

系统左侧菜单用的element_ui的menu导航

```html
<!--router：使用 vue-router 的模式，启用该模式会在激活导航时以 index 作为 path 进行路由跳转-->
<el-menu
    :default-active="activeIndex"
    :collapse="toggle"
    mode="vertical"
    router
    :unique-opened="true"
    :collapse-transition="false"
>
    <submenu :menu="menuData" />
</el-menu>
```

这里从全局中获取菜单数据并组合成如下格式，也就是menuData传给子组件

```json
{
        "SysId":"AirTickets",
        "SysName":"机票",
        "PlatFormType":"ManagementSystems",
        "SortNo":20,
        "DefaultIcon":"sxiconmg-flight",
        "DefaultUrl":"http://localhost:8080/",
        "path":"/AirTickets",
        "name":"机票",
        "children":[
            {
                "SysId":"AirTickets",
                "MenuId":"AirTicketsOrder",
                "MenuName":"机票订单",
                "ParentId":"0",
                "SortNo":"10",
                "path":"AirTicketsOrder",
                "name":"机票订单"
            },
            {
                "SysId":"AirTickets",
                "MenuId":"AirticketsAnalysis",
                "MenuName":"票号解析",
                "ParentId":"0",
                "SortNo":"3",
                "path":"AirticketsAnalysis",
                "name":"票号解析"
            }
        ]
    },
```

在子组件中递归显示所有子菜单

```html
<template>
	<div class="menu-wrapper">
    	<template v-for="item in menu">
	    	<!-- 只有一级菜单 -->
      		<el-menu-item
        		v-if="!item.children && !item.hidden"
        		:key="item.path"
        		:index="parent ? parent + '/' + item.path : item.path"
      		>
        		<i :class="['iconfont', item.DefaultIcon]"></i>
        		<span slot="title">{{ item.name }}</span>
			</el-menu-item>
			<!-- 多级菜单 -->
			<el-submenu
				v-if="item.children && !item.hidden"
				:key="item.path"
				:index="parent ? parent + '/' + item.path : item.path"
              >
				<template slot="title">
					<i :class="['iconfont', item.DefaultIcon]"></i>
					<span>{{ item.name }}</span>
				</template>
				<!-- 递归 -->
				<sidebar-item
					:menu="item.children"
					:parent="parent ? parent + '/' + item.path : item.path"
				/>
			</el-submenu>
    	</template>
  	</div>
</template>
```


预览如下

![](/img/Vue2-权限控制/左侧菜单.png)

## 按钮权限

公共方法中提供了过滤当前所在功能按钮权限的方法

```javascript
/**
 * @description: 数组过滤（匹配某菜单下所有方法）
 * @param {string} sysId 系统ID
 * @param {string} menuId 菜单ID
 * @return {array} 某一菜单下的所有Function
 */
const filterarr = function (sysId, menuId) {
  // 获取缓存中所有的FUNCTION
  let array = JSON.parse(localStorage.getItem('management-FUNCTIONS')) || []
  // 根据传入系统和菜单唯一标识，返回当前功能的所有按钮
  let newArr = array.filter(item => {
    return item.SysId === sysId && item.MenuId === menuId
  })
  return newArr
}
```

这里以系统中任一功能演示

```javascript
/**
 * @description: 绑定当前功能页面的按钮权限
 * @param {*}
 * @return {*}
 */
getFunc () {
	let pagefunc = filterarr('SysManagement', 'EmployeeManagement')
    pagefunc.forEach((item) => {
        if (item.FunctionId === 'SaveEmployee') {
            this.isAddFuc = true // 新增按钮是否显示
            this.addFuc = item // 新增api信息
        }
        if (item.FunctionId === 'UpdateEmployee') {
            this.isUpdateFuc = true // 修改按钮是否显示
            this.updateFuc = item // 修改api信息
        }
        if (item.FunctionId === 'GetEmployeeEntity') {
            this.isViewFuc = true // 查看按钮是否显示
            this.viewFuc = item // 查看api信息
        }
    })
},
```

按钮显示需要加上v-if判断权限

```html
<el-button v-if="isAddFuc" @click="bindEdit('add')">添加</el-button>
```

发送请求时不用重新定义api

```javascript
/**
 * @description: 查询当前登录用户权限数据
 * @param {object} data 接口请求参数
 * @param {string} ServiceName 接口服务名称（一个平台对应一个服务）
 * @param {string} ApiName 接口名称
 * @return {*}
 */
base.commonFuc(data, this.addFuc.ServiceName, this.addFuc.ApiName).then((res) => {
    ...
})
```

# 注意

1. 权限菜单的跳转是根据系统和菜单维护的编号与router中配置的路由匹配的，需要保持一致


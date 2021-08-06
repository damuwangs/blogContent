---
title: "Vue2-token"
date: "2021-08-06"
tags: [编程]
categories: VUE

---

# token的含义

> 1、Token的引入：
>  Token是在客户端频繁向服务端请求数据，服务端频繁的去数据库查询用户名和密码并进行对比，判断用户名和密码正确与否，并作出相应提示，在这样的背景下，Token便应运而生。
>
> 2、Token的定义：
>  Token是服务端生成的一串字符串，以作客户端进行请求的一个令牌，当第一次登录后，服务器生成一个Token便将此Token返回给客户端，以后客户端只需带上这个Token前来请求数据即可，无需再次带上用户名和密码。
>
> 3、使用Token的目的：
>  Token的目的是为了减轻服务器的压力，减少频繁的查询数据库，使服务器更加健壮。
>
> 4、Token 的优点：
>  扩展性更强，也更安全点，非常适合用在 Web 应用或者移动应用上。Token 的中文有人翻译成 “令牌”，我觉得挺好，意思就是，你拿着这个令牌，才能过一些关卡。

# 项目中使用token

说明

| 文件名称 | 功能描述                                           |
| -------- | -------------------------------------------------- |
| auth.js  | 设置、获取以及清空cookie                           |
| http.js  | 接口请求封装                                       |
| store.js | 对接业务的状态管理，负责登录、登出状态的保存和移除 |

流程梳理

1. 用户输入信息点击登录，调用store.js中的Login方法请求登录接口，调用成功返回200回传token值

2. 接着调用SaveLoginInfo方法，将token值state中保存一份，再调用setToken将token在cookie中也保存一份

   因为vuex刷新页面数据会丢，所以在cookie里面也放了一份，使用的时候只需要通过getter方法获取state就可以，state默认值为调用getToken获取的cookie中的token值

3. 此时token对象就可以全局使用了，除登录以外的所有接口请求都要传token，否则会报505错误

4. token由服务端生成，设置了失效时间为24小时

   当token过期，前端再发送请求，服务端会返回505，此响应会被http.js的拦截器捕获

   捕获后先弹框提示‘登录信息已过期，请重新登录'，接着调用store.js中的ClearLoginInfo方法清空state中全局token，再调用removeToken移除cookie

5. 清空完之后会执行跳转，重新回到登录页面重复步骤一

6. 退出登录与登录操作类似，用户点击退出登录按钮，调用store.js里的ClearLoginInfo方法。先清空state中全局token，再调用removeToken移除cookie

代码

auth.js

```js
import Cookies from 'js-cookie'

const TokenKey = 'sxmanage-auth-token'// tokenKey为固定字符串

// 根据TokenKey获取cookie中的token信息
export function getToken () {
  return Cookies.get(TokenKey)
}
// 设置将token设置到cookie中
export function setToken (token) {
  return Cookies.set(TokenKey, token)
}
// 根据tTokenKey移除cookie中的token信息
export function removeToken () {
  return Cookies.remove(TokenKey)
}
```

http.js

```js
import axios from 'axios'
import store from '@/store'

const service = axios.create({
    timeout: 30000, // request timeout
    withCredentials: true
})

// resposne interceptor
service.interceptors.response.use(
    response => {
        const res = response.data
        if (res.c === 505)  {
            alert('登录信息已过期，请重新登录')
            // 清除数据
            store.dispatch('ClearLoginInfo').then(() => {
                // 跳转到登录页面
                router.push('/login')
            })
        }
        return response
    }, error => {
        return Promise.reject(error)
    }
)
```

store.js

```js
import Vuex from 'vuex'
import Vue from 'vue'
import { base } from '@/api/base'
import { getToken, setToken, removeToken} from '@/utils/auth'

Vue.use(Vuex)

const state = {
  token: getToken()
}

const getters = {
  token: state => state.token
}

const mutations = {
  SET_TOKEN: (state, token) => {
    state.token = token
  }
}

const actions = {
  /** 登录 */
  Login: ({ commit, dispatch }, userInfo) => {
    return new Promise((resolve, reject) => {
      base.login(userInfo).then(response => {
        if (response.data.c === 200) {
          // 先清除数据
          dispatch('ClearLoginInfo')
          // 再保存数据
          dispatch('SaveLoginInfo', response.data)
          resolve(response.data)
        } else {
          reject(response.data.c)
        }
      })
    })
  },
  // 保存登录信息
  SaveLoginInfo: ({ commit }, data) => {
    // state保存token
    commit('SET_TOKEN', data.v.token)
    // 保存token到cookie中
    setToken(data.v.token)
  },
  /** 清除数据 */
  ClearLoginInfo: ({ commit }) => {
    // 清除数据
    commit('SET_TOKEN', '')
    // 清除cookie中的token
    removeToken()
  }
}

export default new Vuex.Store({
  state,
  getters,
  mutations,
  actions
})
```

# 参考资料

> [token详解以及应用原理](https://blog.csdn.net/cmj6706/article/details/79032703)


---
title: "JavaScript-跨域"
date: "2021-08-04"
tags: [编程]
categories: JavaScript

---

# 概述

##  含义

1995年，同源政策由 Netscape 公司引入浏览器。目前，所有浏览器都实行这个政策

最初，它的含义是指，A网页设置的 Cookie，B网页不能打开，除非这两个网页"同源"

所谓"同源"指的是"三个相同"

> - 协议相同
> - 域名相同
> - 端口相同

常见跨域场景

![](/img/JavaScript-跨域/场景.png)

## 目的

同源政策的目的，是为了保证用户信息的安全，防止恶意的网站窃取数据。

设想这样一种情况：A网站是一家银行，用户登录以后，又去浏览其他网站。如果其他网站可以读取A网站的 Cookie，会发生什么？

很显然，如果 Cookie 包含隐私（比如存款总额），这些信息就会泄漏。更可怕的是，Cookie 往往用来保存用户的登录状态，如果用户没有退出登录，其他网站就可以冒充用户，为所欲为。因为浏览器同时还规定，提交表单不受同源政策的限制

由此可见，"同源政策"是必需的，否则 Cookie 可以共享，互联网就毫无安全可言了

## 限制范围

> - Cookie、LocalStorage 和 IndexDB 无法读取
> - DOM 无法获得
> - AJAX 请求不能发送

# 解决方案

## CORS

CORS 即是指跨域资源共享。它允许浏览器向非同源服务器，发出 Ajax 请求，从而克服了 Ajax 只能同源使用的限制。这种方式的跨域主要是在后端进行设置

这种方式的关键是后端进行设置，即是后端开启 Access-Control-Allow-Origin 为*或对应的origin就可以实现跨域

cors.html

```js
let xhr = new XMLHttpRequest() xhr.open('GET', 'http://localhost:8002/request')
xhr.send(null)
```

server.js

```js
const express = require('express')
const app = express()

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', 'http://127.0.0.1:5500') // 设置允许哪个域访问
  next()
})

app.get('/request', (req, res) => {
  res.end('server ok')
})

app.listen(8002)
```

## Jsonp

说明：利用了 script 标签可跨域的特性，在客户端定义一个回调函数（全局函数），请求服务端返回该回调函数的调用，并将服务端的数据以该回调函数参数的形式传递过来，然后该函数就被执行了。该方法需要服务端配合完成

优点：兼容性好

缺点：由于 script 本身的限制，该跨域方式仅支持 get 请求，且不安全可能遭受 XSS 攻击

实现步骤：

1. 声明一个全局回调函数，参数为服务端返回的 data。
2. 创建一个 script 标签，拼接整个请求 api 的地址（要传入回调函数名称如 ?callback=getInfo ），赋值给 script 的 src 属性
3. 服务端接受到请求后处理数据，然后将函数名和需要返回的数据拼接成字符串，拼装完成是执行函数的形式。（getInfo('server data')）
4. 浏览器接收到服务端的返回结果，调用了声明的回调函数

jsonp.html

```js
function getInfo(data) {
  console.log(data) // 告诉你一声， jsonp跨域成功
}

let script = document.createElement('script')
script.src = 'http://localhost:3000?callback=getInfo'
document.body.appendChild(script)
```

server.js

```js
const express = require('express')
const app = express()

app.get('/', (req, res) => {
  let { callback } = req.query
  res.end(`${callback}('告诉你一声， jsonp跨域成功')`)
})

app.listen(3000)
```

封装了一个 jsonp 函数

```js
function jsonp({ url, params, callback }) {
  return new Promise((resolve, reject) => {
    let script = document.createElement('script')
    // 定义全局回调函数
    window[callback] = function (data) {
      resolve(data)
      document.body.removeChild(script) // 调用完毕即删除
    }

    params = { callback, ...params } // {callback: "getInfo", name: "jacky"}
    let paramsArr = []
    for (const key in params) {
      paramsArr.push(`${key}=${params[key]}`)
    }
    // http://localhost:3000/?callback=getInfo&name=jacky
    script.src = `${url}?${paramsArr.join('&')}` 
    document.body.appendChild(script)
  })
}

jsonp({
  url: 'http://localhost:3000',
  params: {
    name: 'jacky',
  },
  callback: 'getInfo',
}).then(res => {
  console.log(res) // 告诉你一声， jsonp跨域成功
})
```

## Node 中间件代理

说明：同源策略是浏览器需要遵循的标准，而如果是服务器向服务器请求就没有跨域一说。

这次我们使用 express 中间件 http-proxy-middleware 来代理跨域, 转发请求和响应

实现步骤：

1. 接受客户端请求 
2. 将请求转发给服务器
3. 拿到服务器响应数据
4. 将响应转发给客户端

index.html

```js
let xhr = new XMLHttpRequest()
xhr.open('GET', '/api/request')
xhr.onreadystatechange = () => {
  if (xhr.readyState === 4 && xhr.status === 200) {
    console.log('请求成功，结果是：', xhr.responseText) // request success
  }
}
xhr.send(null)
```

nodeMdServer.js

```js
const express = require('express')
const { createProxyMiddleware } = require('http-proxy-middleware')

const app = express()

// 设置静态资源
app.use(express.static(__dirname))

// 使用代理
app.use(
  '/api',
  createProxyMiddleware({
    target: 'http://localhost:8002',
    pathRewrite: {
      '^/api': '', // 重写路径
    },
    changeOrigin: true,
  })
)

app.listen(8001)
```

nodeServer.js

```js
const express = require('express')
const app = express()

app.get('/request', (req, res) => {
  res.end('request success')
})

app.listen(8002)
```

## Nginx 反向代理

说明：实现原理类似于 Node 中间件代理，需要你搭建一个中转 nginx 服务器，用于转发请求。这种方式只需修改 Nginx 的配置即可解决跨域问题，前端除了接口换成对应形式，然后前后端不需要修改作其他修改。

实现思路：通过 nginx 配置一个代理服务器（同域不同端口）做跳板机，反向代理要跨域的域名，这样可以修改 cookie 中 domain 信息，方便当前域 cookie 写入，实现跨域登录

nginx 目录下修改 nginx.conf 

```yaml
// proxy服务器
server {
    listen 80;
    server_name  www.domain1.com;
    location / {
        proxy_pass   http://www.domain2.com:8080;  # 反向代理
        proxy_cookie_domain www.domain2.com www.domain1.com; # 修改cookie里域名
        index  index.html index.htm;

        # 当用webpack-dev-server等中间件代理接口访问nignx时，此时无浏览器参与，故没有同源限制，下面的跨域配置可不启用
        add_header Access-Control-Allow-Origin http://www.domain1.com;  # 当前端只跨域不带cookie时，可为*
        add_header Access-Control-Allow-Credentials true;
    }
}
```

启动 Nginx

index.html

```js
var xhr = new XMLHttpRequest()
// 前端开关：浏览器是否读写cookie
xhr.withCredentials = true
// 访问nginx中的代理服务器
xhr.open('get', 'http://www.domain1.com:81/?user=admin', true)
xhr.send()
```

server.js

```js
var http = require('http')
var server = http.createServer()
var qs = require('querystring')
server.on('request', function (req, res) {
  var params = qs.parse(req.url.substring(2))
  // 向前台写cookie
  res.writeHead(200, {
    'Set-Cookie': 'l=123456;Path=/;Domain=www.domain2.com;HttpOnly', // HttpOnly:脚本无法读取
  })
  res.write(JSON.stringify(params))
  res.end()
})
server.listen(8080)
```

## PostMessage

postMessage 是 HTML5 XMLHttpRequest Level 2 中的 API，且是为数不多可以跨域操作的 window 属性之一，它可用于解决以下方面的问题：

1. 页面和其打开的新窗口的数据传递
2. 多窗口之间消息传递
3. 页面与嵌套的 iframe 消息传递
4. 上面三个场景的跨域数据传递

总之，它可以允许来自不同源的脚本采用异步方式进行有限的通信，可以实现跨文本档、多窗口、跨域消息传递。

> otherWindow.postMessage(message, targetOrigin, [transfer])

- otherWindow：其他窗口的一个引用，比如 iframe 的 contentWindow 属性、执行 window.open 返回的窗口对象、或者是命名过或数值索引的 window.frames。
- message: 将要发送到其他 window 的数据。
- targetOrigin:通过窗口的 origin 属性来指定哪些窗口能接收到消息事件，其值可以是字符串"*"（表示无限制）或者一个 URI。在发送消息的时候，如果目标窗口的协议、主机地址或端口这三者的任意一项不匹配 targetOrigin 提供的值，那么消息就不会被发送；只有三者完全匹配，消息才会被发送。
- transfer(可选)：是一串和 message 同时传递的 Transferable 对象. 这些对象的所有权将被转移给消息的接收方，而发送一方将不再保有所有权。

这次我们把两个 html 文件挂到两个 server 下，采取 fs 读取的方式引入，运行两个 js 文件

postMessage1.html

```html
<body>
  <iframe src="http://localhost:8002" frameborder="0" id="frame" onLoad="load()"></iframe>
  <script>
    function load() {
      let frame = document.getElementById('frame')
      frame.contentWindow.postMessage('你好，我是postMessage1', 'http://localhost:8002') //发送数据
      window.onmessage = function (e) {
        //接受返回数据
        console.log(e.data) // 你好，我是postMessage2
      }
    }
  </script>
</body>
```

postMsgServer1.js

```js
const express = require('express')
const fs = require('fs')
const app = express()

app.get('/', (req, res) => {
  const html = fs.readFileSync('./postMessage1.html', 'utf8')
  res.end(html)
})

app.listen(8001, (req, res) => {
  console.log('server listening on 8001')
})
```

postMessage2.html

```html
<body>
  <script>
    window.onmessage = function (e) {
      console.log(e.data) // 你好，我是postMessage1
      e.source.postMessage('你好，我是postMessage2', e.origin)
    }
  </script>
</body>
```

postMsgServer2.js

```js
const express = require('express')
const fs = require('fs')
const app = express()

app.get('/', (req, res) => {
  const html = fs.readFileSync('./postMessage2.html', 'utf8')
  res.end(html)
})

app.listen(8002, (req, res) => {
  console.log('server listening on 8002')
})
```

## WebSocket 

说明：WebSocket 是一种网络通信协议。它实现了浏览器与服务器全双工通信，同时允许跨域通讯，长连接方式不受跨域影响

由于原生 WebSocket API 使用起来不太方便，我们一般都会使用第三方库如 ws

Web 浏览器和服务器都必须实现 WebSockets 协议来建立和维护连接。由于 WebSockets 连接长期存在，与典型的 HTTP 连接不同，对服务器有重要的影响

socket.html

```js
let socket = new WebSocket('ws://localhost:8001')
socket.onopen = function () {
  socket.send('向服务端发送数据')
}
socket.onmessage = function (e) {
  console.log(e.data) // 服务端传给你的数据
}
```

Server.js

```js
const express = require('express')
const WebSocket = require('ws')
const app = express()

let wsServer = new WebSocket.Server({ port: 8001 })
wsServer.on('connection', function (ws) {
  ws.on('message', function (data) {
    let buf = Buffer.from(data);
    console.log(buf.toString('utf-8')) // 向服务端发送数据
    ws.send('服务端传给你的数据')
  })
})
```

## document.domain + iframe

说明：这种方式只能用于二级域名相同的情况下。

比如 a.test.com 和 b.test.com 就属于二级域名，它们都是 test.com 的子域

只需要给页面添加 document.domain ='test.com' 表示二级域名都相同就可以实现跨域。

比如：页面 a.test.com:3000/test1.html 获取页面 b.test.com:3000/test2.html 中 a 的值

test1.html

```html
<body>
  <iframe
    src="http://b.test.com:3000/test2.html"
    frameborder="0"
    onload="load()"
    id="iframe"
  ></iframe>
  <script>
    document.domain = 'test.com'
    function load() {
      console.log(iframe.contentWindow.a)
    }
  </script>
</body>
```

test2.html

```js
document.domain = 'test.com'
var a = 10
```

## window.name + iframe

浏览器具有这样一个特性：同一个标签页或者同一个 iframe 框架加载过的页面共享相同的 window.name 属性值。在同个标签页里，name 值在不同的页面加载后也依旧存在，这些页面上 window.name 属性值都是相同的

利用这些特性，就可以将这个属性作为在不同页面之间传递数据的介质

>  由于安全原因，浏览器始终会保持 window.name 是 string 类型

a.html

```html
<body>
  <iframe
    src="http://localhost:8002/c.html"
    frameborder="0"
    onload="load()"
    id="iframe"
  ></iframe>
  <script>
    let first = true
    function load() {
      if (first) {
        // 第1次onload(跨域页)成功后，切换到同域代理页面
        let iframe = document.getElementById('iframe')
        iframe.src = 'http://localhost:8001/b.html'
        first = false
      } else {
        // 第2次onload(同域b.html页)成功后，读取同域window.name中数据
        console.log(iframe.contentWindow.name) // 我是c.html里的数据
      }
    }
  </script>
</body>
```

b.html（不需要往html加内容，默认html结构模板即可）

c.html

```html
<body>
  <script>
    window.name = '我是c.html里的数据'
  </script>
</body>
```

c 页面给 window.name 设置了值, 即便 c 页面销毁，但 name 值不会被销毁；a 页面依旧能够得到 window.name

## location.hash + iframe

说明：实现原理： a.html 欲与 c.html 跨域相互通信，通过中间页 b.html 来实现。 三个页面，不同域之间利用 iframe 的 location.hash 传值，相同域之间直接 js 访问来通信。

具体实现步骤：一开始 a.html 给 c.html 传一个 hash 值，然后 c.html 收到 hash 值后，再把 hash 值传递给 b.html，最后 b.html 将结果放到 a.html 的 hash 值中。

同样的，a.html 和 b.html 是同域的，都是http://localhost:8001，也就是说 b 的 hash 值可以直接复制给 a 的 hash。c.html 为http://localhost:8002下的

a.html

```html
<body>
  <iframe src="http://localhost:8002/c.html#jackylin" style="display: none;"></iframe>
  <script>
    window.onhashchange = function () {
      // 检测hash的变化
      console.log(456, location.hash) // #monkey
    }
  </script>
</body>
```

b.html

```js
window.parent.parent.location.hash = location.hash
// b.html将结果放到a.html的hash值中，b.html可通过parent.parent访问a.html页面
```

c.html

```js
console.log(location.hash) //  #jackylin
let iframe = document.createElement('iframe')
iframe.src = 'http://localhost:8001/b.html#monkey'
document.body.appendChild(iframe)
```

# 参考资料

> [浏览器同源政策及其规避方法](https://www.ruanyifeng.com/blog/2016/04/same-origin-policy.html)
>
> [前端跨域解决方案归纳整理](https://juejin.cn/post/6861553339994374157#heading-5)


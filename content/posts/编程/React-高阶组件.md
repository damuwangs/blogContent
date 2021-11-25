---
title: "React-高阶组件"
date: "2021-11-24"
tags: [编程]
categories: React

---

# 概述

一个高阶组件只是一个包装了另外一个React组件的React组件

# 基础高阶组件

## 装饰器模式

高阶组件可以看做是装饰器模式(Decorator Pattern)在React的实现。即允许向一个现有的对象添加新的功能，同时又不改变其结构，属于包装模式(Wrapper Pattern)的一种

```typescript
// 定义高阶组件
const withHeader = (WrappedComponent) => class extends React.Component {
    render() {
      return (
        <div>
          <div className="demo-header">高阶组件</div>
          <WrappedComponent {...this.props}/>
        </div>
      )
    }
  }

// 调用高阶组件  
@withHeader
class Demo extends React.Component {
  render() {
    return (
      <div>普通组件</div>
    )
  }
}
```

## 组件命名

当通过高阶组件来包装一个组件时，你会丢失原先 WrappedComponent 的名字，可能会给开发和 debug 造成影响

我们改写一下上述的高阶组件代码，增加了getDisplayName函数以及静态属性displayName，此时再去观察DOM Tree

```typescript
// 获取组件名称
function getDisplayName(component) {
    return component.displayName || component.name || 'Component'
}

// 定义高阶组件
const withHeader = WrappedComponent => class extends React.Component {
    // 设置高阶组件别名
    static displayName = `HOC(${getDisplayName(WrappedComponent)})`
    render() {
      return (
        <div>
          <div className="demo-header">我是标题</div>
          <WrappedComponent {...this.props}/>
        </div>
      )
    }
  }

// 调用高阶组件  
@withHeader
class Demo extends React.Component {
  render() {
    return (
      <div>我是普通组件</div>
    )
  }
}
```

之前高阶组件仅显示HOC，命名后如下显示

![](/img/React-高阶组件/组件命名.png)

## 组件传参

>  柯里化 Curry
>
> 概念：只传递函数的一部分参数来调用它，让它返回一个函数去处理剩下的参数
>
> 函数签名：fun(params)(otherParams)
>
> 应用：在React里，通过柯里化，我们可以通过传入不同的参数来得到不同的高阶组件

```typescript
// 定义高阶组件
const withHeader = title => WrappedComponent => class extends React.Component {
    render() {
      return (
        <div>
          {/* 获取参数并使用 */}
          <div className="demo-header">{title}</div>
          <WrappedComponent {...this.props}/>
        </div>
      )
    }
  }
  
// 调用高阶组件,在括号内定义参数  
@withHeader('我是标题')
class Demo extends React.Component {
  render() {
    return (
      <div>普通组件</div>
    )
  }
}
```

# 属性代理

## 更改 props

在修改或删除重要 props 的时候要小心，应该给高阶组件的 props 指定命名空间（namespace），以防破坏从外传递给 WrappedComponent 的 props

下面的例子中定义了一个新的newProps传给组件

```typescript
// 定义高阶组件
const withHeader = WrappedComponent => class extends React.Component {
    // 定义点击事件
    handleClick() {
      console.log('click')
    }
    render() {
      // 定义变量  
      const newProps = {
        user: '王大木'
      }        
      return (
        <div>
          <div className="demo-header">高阶组件</div>
          {/* 通过props传递变量和点击事件 */}
          <WrappedComponent {...this.props} {...newProps} handleClick={this.handleClick}/>
        </div>
      )
    }
  }

// 调用高阶组件  
@withHeader
class Demo extends React.Component {
  render() {
    return (
      <div>
        <div>普通组件</div>
        {/* 读取变量 */}
        <div>我是newProps：{this.props.user}</div>
	    {/* 调用点击事件 */}	
        <button onClick={this.props.handleClick}>点击</button>
      </div>
    )
  }
}
```

## 通过 refs 获取组件实例

当我们包装Usual的时候，想获取到它的实例怎么办，可以通过引用(ref),在Usual组件挂载的时候，会执行ref的回调函数，在HOC中取到组件的实例。通过打印，可以看到它的props， state，都是可以取到的。

```typescript
// 定义高阶组件
const withHeader = WrappedComponent => class extends React.Component {
   // 装载完成，读取组件并打印
   componentDidMount() {
      console.log(this.instanceComponent, 'instanceComponent')
    }
    render() {
      return (
        <div>
          <div className="demo-header">高阶组件</div>
          // 引用ref,在组件挂载的时候，会执行ref的回调函数，在HOC中取到组件的实例
          <WrappedComponent {...this.props} ref={instanceComponent => this.instanceComponent = instanceComponent}/>
        </div>
      )
    }
  }

// 调用高阶组件  
@withHeader
class Demo extends React.Component {
  constructor(props) {
    super(props)
      // 定义state
	  this.state = {
		test: '普通组件state'
	}
  }
  render() {
    return (
      <div>
        <div>普通组件</div>
      </div>
    )
  }
}
```

## 抽象 state

通过 { props, 回调函数 } 传递给wrappedComponent组件，通过回调函数获取state。用的比较多的就是react处理表单的时候。

通常react在处理表单的时候，一般使用的是受控组件，即把input都做成受控的，改变value的时候，用onChange事件同步到state中

```typescript
// 定义高阶组件
const withHeader = WrappedComponent => class extends React.Component {
  constructor() {
    super()
    // 定义state 
    this.state = {
      fields: {},
    }
  }
  // 通过fieldName绑定控件，触发调用onChange  
  getField = fieldName => {
    return {
      onChange: this.onChange(fieldName),
    }
  }
  // 文本框onChange事件  
  onChange = key => e => {
    console.log('key = ',key)
    console.log('e = ',e)      
    const { fields } = this.state
    // 将组件视图变化绑定给高阶组件的state
    fields[key] = e.target.value
    this.setState({
      fields,
    })
  }
  // 提交点击事件  
  handleSubmit = () => {
    console.log(this.state.fields)
  }

  render() {
    const props = {
      ...this.props,
      handleSubmit: this.handleSubmit,// 提交点击事件
      getField: this.getField,// 文本框值
    }
    return (
      <WrappedComponent {...props}/>
	)
  }
}

// 调用高阶组件
@withHeader
 class Login extends React.Component {
  render() {
    return (
      <div>
        <div>
          <label id="username">账户</label>
          {/* 绑定文本框 */}			
          <input name="username" {...this.props.getField('username')}/>
        </div>
        <div>
          <label id="password">密码</label>
		 {/* 绑定文本框 */}			
          <input name="password" {...this.props.getField('password')}/>
        </div>
		{/* 调用点击事件 */}
        <div onClick={this.props.handleSubmit}>提交</div>
      </div>
    )
  }
}
```

这里把state，onChange等方法都放到HOC里，其实是遵从的react组件的一种规范，子组件简单，傻瓜，负责展示，逻辑与操作放到Container。比如说我们在HOC获取到用户名密码之后，再去做其他操作，就方便多了，而state，处理函数放到Form组件里，只会让Form更加笨重，承担了本不属于它的工作，这样我们可能其他地方也需要用到这个组件，但是处理方式稍微不同，就很麻烦了

## 包装其它 elements

出于操作样式、布局或其它目的，你可以将 WrappedComponent 与其它组件包装在一起

上面的装饰器模式例子就是将高阶组件与组件包装在了一起

# 反向继承

返回的高阶组件类继承了 WrappedComponent。这被叫做反向继承是因为 WrappedComponent 被动地被高阶组件继承，而不是 WrappedComponent 去继承 高阶组件。通过这种方式他们之间的关系倒转了。

反向继承允许高阶组件通过 **this** 关键词获取 WrappedComponent，意味着它可以获取到 state，props，组件生命周期（component lifecycle）钩子，以及渲染方法（render）

```typescript
// 定义高阶组件
const iiHoc = WrappedComponent => class extends WrappedComponent {
    // 这里重写了组件的生命周期
    // 如果高阶组件和组件同时定义了相同的生命周期，高阶组件中的会覆盖掉组件中的
    componentDidMount(){
      console.log('hoc didmount')
    }
    render() {
      // 在高阶组件中读取组件的state
      console.log('state = ', this.state)
      // 继续渲染WrappedComponent组件  
      return super.render()
    }
}

// 调用高阶组件
@iiHoc
class Usual extends React.Component {
  constructor() {
    super()
    // 定义state
    this.state = {
      usual: 'usual',
    }
  }
  // 定义组件的生命周期
  // 如果高阶组件和组件同时定义了相同的生命周期，高阶组件中的会覆盖掉组件中的
  componentDidMount() {
    console.log('didMount')
  }

  render() {
    return (
      <div>Usual</div>
    )
  }
}
```

## 渲染劫持

渲染指的是 WrappedComponent.render 方法

```typescript
// 定义高阶组件
function iiHOC(WrappedComponent) {
  return class extends WrappedComponent {
    render() {
      // 如果 this.props.loggedIn 是 true，这个高阶组件会原封不动地渲染 WrappedComponent  
      if (this.props.loggedIn) {
        return super.render()
      // 如果不是 true 则渲染如下内容    
      } else {
        return <div>渲染</div>
      }
    }
  }
}

// 调用高阶组件
@iiHOC
class Usual extends React.Component {
  render() {
    return (
      <div>Usual</div>
    )
  }
}
```

> 注意：你不能通过 Props Proxy 来做渲染劫持
>
> 即使你可以通过 WrappedComponent.prototype.render 获取它的 render 方法，你需要自己手动模拟整个实例以及生命周期方法，而不是依靠 React，这是不值当的，应该使用反向继承来做到渲染劫持

## 操作组件state

高阶组件可以 『读取、修改、删除』WrappedComponent 实例的 state，如果需要也可以添加新的 state。

需要记住的是，你在弄乱 WrappedComponent 的 state，可能会导致破坏一些东西。通常不建议使用高阶组件来读取或添加组件 state，添加 state 需要使用命名空间来防止与 WrappedComponent 的 state 冲突

```typescript
// 定义高阶组件
export function IIHOCDEBUGGER(WrappedComponent) {
  return class extends WrappedComponent {
    render() {
      return (
        <div>
          {/* 读取组件props */}
          <p>Props</p> <pre>{JSON.stringify(this.props)}</pre>
          {/* 读取组件state */}
          <p>State</p><pre>{JSON.stringify(this.state)}</pre>
          {/* 渲染组件 */}
          {super.render()}
        </div>
      )
    }
  }
}
```

# 组合多个高阶组件

```typescript
export function HOC1(WrappedComponent) {
  return class extends WrappedComponent {
    render() {
      return (
        <div>
          <div className="demo-header">高阶组件1</div>
          <WrappedComponent {...this.props}/>
        </div>
      )
    }
  }
}

export function HOC2(WrappedComponent) {
  return class extends WrappedComponent {
    render() {
      return (
        <div>
          <div className="demo-header">高阶组件2</div>
          <WrappedComponent {...this.props}/>
        </div>
      )
    }
  }
}

@HOC1
@HOC2
class Usual extends React.Component {
  render() {
    return (
      <div>普通组件</div>
    )
  }
}
```

使用compose可以简化上述过程，也能体现函数式编程的思想

```typescript
const enhance = compose(withHeader,withLoading);
@enhance
class Demo extends Component{
    ...
}
```

> 组合 Compose
> compose可以帮助我们组合任意个高阶函数，例如compose(a,b,c)返回一个新的函数d，函数d依然接受一个函数作为入参，只不过在内部会依次调用c,b,a，从表现层对使用者保持透明

# 参考资料

> [深入浅出React高阶组件](https://zhuanlan.zhihu.com/p/28138664)
>
> [深入理解 React 高阶组件](https://www.jianshu.com/p/0aae7d4d9bc1)
>
> [React进阶之高阶组件](https://www.cnblogs.com/libin-1/p/7087605.html)
>
> [高阶组件注意事项](https://react.docschina.org/docs/higher-order-components.html#caveats)


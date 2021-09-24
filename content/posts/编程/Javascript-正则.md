---
title: "JavaScript-正则"
date: "2021-09-23"
tags: [编程]
categories: JavaScript
---



- # 字符串匹配single char

  ## 单个字符

  最简单的正则表达式可以由简单的数字和字母组成，没有特殊的语义，纯粹就是一一对应的关系。如想在'apple'这个单词里找到‘a'这个字符，就直接用`/a/`这个正则就可以了。

  但是如果想要匹配特殊字符的话，就要使用元字符`\`， 它是转义字符字符，顾名思义，就是让其后续的字符失去其本来的含义。举个例子：

  我想匹配`*`这个符号，由于`*`这个符号本身是个特殊字符，所以我要利用转义元字符\来让它失去其本来的含义

  ```js
  /\*/
  ```

  如果本来这个字符不是特殊字符，使用转义符号就会让它拥有特殊的含义。我们常常需要匹配一些特殊字符，比如空格，制表符，回车，换行等, 而这些就需要我们使用转义字符来匹配

  | 特殊字符   | 正则表达式 |
  | ---------- | ---------- |
  | 换行符     | \n         |
  | 换页符     | \f         |
  | 回车符     | \r         |
  | 空白符     | \s         |
  | 制表符     | \t         |
  | 垂直制表符 | \v         |
  | 回退符     | [\b]       |

  ```js
  // \s代表匹配空格，abc为匹配'abc'字符串
  const reg = /\sabc/
  console.log(reg.test(' abc')) // true
  ```

  ## 多个字符

  单个字符的映射关系是一对一的，即正则表达式的被用来筛选匹配的字符只有一个。而这显然是不够的，只要引入集合区间和通配符的方式就可以实现一对多的匹配了。

  在正则表达式里，集合的定义方式是使用中括号`[`和`]`。如`/[123]/`这个正则就能同时匹配1,2,3三个字符。那如果我想匹配所有的数字怎么办呢？从0写到9显然太过低效，所以元字符-就可以用来表示区间范围，利用`/[0-9]/`就能匹配所有的数字, `/[a-z]/`则可以匹配所有的英文小写字母。

  即便有了集合和区间的定义方式，如果要同时匹配多个字符也还是要一一列举，这是低效的。所以在正则表达式里衍生了一批用来同时匹配多个字符的简便正则表达式

  | 匹配区间                                      | 正则表达式 |
  | --------------------------------------------- | ---------- |
  | 除了换行符之外的任何字符                      | .          |
  | 单个数字, [0-9]                               | \d         |
  | 除了[0-9]                                     | \D         |
  | 包括下划线在内的单个字符，[A-Za-z0-9_]        | \w         |
  | 非单字字符                                    | \W         |
  | 匹配空白字符,包括空格、制表符、换页符和换行符 | \s         |
  | 匹配非空白字符                                | \S         |

  ```js
  // \d代表匹配0-9的数字，[a-z]为匹配所有小写字母
  const reg = /\d[a-z]/
  console.log(reg.test('1a2b')) // true
  ```

- # 数量匹配quantifiers

  要实现多个字符的匹配我们只要多次循环，重复使用我们的之前的正则规则就可以了。根据循环次数的多与少，我可以分为0次，1次，多次，特定次

  | 匹配规则    | 元字符          |
  | ----------- | --------------- |
  | 0次或1次    | ?               |
  | 0次或无数次 | *               |
  | 1次或无数次 | +               |
  | 特定次数    | {x}, {min, max} |

  ## 匹配一个或0个字符

  元字符`?`代表了匹配一个字符或0个字符

  ```js
  // 第一个?前面的字符串可以舍弃，第二个?前面的字符串可拼1个或2个
  const reg = /colou?rs?/
  console.log(reg.test('color')) // true
  console.log(reg.test('colors')) // true
  console.log(reg.test('colours')) // true
  console.log(reg.test('colour')) // true
  ```

  ## 匹配0个或无数个字符

  元字符`*`用来表示匹配0个字符或无数个字符。通常用来过滤某些可有可无的字符串

  ```js
  // *表示不限制，appl可随意拼接最后一位，也可不拼
  const reg = /appl*/
  console.log(reg.test('appl')) // true
  console.log(reg.test('apple')) // true
  ```

  元字符`+`适用于要匹配同个字符出现1次或多次的情况

  ```js
  // +限制apple必须出现1次或多次
  const reg = /apple+/
  console.log(reg.test('appl')) // false
  console.log(reg.test('apple')) // true
  ```

  ## 匹配特定的重复次数

  在某些情况下，我们需要匹配特定的重复次数，元字符`{`和`}`用来给重复匹配设置精确的区间范围。如'a'我想匹配3次,那么我就使用`/a{3}/`这个正则，或者说'a'我想匹配至少两次就是用`/a{2,}/`这个正则。

  以下是完整的语法：

  ```js
  - {x}: x次
  - {min, max}： 介于min次到max次之间
  - {min, }: 至少min次
  - {0, max}： 至多max次
  ```

  ```js
  // 限制a必须重复3次到5次，包括3和5
  const reg = /a{3,5}/
  console.log(reg.test('aaaaa')) // true
  ```

- # 位置边界匹配position

  在长文本字符串查找过程中，我们常常需要限制查询的位置。比如我只想在单词的开头结尾查找

  | 边界和标志 | 正则表达式 |
  | ---------- | ---------- |
  | 单词边界   | \b         |
  | 非单词边界 | \B         |
  | 字符串开头 | ^          |
  | 字符串结尾 | $          |
  | 多行模式   | m标志      |
  | 忽略大小写 | i标志      |
  | 全局模式   | g标志      |
  
  ## 单词边界
  
  单词是构成句子和文章的基本单位，一个常见的使用场景是把文章或句子中的特定单词找出来
  
  我想找到`cat`这个单词，但是如果只是使用`/cat/`这个正则，就会同时匹配到`cat`和`scattered`这两处文本。这时候我们就需要使用边界正则表达式`\b`，其中b是boundary的首字母。在正则引擎里它其实匹配的是能构成单词的字符(\w)和不能构成单词的字符(\W)中间的那个位置。
  
  上面的例子改写成`/\bcat\b/`这样就能匹配到`cat`这个单词了
  
  ```js
  // 包含cat都会被匹配到
  const reg1 = /cat/
  console.log(reg1.test('cat')) // true
  console.log(reg1.test('scattered')) // true
  
  // \b 设置了单词边界，必须为cat才能被匹配到,因此scattered会返回false
  const reg2 = /\bcat\b/
  console.log(reg2.test('cat')) // true
  console.log(reg2.test('scattered')) // false
  ```
  
  ## 字符串边界
  
  元字符`^`用来匹配字符串的开头。而元字符`$`用来匹配字符串的末尾。注意的是在长文本里，如果要排除换行符的干扰，我们要使用多行模式
  
  ```js
  // 从I开始0结束，匹配'I am scq000',忽略大小写，忽略换行符
  const reg1 = /^I am scq000$/m
  console.log(reg1.test(`I am scq000
                         I am scq000
                         I AM SCQ000`)) // true
  ```
  
- # 分组匹配

  ## 什么是分组

  通俗来说，我理解的分组就是在正则表达式中用（）包起来的内容代表了一个分组

  ```js
  // 匹配两位数字
  let reg = /(\d{2})/
  console.log(reg.test('12')) // true
  ```

  这里reg中的`(/d{2})`就表示一个分组，匹配两位数字

  ## 分组内容的的形式

  一个分组中可以像上面这样有一个具体的表达式，这样可以优雅地表达一个重复的字符串

  ```js
  // 匹配字符串'hahaha'
  let reg1 = /hahaha/
  let reg2 = /(ha){3}/
  console.log(reg1.test('hahaha')) // true
  console.log(reg2.test('hahaha')) // true
  ```

  这两个表达式是等效的，但有了分组之后可以更急简洁

  分组中还可以有多个候选表达式

  ```js
  // 匹配I come from hunan/hubei/zhejiang
  var reg = /I come from (hunan|hubei|zhejiang)/
  console.log(reg.test('I come from hunan')) // true
  console.log(reg.test('I come from hubei')) // true
  ```

  也就是说在这个分组中，通过|隔开的几个候选表达式是并列的关系，所以可以把这个|理解为或的意思

  ## 分组的分类

  分组有四种类型，我们使用的比较多的都是捕获型分组，只有这种分组才会暂存匹配到的串

  - 捕获型
  - 非捕获型
  - 正向前瞻型

  - 反向前瞻型

  

  ## 分组的应用

  ### 1. 捕获与引用

  被正则表达式捕获(匹配)到的字符串会被暂存起来，其中，由分组捕获到的字符串会从1开始编号，于是我们可以引用这些字符串

  ```js
  var reg = /(\d{4})-(\d{2})-(\d{2})/
  var dateStr = '2018-04-18'
  reg.test(dateStr)  //true
  console.log(RegExp.$1) // 2018
  console.log(RegExp.$2) // 04
  console.log(RegExp.$3) // 18
  ```

  ### 2. 结合replace方法做字符串自定义替换

  String.prototype.replace方法的传参中可以直接引用被捕获的串，比如我们想开发中常见的日期格式替换,例如后台给你返回了一个2018/04/18,让你用正则替换为2018-04-18，就可以利用分组

  这里需要注意的是`/`是需要用`\`转义的

  ```js
  let dateStr = '2018/04/18';
  let reg = /(\d{4})\/(\d{2})\/(\d{2})/;
  dateStr = dateStr.replace(reg, '$1-$2-$3')
  console.log(dateStr) // 2018-04-18
  ```

  ###  3. 反向引用

  正则表达式里也能进行引用，这称为反向引用

  ```js
  // \w{3}表示任意的三位字母或数字,\1表示引用第1个分组，这里代表前三个字符
  let reg = /(\w{3}) is \1/
  console.log(reg.test('kid is kid')) // true
  console.log(reg.test('dik is dik')) // true
  console.log(reg.test('kid is dik')) // false
  console.log(reg.test('dik is kid')) // false
  ```

  如果引用了越界或者不存在的编号的话，就被被解析为普通的表达式

  ```js
  // \w{3}表示任意的三位字母或数字,\1表示引用第6个分组，这里第6个分组不存在，所以解析成了字符串'\6'
  let reg = /(\w{3}) is \6/
  console.log(reg.test('kid is kid')) // false
  console.log(reg.test('kid is \6')) // true
  ```

  ### 4. 非捕获型分组

  有的时候只是为了分组并不需要捕获的情况下就可以使用非捕获型分组

  ```js
  let reg = /(?:\d{4})-(\d{2})-(\d{2})/
  let date = '2012-12-21'
  reg.test(date)
  console.log(RegExp.$1) // 12
  console.log(RegExp.$2) // 21
  ```

  ### 5. 正向与反向前瞻型分组

  正向前瞻型分组：你站在原地往前看，如果前方是指定的东西就返回true，否则为false

  ```js
  let reg = /kid is a (?=doubi)/
  console.log(reg.test('kid is a doubi')) // true
  console.log(reg.test('kid is a shabi')) // false
  ```

  反向前瞻型分组：你站在原地往前看，如果前方不是指定的东西则返回true，如果是则返回false

  ```js
  let reg = /kid is a (?!doubi)/
  console.log(reg.test('kid is a doubi')) // false
  console.log(reg.test('kid is a shabi')) // true
  ```

  ### 6. 前瞻型分组和非捕获型分组的区别

  ```js
  let reg, str = "kid is a doubi";
  reg = /(kid is a (?:doubi))/
  reg.test(str)
  console.log(RegExp.$1) // kid is a doubi
  
  reg = /(kid is a (?=doubi))/
  reg.test(str)
  console.log(RegExp.$1) // kis is a
  ```

  也就是说非捕获型分组匹配到的字符串任然会被外层分组匹配到，而前瞻型不会

  如果你希望在外层分组中不匹配里面分组的值的话就可以使用前瞻型分组了

# 参考资料

> [在线正则工具](https://jex.im/regulex/#!flags=&re=%5E(a%7Cb)*%3F%24)
>
> [正则表达式中的特殊字符](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Guide/Regular_Expressions)
>
> [正则表达式不要背](https://juejin.cn/post/6844903845227659271)
>
> [JS正则表达式的分组匹配](https://www.cnblogs.com/wancheng7/p/8906015.html)
>
> [正则表达式 - (?!), (?:), (?=)](https://www.cnblogs.com/allen2333/p/9835654.html)

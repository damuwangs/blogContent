---
title: "Javascript - 原型链"
date: "2021-06-24"
tags: [编程]
categories: 前端
---



- # 原型

- ## 理解原型对象

  无论什么时候，只要创建了一个新函数，就会根据一组特定的规则为该函数创建一个prototype属性，这个属性指向函数的原型对象。在默认情况下，所有原型对象都会自动获得一个constructor（构造函数）属性，这个属性包含一个指向prototype属性所在函数的指针。

  使用原型对象的好处是可以让所有对象实例共享它所包含的属性和方法。换句话说不必在构造函数中定义对象实例的信息，而是可以将这些信息直接添加到原型对象中

  ```
  function Person() {}
  
  Person.prototype.name = 'Nicholas'
  Person.prototype.age = 19
  Person.prototype.sayName = function () {
      console.log(this.name)
  }
  
  let person1 = new Person()
  person1.sayName() // 输出：Nicholas
  
  let person2 = new Person()
  person2.sayName() // 输出：Nicholas
  
  console.log(person1.sayName == person2.sayName) // 输出：true
  ```

  我们将sayName()方法和所有属性直接添加到Person的prototype属性中，构造函数变成了空函数。即使如此，也仍然可以通过调用构造函数来创建新对象，而且新对象还会具有相同的属性和方法。但与构造函数模式不同的是，新对象的这些属性和方法是由所有实例共享的。换句话说，person1和person2访问的都是同一组属性和同一个sayName()函数

  创建了自定义构造函数之后，其原型对象默认只会取得constructor属性，至于其它方法，则都是从Object继承而来。当调用构造函数创建一个新实例后，该实例内部将包含一个指针（内部属性）____proto____指向构造函数的原型对象，需要明确的是，这个连接存在与实例和构造函数的原型之间，而不是存在与实例与构造函数之间

  ![hugo下载版本](/img/Javascript-原型链/原型关系.png)

  上图展示了Person构造函数、Person的原型属性以及Person现有两个实例之间的关系。在此，Person.prototype指向了原型对象，而Person.prototype.constructor又指回了Person。原型对象中除了包含constructor属性之外，还包括后来添加的其它属性。Person的每个实例person1和person2都包含一个内部属性____proto____，该属性仅仅指向了Person.prototype，换句话说，它们与构造函数没有直接关系。此外，要格外注意的是，虽然这两个实例都不包含属性和方法，但我们却可以调用person1.sayName。这是通过查找对象属性的过程来实现的

- ## 原型搜索机制

  每当代码读取某个对象的某个属性时，都会执行一次搜索，目标是具有给定名字的属性。搜索首先从对象的实例本身开始。如果在实例中找到了具有给定名字的实现，则返回该属性的值，如果没有找到，则继续搜索指针指向的原型对象，在原型对象中查找给定名字的属性。如果在原型对象中找到了这个属性，则返回该属性的值。也就是说，在我们调用person.sayName()的时候，会先后执行两次搜索。首先，解析器会问："实例person1有sayName属性吗？"答："没有。"然后，它继续搜索，再问："person1的原型有sayName属性吗？"答："有。"于是，他就读取那个保存在原型对象中的函数。当我们调用person2.sayName()时，将会重现相同的搜索过程，得到相同的结果。而正是多个对象实例共享原型所保存的属性和方法的基本原理

- ## 注意事项

  虽然可以通过对象实例访问保存在原型中的值，但却不能通过对象实例重写原型的值。如果我们在实例中添加了一个属性，而该属性与实例原型中的一个属性同名，那我们就在实例中创建该属性，该属性将会屏蔽原型中的那个属性

  ```
  function Person() {}
  
  Person.prototype.name = 'Nicholas'
  Person.prototype.age = 19
  Person.prototype.sayName = function () {
      console.log(this.name)
  }
  
  let person1 = new Person()
  let person2 = new Person()
  person1.name = '王大木'
  console.log(person1.name) // '王大木' ——————来自实例
  console.log(person2.name) // 'Nicholas' ——————来自原型
  ```

  在这个例子中，person1的name被一个新的值给屏蔽了。但无论访问person1.name还是访问person2.name都能正常的返回值，即分别是'王大木'（来自对象实例）和'Nicholas'（来自原型）。当console.log()中访问person1.name时，需要读取它的值，因此就会在这个实例上搜索一个名为name的属性。这个属性确实存在，于是就返回它的值而不必再搜搜索原型了。当以同样的方式访问person2.name时，并没有实例上发现该属性，因此就会继续搜索原型，结果在那里找到了name属性。

  当为对象实例添加一个属性时，这个属性就会屏蔽原型对象中保存的同名属性，换句话说，添加这个属性只会阻止我们访问原型中的属性，但不会修改那个属性。即使这个属性设置为null，也只会在实例中设置这个属性，而不会恢复其指向原型的连接

- # 原型链

- ## 理解原型链

  ![hugo下载版本](/img/Javascript-原型链/原型链图示.png)

  每个构造函数都有一个原型对象，原型对象都包含一个指向构造函数的指针，而实例都包含一个指向原型对象的内部指针。那么，假如我们让原型对象等于另一个类型的实例，结果会怎么样呢？显然，此时的原型对象将包含一个指向另一个原型的指针，相应的，另一个原型中也包含指向另一个构造函数的指针。假如另一个原型又是另一个类型的实例，那么上述关系依然成立，如此层层递进，就够成了实例与原型的链条。这就是所谓原型链的基本概念

  ```
  function SuperType() {
      this.property = 'SuperType'
  }
  
  SuperType.prototype.getSuperValue = function () {
      return this.property
  }
  
  function SubType() {
      this.subProperty = 'SubType'
  }
  
  // 继承了 SuperType
  SubType.prototype = new SuperType()
  
  SubType.prototype.getSubValue = function () {
      return this.subProperty
  }
  
  let instancce = new SubType()
  console.log(instancce.getSuperValue()) // 输出：SuperType
  ```

  以上代码定义了两个类型：SuperType和SubType。每个类型分别有一个属性和一个方法。它们的主要区别是SubType继承了SuperType，而继承时通过创建SuperType的实例，并将实例赋值给SubType.prototype实现的。实现的本质是重写原型对象，代之以一个新类型的实例。换句话说，原来存在于SuperType的实例中的所有属性和方法，现在也存在与于SubType中了。在确立了继承关系之后，我们给SubType.prototype添加了一个方法，这样就继承了SuperType的属性和方法的基础上又添加了一个新方法

  ![hugo下载版本](/img/Javascript-原型链/原型链.png)

  在上面代码中，我们没有使用SubType默认提供的原型，而是给它换了一个新的原型，这个新原型就是SuperType的实例。于是，新原型不仅具有作为一个SuperType的实例所拥有的全部属性和方法，而且内部还有一个指针，指向了SuperType的原型。最终结果就是这样：instance指向SubType的原型，SubType的原型又指向了SuperType的原型。getSuperValue()方法仍然还在SuperType.prototype中，但prototype则位于subType.prototype中。这是因为prototype是一个实例属性，而getSuperValue()则时一个原型方法。既然SubType.prototype现在是superType的实例，那么prototype当然就位于该实例中了

- ## 原型链搜索机制

  原型链本质上扩展了原型搜索机制。当以读取模式访问一个实例属性时，首先在会实例中搜索该属性。如果没有找到该属性，则会继续搜索实例的原型。在通过原型链实现继承的情况下，搜索过程就得以沿着原型链继续向上。拿上面的例子来说，调用instance.getSuperValue()会经历三个搜索步骤：

  1. 搜索实例
  2. 搜索SubType.prototype
  3. 搜索SuperType.prototype，最后一步才会找到该方法。在找不到该属性或方法的情况下，搜索过程总要一环一环地前行到原型链末端才会停下来

- ## 默认的原型

  所有引用类型默认都继承了Object，而这个继承也是通过原型链实现的。所有函数的默认原型都是Object的实例，因此默认原型都会包含一个内部指针，指向Object.prototype。这也正是所有自定义类型都会继承toString()、valueOf()等默认方法的根本原因。所以上面展示的原型链中还应包括另外一个继承层次

  ![hugo下载版本](/img/Javascript-原型链/默认原型.png)

  一句话，SubType继承了SuperType，而SuperType继承了Object。当调用instance.toString()时，实际上调用的时保存在Object.prototype中的那个方法

- ## 注意事项

  1. 子类型有时候需要重写超类型中的某个方法，或者添加超类型中不存在的某个方法。但不管怎样，给原型添加方法的代码一定要放在替换原型的语句之后

     ```
     function SuperType() {
         this.property = 'SuperType'
     }
     
     SuperType.prototype.getSuperValue = function () {
         return this.property
     }
     
     function SubType() {
         this.subProperty = 'SubType'
     }
     
     // 继承了 SuperType
     SubType.prototype = new SuperType()
     
     // 添加新方法
     SubType.prototype.getSubValue = function () {
         return this.subProperty
     }
     
     // 重写超类型中的方法
     SubType.prototype.getSuperValue = function () {
         return '重写SuperType'
     }
     
     
     let instancce = new SubType()
     console.log(instancce.getSuperValue()) // 输出： 重写SuperType
     ```

     以上代码中，第一个方法getSubValue()被添加到了SubType中，第二个方法getSuperValue是原型中已经存在的一个方法，但重写这个方法会屏蔽原来的那个方法。换句话说，当通过SubType的实例调用getSuperValue()时，调用的就是这个重新定义的方法，但通过SuperType的实例调用getSuperValue()时，还会继续调用原来的那个方法。这里要格外注意的时，必须在用SuperType的实例替换原型之后，再定义这两个方法

  2. 通过原型链实现继承时，不能使用对象字面量创建原型方法。因为这样做就会重写原型链

     ```
     function SuperType() {
         this.property = 'SuperType'
     }
     
     SuperType.prototype.getSuperValue = function () {
         return this.property
     }
     
     function SubType() {
         this.subProperty = 'SubType'
     }
     
     // 继承了 SuperType
     SubType.prototype = new SuperType()
     
     // 使用字面量添加新方法，会导致上一行代码无效
     SubType.prototype  = {
         getSubValue : function () {
            return this.subProperty
        }
     } 
     
     let instancce = new SubType()
     console.log(instancce.getSuperValue()) // 输出： error
     ```

     以上代码展示了刚刚把SuperType的实例赋值给原型，接着又将原型替换成一个对象字面量而导致报错。由于现在的原型包含的是一个Object的实例，而非SuperType的实例，因此我们设想中的原型链已经被切断，SubType和SuperType之间已经没有关系了

  3. 在通过原型实现继承时，原型实际上会变成另一个类型的实例。于是原先的实例属性也就顺理成章的变成了现在的原型属性了

     ```
     function SuperType() {
         this.color = ['red','blue','green']
     }
     
     function SubType() {
         
     }
     
     // 继承了 SuperType
     SubType.prototype = new SuperType()
     
     let instance1 = new SubType()
     instance1.color.push('black')
     console.log(instance1.color) // 输出：[ 'red', 'blue', 'green', 'black' ]
     
     let instance2 = new SubType()
     console.log(instance2.color) // 输出：[ 'red', 'blue', 'green', 'black' ]
     ```

     这个例子中SuberType构造函数定义了一个color属性，该属性包含一个数组（引用类型值）SuperType的每个实例都会又各自包含自己数组的color属性。当SubType通过原型链继承了SuperType之后，SuperType.prototype就变成了SuperType的一个实例，因此它也拥有了一个它自己的color属性，就跟专门创建了一个SubType.prototype.color属性一样。但结果是什么呢？结果是SubType的所有实例都会共享这一个color属性。而我们对instance1.color的修改能够通过instance2.color反应出来，这就充分证实了这一点

  4. 在创建子类型的实例时，不能向超类型的构造函数中传递参数。实际上，应该说是没有办法在不影响所有对象实例的情况下，给超类型的构造函数传递参数

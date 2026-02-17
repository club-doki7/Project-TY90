#import "../template.typ": book-style, term, dt, bad-formatting

#show: book-style

// translated at commit hash: 349422d22a371bb5f7edc80f10f6a463f6628081

= $lambda$ 演算

#linebreak()

#bad-formatting

$lambda$ 演算是最纯粹的计算形式。毫不夸张地说，这个精巧而简洁的系统是几乎所有函数式编程语言的理论基石，其影响遍及整个计算机科学领域。它最初是作为研究数学基础的工具，由阿隆佐·丘奇在 20 世纪 30 年代开发，并在后来被人们认识到是一种通用的计算模型。从本质上讲，$lambda$ 演算异常地简单：它的语法只定义了三种词项（表达式）。我们可以给出纯 $lambda$ 演算语法的如下形式化定义：

$
  e & ::= && x              & wide "变量" \
    &   | && lambda x dt e  & wide "抽象" \
    &   | && e_1 med e_2    & wide "应用"
$

让我们化整为零：

- 变量 ($x$): 一个名字，作为某个值的占位符；
- 抽象 ($lambda x dt e$): 一个匿名函数定义，$lambda x$ 是函数的#term[参数 (parameter)]，而表达式 $e$ 是函数体。$lambda$ 读作“兰姆达” (lambda)；
- 应用 ($e_1 med e_2$): 一个函数调用动作，表达式 $e_1$ 是函数，而 $e_2$ 是传给函数的#term[实参 (argument)]。

以上形式化定义几乎可以直接对应于像 Java 这样的程序语言中的数据结构。我们用一个密封接口 `Expr` 来表示这三个核心项：

```java
sealed interface Expr {
    record Var(String name) implements Expr {}
    record Abs(String paramName, Expr body) implements Expr {}
    record App(Expr f, Expr arg) implements Expr {}
}
```

其中 `Var(String name)` 对应于 $x$，`Abs(String paramName, Expr body)` 对应于 $lambda x dt e$，而 #linebreak() `App(Expr f, Expr arg)` 则对应于 $e_1 med e_2$。

$lambda$ 演算的强大之处源于几个基本概念。首先是#term[变量绑定 (variable binding)]：在形如 $lambda x dt x + 1$ 的函数抽象中，我们说*在函数体* $x + 1$ 中的 $x$ 是一个#term[绑定变量 (bound variable)]。任何没有被外层的 $lambda$ 绑定的变量都是#term[自由变量 (free variable)]。这一区别对于理解作用域至关重要。这直接引出了#term[$alpha$-等价 (alpha equivalence)] 的概念，即绑定变量的名称无关紧要。函数 $lambda x dt x$ 和 $lambda y dt y$ 在语义上是同一个函数——它们都是恒等函数。实现必须能够识别这种等价关系，才能正确处理变量的名称。

第二个核心概念是#term[$beta$-归约 (beta-reduction)]，它是 $lambda$ 演算的计算引擎。它形式化地定义了什么是函数应用：当一个函数抽象被应用于一个实参时，我们将函数抽象所引入的绑定变量在函数体中的所有#term[自由出现 (free occurrence)] 替换为实参。例如，将函数抽象 $lambda x dt x + 1$ 应用于实参 $5$ 写作 #linebreak() $(lambda x dt x + 1) med 5$。根据 $beta$-归约规则，我们将函数体 $x + 1$ 中所有的 $x$ 替换成 $5$，得到结果 $5 + 1$。这种替换过程是 $lambda$ 演算中计算的基本机制。直接进行字符串替换的算法复杂度较高，且存在名称冲突的风险，故实现中通常会避免这种做法，而是使用诸如#term[德布鲁因索引 (de Bruijn index)] 之类的无名表示法。具体来说，德布鲁因索引将变量名替换为数字，用以表示变量出现处到其#term[绑定符 (binder)] 的词法距离。

纯 $lambda$ 演算是图灵完备的，但它却难以直接应用于实际编程。例如，在 $lambda$ 演算中表示数字 $3$ 需要像 $lambda f dt lambda x dt f (f (f med x))$ 这样的复杂表达式。为了让程序写起来更方便，我们几乎总是需要扩展核心演算，引入额外的表达式类型，包括用于处理局部变量的 `let` 绑定、用于表示具体值（例如数字和字符串）的字面量，以及元组等数据结构：

```java
sealed interface Expr {
    // ...

    record Let(String name, Expr value, Expr body) implements Expr {}
    record Lit(int value) implements Expr {}
    record Tuple(ImmSeq<Expr> elements) implements Expr {}
}
```

这就引出了一个关键的设计问题：这些新构造应该被作为#term[原语 (primitive)] 织入，拥有自己的语义规则？还是应该用纯 $lambda$ 演算中已有的东西来定义它们？这代表了语言设计中的一个根本性权衡。例如，一个形如 $"let" x = e_1 "in" e_2$ 的 `let` 表达式可以被视作纯 $lambda$ 演算表达式 $(lambda x dt e_2) med e_1$ 的语法糖。这么做可以让核心语言保持简洁而优雅。另一种选择则是把 `let` 作为一种原语结构，也就是说类型检查器和求值器必须为其特设一套处理逻辑。将新结构作为原语织入通常能带来更好的性能和更准确的诊断信息，因为编译器能更准确地捕捉这些结构的#term[意图 (intent)]，但与此同时这也会增加核心系统的复杂度。许多语言都在寻求平衡：将数值字面量之类的基础且对性能至关重要的特性作为原语织入核心系统，而 `let` 绑定之类的高级模式则可能被视为语法糖，这些语法糖最后会被转换回抽象、应用和变量等基本概念。
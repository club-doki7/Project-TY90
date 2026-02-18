#import "../template.typ": book-style, term, dt, bad-formatting

#show: book-style

// translated at commit hash: 349422d22a371bb5f7edc80f10f6a463f6628081

= 核心实现
#linebreak()
#bad-formatting

#term[算法 W (Algorithm W)] 是函数式语言中最早也最优雅（就当时而言）的类型推断方案之一，它由 Robin Milner 于 1978 年开发，为推断#link("https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system")[#term[HM (Hindley-Milner) 类型系统]]中最一般的类型提供了一种#term[健全 (sound)] 且#term[完备 (complete)] 的方法。本节会给出一个算法 W 的 Java 实现，展示如何将数学基础翻译成能处理 $lambda$ 抽象、函数应用、`let` 多态和复杂#term[合一 (unification)] 的实际代码。

算法 W 的核心思想在于其通过*生成约束*和*执行合一*来进行类型推断的系统性方法：不是用局部性的分析来确定类型，而是生成类型变量、收集约束并运用合一求解约束，从而总揽全局。这种方法确保了类型推断总是能找到最通用的类型，这一特性对于在函数式语言中支持多态性至关重要。

== 符号约定

在深入探讨实现细节之前，先来看看 Hindley-Milner 类型系统的形式化类型规则。我们会引入一些数学符号。不用担心看不懂或是记不住：只消复行数十步，便会豁然开朗。

- $tau$ (tau, 陶) -- 表示 $"Int"$、$"Bool"$、$"Int" -> "Bool"$ 这样的#term[单态 (monomorphic)] 类型，它们是具体的、完全确定的类型。
- $alpha, beta$ (alpha / beta, 阿尔法 / 贝塔) -- 类型变量，用以在类型推断过程中代表未知的类型。特别地，为 $lambda$ 抽象的参数类型引入类型变量时，我们使用 $alpha$；为函数应用的结果类型引入类型变量时，我们使用 $beta$。
- $"fresh" alpha$ -- $alpha$ 是全新的、未曾出现过的类型变量。
- $Gamma$ (Gamma, 伽马 $gamma$ 的大写) -- 类型语境，将变量映射到其类型。它就像一本字典，其中记录着每个变量的类型。
- $forall alpha$ (forall alpha) -- 对类型变量的#term[全称量化 (universal quantification)]，表示“对于任何类型 $alpha$”——这是我们表达多态性的方式。
- $sigma$ (sigma, 西格玛) -- 表示形如 $forall alpha dt alpha -> alpha$ 的多态#term[类型概型 (type scheme)]。类型概型可被#term[实例化 (instantiate)] 为不同的具体类型。
- $sigma[alpha |-> tau]$ -- 类型替换：将概型 $sigma$ 中的所有类型变量 $alpha$ 替换为类型 $tau$——这是我们实例化多态类型的方式。
- $SS$ -- #term[替换集 (substitution set)]：类型变量到类型的映射，代表合一过程求得的解。
- $SS(alpha)$ -- 将替换集 $SS$ 中的每个替换应用于类型 $alpha$。
- $"gen"(Gamma, tau)$ -- #term[泛化 (generalisation)]：对单态类型中不存在于语境中的类型变量作全称量化，从而将#term[单态类型 (monotype)] 变为#term[多态类型 (polytype)]。
- $"inst"(sigma)$ -- 实例化，将多态类型（类型概型）中被量化的类型变量替换为全新的类型变量，从而将多态类型变成单态类型。
- $"ftv"(tau)$ -- #term[自由类型变量 (free type variable)]：$tau$ 中出现的未绑定类型变量的集合。
- $emptyset$ -- 空的替换集，表示对类型不做更改。
- ${ alpha |-> tau }$ -- 一个将类型变量 $alpha$ 映射到类型 $tau$ 的替换集。
- $SS_1 circle.tiny SS_2$ -- 组合两个替换集 $SS_1$ 和 $SS_2$。应用替换集 $SS_1 circle.tiny SS_2$ 相当于先应用 $SS_2$，后应用 $SS_1$。
- $in.not$ -- 集合成员否定，在#term[出现检查 (occurs check)] 中用于防止无限类型。

== 类型规则

#let t-var = $[T"-Var"]$
#let t-lam = $[T"-Lam"]$
#let t-app = $[T"-App"]$
#let t-let = $[T"-Let"]$
#let t-litint = $[T"-LitInt"]$
#let t-litbool = $[T"-LitBool"]$

变量规则 #t-var 在语境中查找变量的类型：

$
  (x : sigma in Gamma wide tau = "inst"(sigma))
  /
  (Gamma tack x : tau)
  quad
  #(t-var)
$

$lambda$ 绑定规则 #t-lam 引入新的变量绑定：

$
  (Gamma, x : alpha tack e : tau wide "fresh" alpha)
  /
  (Gamma tack lambda x dt e : alpha -> tau)
  quad
  #(t-lam)
$

函数应用规则 #t-app 通过合一将类型信息综合起来：

$
  (Gamma tack e_1 : tau_1 wide Gamma tack e_2 : tau_2 wide "fresh" beta wide SS = "unify"(tau_1, tau_2 -> beta))
  /
  (Gamma tack e_1 med e_2 : SS(beta))
  quad
  #(t-app)
$

`let` 多态规则 #t-let 允许泛化 `let` 绑定引入的变量：

$
  (Gamma tack e_1 : tau_1 wide sigma = "gen"(Gamma, tau_1) wide Gamma, x : sigma tack e_2 : tau_2)
  /
  (Gamma tack #[`let`] x = e_1 #[`in`] e_2 : tau_2)
  quad
  #(t-let)
$

字面量具有相应的基本类型：

$
  () / (Gamma tack #[`0`], #[`1`], #[`2`], ... : "Int") quad #(t-litint)
  \
  () / (Gamma tack #[`true`] : "Bool")
  quad
  () / (Gamma tack #[`false`] : "Bool")
  quad #(t-litbool)
$

这些规则概括了 HM 类型系统的精髓。如果信息量太大了，别担心！直接跳到 Java 代码，试着把公式中的符号对应到实际的代码行，很快你就会明白它们和代码的对应关系。虽然这些符号看起来可能很复杂，但它们在代码中实际上非常简单，主要是操作、查找和合并哈希表。

== 抽象语法树

我们的实现使用密封接口来模拟 ADT，对表达式和类型进行细致的建模。简洁起见，用于美化输出的 `toString` 方法已略去；除非经由 `@Nullable` 显式声明，引用类型的字段和参数总是非空（不为 `null`）的；类型为 `List` 的字段都视为不可变列表，可变列表则会使用 `ArrayList` 类型显式指明。

表达式的抽象语法树 `Expr` 描述了语言的语法结构。变量 `Var` 和函数抽象 `Abs` 直接对应于 $lambda$ 演算。函数应用 `App` 通过 $beta$-归约驱动计算。`Let` 构造引入能进行多态泛化的局部绑定。字面量 `LitInt`、`LitBool` 和元组 `Tuple` 为实际编程提供了具体的数据类型。

```java
sealed interface Expr {
    record Var(String name) implements Expr {}
    record App(Expr f, Expr arg) implements Expr {}
    record Abs(String paramName, Expr body) implements Expr {}
    record Let(String name, Expr value, Expr body) implements Expr {}
    record LitInt(int value) implements Expr {}
    record LitBool(boolean value) implements Expr {}
    record Tuple(List<Expr> elements) implements Expr {}
}
```

#colbreak()

类型的抽象语法树 `Type` 描述了表达式可能具有的类型。类型变量 `Type.Var` 在类型推断期间被作为占位符，在合一过程中被实例化为具体类型。箭头类型 `Type.Arrow` 表示函数类型。单例枚举 `Type.Int` 和 `Type.Bool` 提供了基础类型，而元组类型 `Type.Tuple` 支持了结构化数据。这些类型是是递归定义的，因而我们可以表达任意复杂的类型结构——从简单的整数到操作其他函数的高阶函数。

```java
sealed interface Type {
    record Var(Greek greek, int id) implements Type {}
    record Arrow(Type from, Type to) implements Type {}
    record Tuple(List<Type> elements) implements Type {}
    enum Int implements Type { INSTANCE }
    enum Bool implements Type { INSTANCE }

    Type.Int INT = Int.INSTANCE;
    Type.Bool BOOL = Bool.INSTANCE;
}
```

== 类型推断算法

算法 W 基于几种基本数据结构运行，这些数据结构体现了类型推断的核心概念。

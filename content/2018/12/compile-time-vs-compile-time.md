---
title: "Compile-time vs. compile-time【翻訳】"
date: 2018-12-05
tags:
- dlang
- tech
- translation
- d_wiki
---

[User:Quickfur/Compile-time vs. compile-time - D Wiki](https://wiki.dlang.org/User:Quickfur/Compile-time_vs._compile-time)

_By H. S. Teoh, March 2017_

<!-- One of D's oft\-touted features is its awesome "compile\-time" capabilities. However, said capabilities are also often the source of much confusion and misunderstanding, especially on the part of newcomers to D, often taking the form of questions posted to the discussion forum by frustrated users such as the classic: "Why can't the compiler read this value at compile\-time, since it's clearly known at compile\-time?!" -->

よく宣伝文句にされるD言語の機能のひとつに、素晴らしい「コンパイル時」能力があります。
しかしこの能力はしばしばD言語初心者の混乱と誤解を引き起こし、
苛ついたユーザーはディスカッションフォーラムにこのような質問を投げかけることになります。
「どう考えてもコンパイル時にわかる値なのに、
なんでコンパイラはコンパイル時にこの値を読んでくれないんですか？！」

<!-- This article hopes to clear up most of these misunderstandings by explaining just what D's "compile\-time" capabilities are, how it works, and how to solve some commonly\-encountered problems. -->

この記事ではそんな誤解を解き明かすべく、Dの「コンパイル時」機能とはなにか、
どのように動作するのか、頻出の問題をどのように解決するかを説明します。

<!-- There's compile\-time, and then there's compile\-time
----------------------------------------------------- -->

### これはコンパイル時、あれもコンパイル時

<!-- Part of the confusion is no thanks to the overloaded term "compile\-time". It sounds straightforward enough \-\- "compile\-time" is just the time when the compiler performs its black magic of transforming human\-written D code into machine\-readable executables. So, the reasoning goes, if feature X is a "compile\-time" feature, and feature Y is another "compile\-time" feature, then surely X and Y ought to be usable in any combination, right? Since, after all, it all happens at "compile\-time", and the compiler ought to be able to sort it all out magically. -->

混乱の原因は複数の意味を持つ「コンパイル時」という言葉には無さそうです。
「コンパイル時」という言葉は素直な言い方に思えます。
コンパイル時とは、単に人間の書いたDのコードをコンパイラが黒魔術でマシンリーダブルな実行ファイルに変換する時間のことです。
だとすれば、機能Xが「コンパイル時」の機能で、機能Yも「コンパイル時」の機能なら、
当然XとYは好きなように組み合わせられなければいけないはずですね？
ということで、すべてが「コンパイル時」に起こり、
コンパイラは魔法のようにすべてをシュッとしてくれなければいけないはずです。

<!-- The reality, of course, is a _bit_ more involved than this. There are, roughly speaking, at least _two_ distinct categories of D features that are commonly labelled "compile\-time": -->

もちろん現実には、混乱の原因として多少関係があります。
大まかに言うと、よく「コンパイル時」と呼ばれるDの機能には少なくとも2つのカテゴリが存在します。

<!-- *   Template expansion, or abstract syntax tree (AST) manipulation; and
*   Compile\-time function evaluation (CTFE). -->

- テンプレート展開、もしくは抽象構文木（AST）操作
- コンパイル時関数実行（CTFE）

<!-- While these two take place at "compile\-time", they represent distinct phases in the process of compilation, and understanding this distinction is the key to understanding how D's "compile\-time" features work. -->

「コンパイル時」にはコンパイルの過程に明確なフェーズとして存在するこの2箇所があり、
この区別を理解することはDの「コンパイル時」機能がいかに動作するかを理解するカギとなります。

<!-- In particular, the AST manipulation features apply to an early stage in the process of compilation, whereas CTFE applies to a much later stage. To understand this, it is helpful to know roughly the stages of compilation that a piece of code goes through: -->

特にAST操作機能はコンパイル過程の早い段階で適用され、CTFEはもっと後の段階に適用されます。
これを理解すると、コード片が通過していくコンパイル過程を大まかに知る役に立ちます。

<!-- 1.  Lexical analysis and parsing, where the compiler scans the human\-written text of the program and turns it into a syntax tree representing the structure of the code;
2.  AST manipulation, where templates are expanded and other AST manipulation features are applied;
3.  Semantic analysis, where meaning is assigned to various AST features, such as associating an identifier with a data type, another identifier with a function, and another identifier with a variable.
4.  Code generation, where the semantically\-analyzed code is used to emit the machine code that goes into the executable. -->

1. 構文解析とパーシング。コンパイラは人間の書いたプログラムをスキャンしコードの構造を表現する構文木に変換します
1. AST操作。テンプレートは展開され、その他AST機能が適用されます
1. 意味解析。識別子をデータ、関数、変数と関連付けるなどして、様々なASTの機能に意味が与えられます
1. コード生成。意味解析がされたコードは実行ファイルになる機械語を出力するのに使われます

<!-- CTFE sits somewhere between semantic analysis and code generation, and basically involves running D code inside an interpreter (called the CTFE engine) embedded inside the compiler. -->

CTFEは意味解析とコード生成の間のどこかに位置しており、
コンパイラに埋め込まれたインタプリタ（CTFEエンジンと呼ばれる）によるDのコードの実行が基本的に関わっています。

<!-- Since CTFE can only take place after semantic analysis has been performed, it no longer has access to AST manipulation features. Similarly, at the AST manipulation stage, no semantics have been attached to various structures in the code yet, and so "compile\-time" features that manipulate the AST can't access things inside the CTFE engine. -->

CTFEは意味解析が行われた後にあるので、AST操作機能にはアクセスできません。
同様に、AST操作の段階ではコード中の構造に意味が与えられていないため、
ASTを操作する「コンパイル時」機能はCTFEエンジンの成果にはアクセスできません。

<!-- Thus, as far as D's "compile\-time" features are concerned, there are really _two_ different "compile\-times"; an early phase involving manipulating the program's AST, and a late phase involving CTFE. Confusing these two is the source of most of the problems encountered when using D's "compile\-time" features. -->

したがって、Dの「コンパイル時」機能に関して言えば、2つの異なる「コンパイル時」が存在します。
先のAST操作に関わる段階と、後のCTFEが関わる段階です。
この2つの混同がDの「コンパイル時」機能において特に遭遇する問題の原因です。

<!-- These two phases interact in more complex ways than it might appear at first, though. In order to understand how this works, we need to look at each of these two categories of "compile\-time" features in more detail. -->

実際には、この2つのフェーズはもっと複雑に作用します。
これがどのように動くか理解するために、
「コンパイル時」機能の2つのカテゴリについてもっと詳しく見ていきましょう。

<!-- Template expansion / AST manipulation
------------------------------------- -->

### テンプレート展開・AST操作

<!-- One of the first things the compiler does when it compiles your code, is to transform the text of the code into what is commonly known as the Abstract Syntax Tree (AST). -->

コンパイラがコードをコンパイルするときに最初にすることは、
コードのテキストを抽象構文木（Abstract Syntax Tree、AST）として知られるものに変換することです。

<!-- For example, this program:

import std.stdio;
void main(string\[\] args)
{
    writeln("Hello, world!");
}

is parsed into something resembling this: -->

たとえば、このプログラムは

```d
import std.stdio;
void main(string[] args)
{
    writeln("Hello, world!");
}
```

以下のように再構築されます。

<!-- [![AST.svg](/images/thumb/b/bb/AST.svg/923px-AST.svg.png)](/File:AST.svg) -->
![AST.svg](/img/blog/2018/12/AST.svg)

<!-- (Note: this is not the actual AST created by the compiler; it is only an example to illustrate the point. The AST created by the compiler may differ slightly in structure and/or details.) -->

（注意：これはコンパイラが生成する実際のASTではありません。ただ主要な点を例示しているだけです。
コンパイラによって生成されるASTはこれと構造や細かい点が異なるかもしれません。）

<!-- The AST represents the structure of the program as seen by the compiler, and contains everything the compiler needs to eventually transform the program into executable machine code. -->
ASTはコンパイラが見ているプログラムの構造を表しており、
コンパイラがプログラムを機械語に変換する過程で必要になるすべてが含まれています。

<!-- One key point to note here is that in this AST, there are no such things as variables, memory, or input and output. At this stage of compilation, the compiler has only gone as far as building a model of the program structure. In this structure, we have identifiers like `args` and `writeln`, but the compiler has not yet attached semantic meanings to them yet. That will be done in a later stage of compilation. -->

このASTで注目すべき点は、変数、メモリ、入力や出力といったものが含まれないところです。
コンパイルのこの時点では、コンパイラはプログラムの構造のモデルを構築するだけです。
この構造の中には`args`や`writeln`のような識別子がありますが、コンパイラはまだそれらに意味論的な意味を与えていません。
それはコンパイルの後の段階で行われます。

<!-- Part of D's powerful "compile\-time" capabilities stem from the ability to manipulate this AST to some extent as the program is being compiled. Among the features that D offers are templates and `static if`. -->

Dの強力な「コンパイル時」機能のうち、このASTを操作する能力に由来するものの一部がコンパイルされます。
ここでDが提供するものはテンプレートと`static if`です。

<!-- ### Templates -->

#### テンプレート

<!-- _If you are already familiar with the basics of templates, you may want to skip to the following section._ -->

**もしあなたがテンプレートの基礎を理解しているなら、以下のセクションは飛ばしてもいいかもしれません。**

<!-- One of D's powerful features is templates, which are similar to C++ templates. Templates can be thought of as _code stencils_, or AST patterns that can be used to generate AST subtrees. For example, consider the following template struct: -->

Dの強力な機能のひとつに、C++のそれと同じようなテンプレートがあります。
テンプレートはコードのステンシル（訳注：同じ形をたくさん描くための文房具。型紙。）、
もしくはASTの部分木を生成できるASTパターンとして考えることができます。
例えば、以下のようなテンプレート構造体を考えてみましょう。

```d
struct Box(T)
{
    T data;
}
```

<!-- In D, this is a shorthand for a so\-called _eponymous template_ that, written out in full, is: -->

Dでは、これは冠名テンプレート（eponymous template）と呼ばれる略記であり、完全に書き下すとこうなります。

```d
template Box(T)
{
    struct Box
    {
        T data;
    }
}
```

<!-- Its corresponding AST tree looks something like this: -->

このテンプレートに相当するASTはこのようになります。

<!-- [![Template1.svg](/images/thumb/d/dd/Template1.svg/608px-Template1.svg.png)](/File:Template1.svg) -->

![Template1.svg](/img/blog/2018/12/Template1.svg)

<!-- When you instantiate the template with a declaration like: -->

テンプレートのインスタンス化はこのように行います。

```d
Box!int intBox;
```

<!-- for example, the type `Box!int` may not yet be defined. However, the compiler automatically makes a copy of the AST subtree under the `TemplateBody` node and substitute `int` for every occurrence of `T` in it. This generated AST subtree is then included among the program's declarations: -->

たとえば型`Box!int`はまだ定義されていないかもしれません。
しかし、コンパイラは自動的にAST部分木のコピーを`TemplateBody`ノード下に作り、
その中の`T`をすべて`int`に置き換えます。
こうして生成された以下のようなAST部分木が、プログラムの宣言に加えられます。

<!-- [![Template-example1.svg](/images/thumb/0/01/Template-example1.svg/373px-Template-example1.svg.png)](/File:Template-example1.svg) -->

![Template-example1.svg](/img/blog/2018/12/Template-example1.svg)

<!-- Which corresponds to this code fragment: -->

これは以下のようなコード片に相当します。

```d
struct Box!int
{
    int data;
}
```

<!-- (Note that you cannot actually write this in your source code; the name `Box!int` is reserved for the template expansion process and cannot be directly defined by user code.) -->

（実際はこのようなコードを書くことはできません。
`Box!int`という名前はテンプレート展開プロセスのためのものであり、
ユーザーコードで直接定義することはできません。）

<!-- Similarly, if you instantiate the same template with a different declaration, such as: -->

同様に、同じテンプレートを以下のように違う宣言でインスタンス化すると、

```d
Box!float floatBox;
```

<!-- it is as if you had declared something like this: -->

以下のようなものを宣言したのと同じになります。

```d
struct Box!float
{
    float data;
}

Box!float floatBox;
```

<!-- In effect, you are creating new AST subtrees every time you instantiate a template, which get grafted into your program's AST. -->

実際テンプレートをインスタンス化するたびに新しいAST部分木が生成され、プログラムのASTに組み込まれます。

<!-- One common use for this feature is to avoid boilerplate code: you can factor out commonly\-repeated bits of code into a template, and the compiler would automatically insert them each time you instantiate the template. This saves you a lot of repetitive typing, and thereby allows you to adhere to the DRY (Don't Repeat Yourself) principle. -->

この機能を使う主目的はコードの繰り返しの回避です。
よく繰り返されるコードを取り除いてテンプレートにすることができて、
そうするとコンパイラは自動的にテンプレートをインスタンス化して挿入します。
これによって多くの無駄なタイピングを防ぐことができて、
結果DRY（Don't Repeat Yourself）の原則を守ることができます。

<!-- D templates, of course, go much, much farther than this, but a full exposition of templates is beyond the scope of this article. -->

もちろんDのテンプレートはこれよりも奥がとてもとても深いものですが、
テンプレートのすべてを解説するのはこの記事のスコープを超えています。

<!-- The important point here is that template expansion happens in the AST manipulation phase of compilation, and therefore template arguments must be known _at the time the code in question is in its AST manipulation phase_. In common D parlance, we tend to say that template arguments must be known "at compile\-time", but this is often not precise enough. It is more precise to say that template arguments must be known during the AST manipulation phase of compilation. As we shall see later, being more precise will help us understand and avoid many of the common problems that D learners encounter when they try to use D's "compile\-time" features. -->

ここで重要なのは、テンプレート展開はコンパイルのAST操作フェーズに行われ、
したがってテンプレート引数は**問題のコードがAST操作フェーズにある時**にわかっていなければなりません。
これがDでは、テンプレート引数は「コンパイル時」にわかっていなければならない、と言われる傾向があります。
しかしこれは多くの場合正確な表現ではありません。
テンプレート引数はコンパイルのAST操作フェーズの間にわかっていなければならないと言ったほうが正確です。
後に見ていくように、正確な表現は理解を助け、
Dを学習する者がDの「コンパイル時」機能を使おうとしたときに遭遇する問題を回避する助けになります。

<!-- ### static if -->

#### static if

<!-- Another powerful feature in the AST manipulation phase of D compilation is `static if`. This construct allows you to choose a subtree of the AST to be compiled, or, conversely, which a subtree to be pruned. For example: -->

DのコンパイルのAST操作フェーズにおけるもうひとつの強力な機能が`static if`です。
これによってコンパイルされるASTの部分木や、逆に取り除かれる部分木を選択できます。
たとえばこのように。

```d
struct S(bool b)
{
    static if (b)
        int x;
    else
        float y;
}
```

<!-- The `static if` here means that the boolean parameter `b` is evaluated when the compiler is expanding the template `S`. The value of must be known _at the time the template is being expanded_. In D circles, we often say that the value must be known "at compile\-time", but it is important to more precise. We will elaborate on this more later. -->

この`static if`は、コンパイラがテンプレート`S`を展開している時にブーリアン引数`b`が評価されることを意味しています。
この値は**テンプレートが展開される時**にわかっていなければなりません。
Dのサークルでは、値は「コンパイル時」にわかっていなければならない、
とよく言いますが、もっと正確であらねばなりません。
これは後で説明します。

<!-- If the value of `b` is `true`, then the `else` branch of the `static if` is pruned away from the expanded template. That is, when you write: -->

`b`の値が`true`なら、`static if`の`else`ブランチは展開後のテンプレートから取り除かれます。
このように書いたなら、

```d
S!true s;
```

<!-- it is as if you declared: -->

このように宣言したのと同じことです。

```d
struct S!true
{
    int x;
}
```

<!-- _(You can't actually write this in your source code, of course, since the name `S!true` is reserved for the template expansion process and cannot be directly defined by user code. But this is just to illustrate the point.)_ -->

（もちろん実際はこのようなコードを書くことはできません。
`S!true`という名前はテンプレート展開プロセスのためのものでありユーザーコードで直接定義できないからです。
これは説明のためのものです。）

<!-- Note that the `else` branch is _completely absent_ from the expanded template. This is a very important point. -->

`else`ブランチは展開後のテンプレートから**完全になくなっています**。
これは非常に重要なことです。

<!-- Similarly, when you write: -->

同様に、以下のように書いたなら、

```d
S!false t;
```

<!-- it is as if you had declared: -->

それは以下のように宣言したのと同じです。

```d
struct S!false
{
    float y;
}
```

<!-- Note that the `if` branch is _completely absent_ from the expanded template. This is also a very important point. -->

`if`ブランチは展開後のテンプレートから**完全になくなっています**。
これもまた非常に重要です。

<!-- In other words, `static if` is a choice that affects the effective AST seen by later compilation phases. -->

言い換えると、`static if`は後のコンパイル段階が関わるASTに影響します。

<!-- To drive this point home further: at this stage, when `static if` is evaluated, notions like variables, memory, and I/O don't exist yet. We are manipulating the _structure_ of the program; _not_ its execution. In the above code, `x` and `y` are merely identifiers; they have not yet been assigned any semantic meanings like variables or data fields that reside in a concrete offset in the `struct`. This is done in subsequent stages of compilation. -->

もっと深く取り扱いましょう。
この段階、`static if`が評価される段階で、変数、メモリ、I/Oのような概念はまだ存在しません。
私達はプログラムの**構造**を操作しています。
実行ではありません。
上のコードで、`x`と`y`は単なる識別子です。
まだ変数や、
`struct`の具体的なオフセットに配置されるデータフィールドのような意味論的意味は与えられていません。
それはコンパイルの後の段階で行われます。

<!-- Why is this point so important? Because it relates to a common misunderstanding of D's "compile\-time" capabilities as it relates to CTFE, or Compile\-Time Function Evaluation. Let's talk about that next. -->

なぜこれが重要なのでしょうか？これがDの「コンパイル時」機能に対するよくある誤解に関係しているからです。
それにはCTFE、コンパイル時関数実行が関わってきます。
次はそれについて話しましょう。

<!-- CTFE
---- -->

### CTFE

<!-- CTFE stands for Compile\-Time Function Evaluation. This is an extremely powerful feature that D offers, and is similar to C++'s `constexpr` feature (though in the author's opinion far more powerful). -->

CTFEとはコンパイル時関数実行（Compile\-Time Function Evaluation）という意味です。
これはDの提供する極めて強力な機能であり、
（筆者はDのほうがはるかに強力だと思いますが）C++の`constexpr`と似ています。

<!-- The first and most important thing to understand about CTFE is that it happens _after the AST manipulation phase has been completed_. More precisely, it happens when the compiler has "finalized" the AST of that part of the program, and is performing semantic analysis on it. Identifiers are assigned meanings as modules, functions, function arguments, variables, and so on, control\-flow constructs like `if` and `foreach` are given their meanings, and other semantic analyses such as VRP (Value Range Propagation) are performed. -->

CTFEを理解するにあたって最も重要なのは、それが**AST操作フェーズが完了した後**に行われるということです。
もっと正確に言うと、プログラムの問題になっている部分のASTが「ファイナライズ」され、
意味解析を行っている時に行われます。
識別子にはモジュール、関数、引数、変数などの意味が割り当てられ、
`if`や`foreach`のような制御構文にも意味が与えられ、
その他VRP（Value Range Propagation）のような意味解析が行われます。

<!-- ### Constant\-folding -->

#### 定数畳み込み

<!-- Part of this semantic analysis is _constant\-folding_. For example, if we wrote something like this: -->

意味解析の一部に**定数畳み込み**があります。
たとえば、以下のようなコードを書いたとします。

```d
int i = 3*(5 + 7);
```

<!-- it would be a waste of computational resources to perform the indicated calculation (add 5 to 7, multiply the result by 3) at runtime, because all the arguments of the calculation are constants known to the compiler, and the result will never change at runtime. Of course, this particular example is trivial, but imagine if this line of code were inside a busy inner loop in a performance\-critical part of the program. If we _folded_ this constant expression into its resulting value, the program would run faster, since it wouldn't have to repeat this same calculation over and over, and indeed, it wouldn't even need to perform the calculation at all, since the answer is already known by the compiler. The answer could be directly assigned to `i`: -->

計算に用いられるすべての引数がコンパイラの知っている定数であり、実行時に結果が変化しないため、
実行時にこのような計算（5を7に足して、その結果を3にかける）のは計算資源の無駄です。
もちろんこの例はささいなものですが、
もしプログラムのパフォーマンスに大きく影響するビジーインナーループにこのコードがあったら、
と想像してみてください。
もしこの定数式を結果の値に**畳み込む**ことができたなら、
繰り返し同じ計算をしなくて良くなるためプログラムは速くなるはずで、
実際コンパイラは答えがわかっているので、ここでは何も行う必要はなくなります。
答えは直接`i`に代入できますね。

```d
int i = 36;
```

<!-- This process is called _constant\-folding_, and is implemented by basically all modern compilers of any language today. So it is nothing new. The D compiler, however, takes this game to a whole new level. -->

この過程は**定数畳み込み**と呼ばれ、基本的に現代的なコンパイラならどの言語でも実装されています。
何も新しいことではありません。
しかしDコンパイラは、これを全く新しいレベルに昇華させました。

<!-- ### Constant\-folding, glorified -->

#### 定数畳み込み（進化版）

<!-- Consider, for example, this code: -->

例えばこんなコードを考えてみます。

```d
int f(int x)
{
    return x + 1;
}

int i = 3*(5 + f(6));
```

<!-- Again, if we perform the calculation manually, we see that the value of the expression is 36. However, this time, the constants involved in the expression are masked by the function call to `f`. But since the definition of `f` is visible to the compiler, and all it does is to add a constant value 1 to its argument, the compiler should be able to deduce that, again, the expression is constant and does not need to be performed at runtime. -->

再び手計算してみると、この式の値は36であるとわかります。
しかし今回は、式に関わる定数が`f`への関数呼び出しで隠されています。
でもコンパイラは`f`の定義を見ることができて、そこでは引数に定数1を足しているだけなので、
コンパイラはこの式も定数であると推測可能であり、実行時には計算を行いません。

<!-- But what if `f` was more complicated than merely adding a constant to its argument, for example: -->

しかし`f`が単純な定数の足し算よりも複雑だったならばどうでしょうか。

```d
int f(int x)
{
    int a = 0;
    for (int i=1; i <= x/2; i++)
    {
        a += i;
    }
    return a + 1;
}

int i = 3*(5 + f(6));
```

<!-- Again, the value of `f(6)` is constant, but in order to know its value, the compiler has to effectively _run this function during compilation_. And in order to do that, the compiler essentially has to compile the body of `f` into a state where it can be run inside a D interpreter embedded inside the compiler. -->

またも`f(6)`の値は定数ですが、
コンパイラがその値を知るためには**この関数をコンパイル中に効率的に実行**しなければなりません。
そしてそのためには、コンパイラはコンパイラの中に埋め込まれているDインタプリタで実行できる状態へと、
`f`の中身をコンパイルする必要があります。

<!-- This, in a nutshell, is how CTFE came about in the history of D. There is a limit as to how much this D virtual machine can do, but there's an ongoing trend of expanding its capabilities as far as possible. As of this writing, the D compiler is able to execute significant chunks of the Phobos standard library during compilation, thus making many library features accessible during compilation without needing to implement them the second time inside the compiler. Furthermore, a focused effort is being spearheaded by Stefan Koch to replace the current CTFE engine with an even more powerful one based on a bytecode interpreter, that promises superior CTFE performance and better memory management, and eventually, more features. -->

簡単に言うと、これがCTFEがDの歴史に現れた経緯です。
D仮想マシンでできることには限界がありますが、その限界を可能な限りひろげようとする試みが目下進行中です。
これを書いている時点で、
DコンパイラはPhobos標準ライブラリのかなりの部分をコンパイル中に実行できるようになっており、
したがって多くのライブラリ機能はコンパイラ組み込みの実装を必要とせずにコンパイル時にアクセスできます。
さらに、現在のCTFEエンジンをバイトコードインタプリタを元にした、
より優れたCTFEパフォーマンスとメモリ管理、そしていつかは機能もより多くを実現する、
さらに強力なものに置き換える試みがStefan Kochの指揮のもと進められています。

<!-- ### Forcing CTFE evaluation -->

#### CTFE評価の強制

<!-- Of course, the compiler usually does not always go this far in attempting to constant\-fold an expression. Past a certain level of complexity, it makes more sense for the compiler to simply leave it up to the generated runtime code to compute the value of the expression. After all, it may be that the entire purpose of the program is to compute the constant answer to a complex mathematical problem. It wouldn't make sense to perform such a computation in the slower CTFE engine instead of letting the generated executable run the computation at native execution speed. -->

もちろんコンパイラは定数畳み込みを常に前もって行ってくれるとは限りません。
複雑さがある一定のレベルを超えたら、
コンパイラはその式の値を計算するコードを実行時用に生成するために残しておいたほうが合理的です。
プログラム全体の目的が複雑な数学の問題を解いて決まった解を計算することかもしれません。
そのような計算は遅いCTFE上で行うよりも、
実行ファイルを生成してネイティブな実行速度で行ったほうがいいでしょう。

<!-- Being _able_ to perform such a computation at compile\-time when needed, however, can be very useful. For example, you could precompute values for a lookup table that gets stored into the executable, so that there is no runtime cost associated with initializing the table when the program starts up. As such, it is sometimes desirable to _force_ the compiler to evaluate an expression at compile\-time rather than relegating it to runtime. The usual idiom is to assign the result of the computation to a construct that requires the value to be known at compile\-time, such as an `enum` or a template parameter. For example: -->

しかし、そのような計算を必要に応じてコンパイル時に**できるようにしておく**と、とても便利です。
たとえばルックアップテーブルの値を事前計算して実行ファイルに埋め込みたいとします。
そうすればプログラムの開始時のルックアップテーブルの初期化に関する実行時コストがなくなります。
このように、式の評価を実行時でなくコンパイル時に行ったほうが望ましい場面が時々あります。
そういうった場合に便利なイディオムとして、
コンパイル時に判明している値で計算を行った結果を代入する`enum`やテンプレート引数があります。
以下に例を挙げましょう。

<!-- ```d
int complicatedComputation(int x, int y)
{
    return ...; /* insert complicated computation here */
}

void main()
{
    // The compiler may choose to evaluate this at compile-time or not,
    // depending on how complex the computation is.
    int i = complicatedComputation(123, 456);

    // Since the value of an enum must be known at compile-time, the
    // compiler has no choice but to evaluate it in CTFE. This is the
    // standard idiom for forcing CTFE evaluation of an expression.
    enum j = complicatedComputation(123, 456);
}
``` -->

```d
int complicatedComputation(int x, int y)
{
    return ...; /* ここに複雑な計算が入る */
}

void main()
{
    // コンパイラは計算の複雑度に応じて、
    // これをコンパイル時に評価するか決定します。
    int i = complicatedComputation(123, 456);

    // enum の値はコンパイル時に判明していなければならないため、
    // コンパイラにはこれをCTFEで評価する以外の選択肢がありません。
    // これが式のCTFE評価を強制する標準的イディオムです。
    enum j = complicatedComputation(123, 456);
}
```

<!-- In discussions among D users, when CTFE is mentioned it is usually in this context, where CTFE evaluation is forced because the value of an expression must be known at compile\-time. -->

式の値がコンパイル時に判明している必要があるためにCTFE評価が強制されるので、
Dユーザー間の議論ではCTFEはこのような文脈で語られることが多いです。

<!-- A different "compile\-time"
--------------------------- -->

### 異なる「コンパイル時」

<!-- Coming back to the topic at hand, though, notice that when we speak of CTFE, we speak of "virtual machines" and "bytecode interpreters". This implies that by this point, the code has gone far enough through the compilation process that it is essentially ready to be turned into runtime executable code. -->

元の話題に戻りますが、CTFE、
「バーチャルマシン」や「バイトコードインタプリター」と呼ばれるCTFEについては気をつけてください。
つまり、この時CTFEとは、
それがコンパイル過程が実行ファイルを生成する手前まで進んだときに行われるということを意味します。

<!-- In particular, this means that it has long passed the AST manipulation stage. Which in turn implies that code that can be evaluated by CTFE _can no longer make use of AST manipulation constructs_ like `static if`. In order for CTFE to work, semantic notions such as variables and memory must have been assigned to various constructs in the code, otherwise there is nothing to execute or interpret. But in the AST manipulation phase, such semantics have not yet been assigned \-\- we're still manipulating the structure of the program. -->

特に、AST操作段階はとうの昔に終わっていることを意味しています。
つまり、CTFEで評価できるコードはもはや`static if`のような**AST操作ができない**ということを意味します。
CTFEが動作するためには、
変数やメモリのような意味論的概念がコードの構成物に対して割り当てられている必要があり、
そうでなければ実行も評価もできません。
しかしAST操作フェーズでは、そのようなセマンティクスは与えられていません。
まだプログラムの構造を操作しているところです。

<!-- Thus, even though CTFE happens at "compile\-time" just as AST manipulation happens at "compile\-time", this is actually a different "compile\-time". It is much closer to "runtime" than AST manipulation, which represents a much earlier stage in the compilation process. This is why the terminology "compile\-time" is confusing: it gives the false impression that all of these features, AST manipulation and CTFE alike, are lumped together into a single, amorphous blob of time labelled "compile\-time", and that the compiler can somehow make it all magically just work, by fiat. -->

したがって、AST操作が「コンパイル時」に行われているようにCTFEも「コンパイル時」に行われていたとしても、
それは異なる「コンパイル時」です。
CTFEのそれは、コンパイル過程の速いところで行われるAST操作よりも「実行時」に近いところにあります。
これが「コンパイル時」という用語が混乱を招く理由です。
この言葉はAST操作やCTFEのような機能すべてをひとつに固めて、
はっきりしない時間のまとまりである「コンパイル時」にしてしまうことで、
コンパイラがなにか魔法のように命令に従ってくれるという誤った印象を与えます。

<!-- The point to take away from all this, is that AST manipulation constructs are applied first, and then the code may be used in CTFE later: -->

重要なのは、AST操作が最初に適用され、その後必要に応じてCTFEが使われるということです。

<!-- AST manipulation → CTFE -->

AST操作 → CTFE

<!-- The unidirectional arrow indicates that a piece of code can only move from AST manipulation to CTFE, but never the other way round. -->

この単方向の矢印はコード片がAST操作からCTFEに移動して、逆には動かないことを示しています。

<!-- Of course, in practice, this simple picture is only part of the story. To understand how it all works, it's best to look at actual code examples. So let's now take a look at a few common pitfalls that D learners often run into, and see how this principle applies in practice. -->

もちろんこれは単純化された図式です。
これらがどのように動くかを理解するためには、実際のコードを見てみるのが一番です。
というわけでD学習者が陥りがちな落とし穴と、そこに上の法則をいかに適用するかを見ていきましょう。

<!-- Case Study: Reading CTFE variables at AST manipulation time
----------------------------------------------------------- -->

### ケーススタディ：CTFE変数をAST操作時に読む

<!-- A rather common complaint that's brought up in the D forums from time to time pertains to code along these lines: -->

Dフォーラムでとくに何度も現れる苦情はこのようなコードに関するものでしょう。

<!-- ```d
int ctfeFunc(bool b)
{
    static if (b)    // <--- compile error at this line
        return 1;
    else
        return 0;
}

// N.B.: the enum forces the compiler to evaluate the function in CTFE
enum myInt = ctfeFunc(true);
``` -->

```d
int ctfeFunc(bool b)
{
    static if (b)    // <--- この行でコンパイルエラー
        return 1;
    else
        return 0;
}

// 注：enumはコンパイラに関数のCTFEによる評価を強制します
enum myInt = ctfeFunc(true);
```

<!-- If you try to compile the above code, the compiler will complain that the `static if` cannot read the value of `b` at "compile\-time". Which almost certainly elicits the reaction, "What??! What do you mean you can't read `b` at compile\-time?! Aren't you running this code in CTFE, which is by definition compile\-time, with a value of `b` that's obviously known at compile\-time?" -->

上のコードをコンパイルしようとすると、
コンパイラは`static if`は`b`の値を「コンパイル時」に読めないと主張します。
これは明らかにこんな反応を引き出すでしょう。
「は？？！`b`がコンパイル時に読めないってどういう意味だよ？！
このコードはコンパイル時であるCTFEで実行されてるんだから`b`の値はコンパイル時にわかるはずだろ？」

<!-- On the surface, this would appear to be a glaring bug in the compiler, or a glaring shortcoming in D's "compile\-time" capabilities, and/or an astonishing lack of competence on the part of the D compiler authors in failing to notice a problem in such an obvious and simple use case for CTFE. -->

表面上、これはあきらかにコンパイラのバグか、Dの「コンパイル時」機能の欠陥か、
Dコンパイラ作者の驚くべき力量不足によって明らかかつシンプルなCTFEのユースケースにおける問題を通知することに失敗しているように見えます。

<!-- If we understand what's really going on, however, we would see why the compiler rejected this code. Remember that during the process of compilation, the D compiler first creates an AST of the code, evaluating any `static if`s that may change the shape of the resulting AST. -->

しかし、何が起きているかを正しく理解すれば、なぜコンパイラがこのコードを受け付けないかわかります。
コンパイルの過程で、DコンパイラはまずコードのASTを生成し、
`static if`の評価はその結果出力されるASTの形を変えることを思い出してください。

<!-- So when the compiler first encounters the declaration of `ctfeFunc`, it scans its body and sees the `static if (b)` while building the AST for this function. If the value of `b` is `true`, then it would emit the AST tree that essentially corresponds with: -->

コンパイラが`ctfeFunc`に遭遇した時、コンパイラはその中身をスキャンし、
そしてこの関数のASTを構築している間に`static if (b)`に遭遇します。
`b`の値が`true`なら、コンパイラはだいたいこんな感じのASTを出力します。

```d
int ctfeFunc(bool b)
{
    return 1;
}
```

<!-- (Recall that in the AST manipulation stage, the false branch of a `static if` is discarded from the resulting AST, and it is as if it wasn't even there. So the `return 0` doesn't even make it past this stage.) -->

（AST操作段階で、`static if`のfalseブランチは結果のASTから除外され、
はじめから何もなかったのと同じようになることを思い出してください。
したがって`return 0`はこの後の段階に現れません。）

<!-- If the value of `b` is `false`, then it would emit the AST tree that corresponds with: -->

`b`の値が`false`ならば、以下のコードに相当するASTツリーが出力されます。

```d
int ctfeFunc(bool b)
{
    return 0;
}
```

<!-- There is a problem here, however. The value of `b` is unknown at this point. All the compiler knows about `b` at this point is that it's an identifier representing a parameter of the function. Semantics such as what values it might hold haven't been attached to it yet. In fact, the compiler hasn't even gotten to the `enum` line that calls `ctfeFunc` with an argument of `true` yet! -->

しかし、ここで問題が発生します。
`b`の値はこの時点ではわかっていないのです。
この時点で`b`についてコンパイラが知っていることはこれが関数の引数を表す識別子だということだけです。
これがどんな値を持ちうるか等のセマンティクスはまだ与えられていません。
実際、コンパイラは引数`true`が渡されている`ctfeFunc`を呼び出す`enum`のことをまだ知りません！

<!-- And even if the compiler _did_ get to the `enum` line, it wouldn't have been able to assign a value to `b`, because the function's AST is still not fully processed yet. You can't assign values to identifiers in an AST that hasn't been fully constructed yet, because the meaning of the identifiers may change once the AST is altered. It is simply too early at this point to meaningfully assign any value to `b`. The notion of assigning a value to a parameter is a semantic concept that can only be applied _after_ the AST manipulation phase. But in order to fully process the AST, the compiler needs to know the value of `b`. Yet the value of `b` cannot be known until after the AST has been processed. This is an insoluble impasse, so the compiler gives up and emits a compile error. -->

コンパイラが`enum`の行を**読んでいた**としても、今度は関数のASTがまだ完全に処理されていないため、
その値を`b`に代入することはできません。
ASTが変化すると識別子の意味も変化してしまう可能性があるので、
ASTが完全に構築されるまで値を識別子に代入することはできません。
この時点では`b`になにか意味があるかのように値を代入するのはまだ早いのです。
引数への値の代入という概念ははAST操作フェーズが適用された**後に**のみ適用できる意味論的概念です。
しかしASTを最後まで処理するには、コンパイラは`b`の値を知らなければなりません。
`b`の値はASTを最後まで処理しないとわかりません。
これは解決できない袋小路なので、コンパイラは諦めてコンパイルエラーを出力するのです。

<!-- ### Solution 1: Make it available during AST manipulation -->

#### 解決策1：AST操作中に値を使えるようにする

<!-- One possible solution to this impasse is to make the value of `b` available during the AST manipulation phase. The simplest way to do this is to turn `ctfeFunc` into a template function with `b` as a template parameter, with the corresponding change in the `enum` line to pass `true` as a template argument rather than a runtime argument: -->

解決策のひとつは`b`の値をAST操作フェーズに使えるようにすることです。
それを実現する最も単純な方法は`ctfeFunc`を`b`をテンプレート引数にとるテンプレート関数にして、
それに応じて`enum`の行が`true`を実行時引数でなくテンプレート引数として渡すように変更することです。

<!-- ```d
int ctfeFunc(bool b)()    // N.B.: the first set of parentheses enclose template parameters
{
    static if (b)    // Now this compiles without error
        return 1;
    else
        return 0;
}

enum myInt = ctfeFunc!true;
``` -->

```d
int ctfeFunc(bool b)()    // 注：最初のカッコの組にはテンプレート引数が入ります
{
    static if (b)    // エラーを出さずにコンパイルできるようになりました
        return 1;
    else
        return 0;
}

enum myInt = ctfeFunc!true;
```

<!-- Since `b` is now a template argument, its value is known during AST manipulation, and so the `static if` can be compiled without any problems. -->

`b`はテンプレート引数なので、その値はAST操作の時点で判明しており、
したがって`static if`も問題なくコンパイルできます。

<!-- ### Solution 2: Do everything during AST manipulation instead -->

#### 解決策2：すべてをAST操作で行う

<!-- The foregoing solution works, but if we consider it more carefully, we will see that we can take it further. Look at it again from the standpoint of the AST manipulation. After the AST manipulation phase, the function has essentially become: -->

先の方法もいいですが、より注意深く見てみると、もっとうまくできることに気が付きます。
AST操作の観点からもう一度考えてみましょう。
AST操作フェーズのあと、関数はこうなっているはずです。

<!-- ```d
int ctfeFunc()    // N.B.: template parameters no longer exist after AST manipulation phase
{
    return 1;     // N.B.: else branch of static if has been discarded
}
``` -->

```d
int ctfeFunc()    // 注：テンプレート引数はAST操作フェーズの後には存在しません
{
    return 1;     // 注：static ifのelseブランチは取り除かれています
}
```

<!-- This means that CTFE wasn't actually necessary to evaluate this function in the first place! We could have just as easily declared **ctfeFunc** as a template, completely evaluated in the AST manipulation phase. (And we might as well also rename it to something other than `ctfeFunc`, since it would be no longer evaluated in CTFE, and no longer even a function): -->

つまりCTFEはそもそも最初からこの関数について何も評価する必要はないのです！
**ctfeFunc**を限界までテンプレートとして宣言すると、完全にAST操作フェーズに評価されるようになります。
（これはもはやCTFEで評価されておらず、関数でもないので、
名前も`ctfeFunc`から変えたほうがいいかもしれません。）

```d
template Value(bool b)
{
    static if (b)
        enum Value = 1;
    else
        enum Value = 0;
}

enum myVal = Value!true;
```

<!-- Now `myVal` can be completely evaluated at the AST manipulation phase, and CTFE doesn't even need to be involved. -->

`myVal`は完全にAST操作フェーズに評価されるようになり、CTFEは全く関与しなくなりました。

<!-- ### Solution 3: Move everything to CTFE -->

#### 解決策3：すべてをCTFEに移す

<!-- There is another approach, however. Although the example we have given is rather trivial, in practice CTFE functions tend to be a lot more involved than a mere if\-condition over a boolean parameter. Some functions may not be amenable to be rewritten in template form. So what do we do in that case? -->

さらにもうひとつ方法があります。
この例はいささか単純ですが、実際のCTFE関数は単なるブーリアン引数のif条件より、もっと複雑のはずです。
そういったものは素直にテンプレートに書く直すのは難しそうです。
そういった場合どうすればいいのでしょうか？

<!-- The answer may surprise you: get rid of the `static if`, and replace it with a plain old "runtime" `if`, like this: -->

答えを聞いて驚かれるかもしれません。
`static if`を取り除き、普通で「実行時」の`if`に置き換えるのです。
このようにです。

<!-- ```d
int ctfeFunc(bool b)
{
    if (b)    // <\-\-\- N.B.: regular if, not static if
        return 1;
    else
        return 0;
}

// N.B.: the enum forces the compiler to evaluate the function in CTFE
enum myInt \= ctfeFunc(true);
``` -->

```d
int ctfeFunc(bool b)
{
    if (b)    // <--- 注：static ifではなく普通のifです
        return 1;
    else
        return 0;
}

// 注：enumはコンパイラにCTFEでの関数評価を強制します
enum myInt = ctfeFunc(true);
```

<!-- And, miracle of miracles, this code compiles without any error, and with the correct value for `myInt`! But wait a minute. What's going on here? How can changing `static if` to `if`, ostensibly a "runtime" construct, possibly work for a value that is needed at "compile\-time"? Is the compiler cheating and secretly turning `myInt` into a runtime computation behind our backs? -->

そして不思議なことにこれはエラーを出さずにコンパイルされ、`myInt`には正しい値が入ります！
しかしちょっと待ってください。
何が起こったのでしょう？
一見「実行時」のものに見える`if`は、「コンパイル時」に必要な値を計算するのに、
どうして`static if`から変えることができたのでしょうか？
コンパイラがずるをして、裏でこっそり`myInt`を実行時に計算するようにしてしまったのでしょうか？

<!-- Actually, inspecting the executable code with a disassembler shows that no such cheating is happening. So how does this work? -->

実際、実行ファイルのコードをディスアセンブラーで調べてみてもそのような不正は起きていません。
ならなんで動いているんでしょう？

Interleaved AST manipulation and CTFE
-------------------------------------

Let's take a close look. This time, during the AST manipulation phase, nothing much happens besides the usual construction of the AST corresponding with `ctfeFunc`. There are no `static if`s or other template\-related constructs anymore, so the resulting AST is as straightforward as it can get. Then the compiler sees the `enum` declaration and realizes that it needs to evaluate `ctfeFunc` at "compile\-time".

Here is where something interesting happens. Based on the above discussion, you may think, the compiler is still in the "AST manipulation" stage (because it hasn't fully constructed the AST for `myInt` yet), so wouldn't this fail, since `ctfeFunc` hasn't gotten to the semantic analysis phase yet? Note, however, that while it is certainly true that the AST for `myInt` hasn't been fully resolved yet (and therefore we can't read the value of `myInt` from CTFE at this point in time), the AST for `ctfeFunc`, by this point, _is_ already ready to proceed to the next stage of compilation. Or, more precisely, _the subtree of the program's AST corresponding with `ctfeFunc` is complete,_ and can be handed over to semantic analysis now.

So the D compiler, being pretty smart about these things, realizes that it can go ahead with the semantic analysis of `ctfeFunc` _independently of the fact that other parts of the program's AST, namely the declaration of `myInt`, aren't completed yet._ This works because `ctfeFunc`'s subtree of the AST can be semantically analyzed as a unit on its own, without depending on `myInt`'s subtree of the AST at all! (It would fail if `ctfeFunc` somehow depended on the value of `myInt`, though.)

Thus, the compiler applies semantic analysis to the AST of `ctfeFunc` and brings it to the point where it can be interpreted by the CTFE engine. The CTFE engine is then invoked to run `ctfeFunc` with the value `true` as its argument \-\- essentially simulating what it would have done at runtime. The return value of 1 is then handed back to the AST manipulation code that's still waiting to finish processing the AST for `myInt`, upon which the latter AST also becomes fully constructed.

Perhaps this "smart" invocation of CTFE interleaved with AST manipulation is part of what imparts some validity to the term "compile\-time" as referring to the entire process as a whole. Hopefully, though, by now you have also acquired a better understanding of why there are really (at least) two different "compile\-times": an early phase where AST manipulation happens, and a later phase with CTFE which is very much like runtime except that it just so happens to be done inside the compiler. These phases may be applied to different parts of the program's AST at different times, though with respect to each part of the AST they are _always_ in the order of AST manipulation first, and then CTFE. AST manipulation always happens on any given subtree of the AST _before_ CTFE can be applied to that subtree, and CTFE can run on a given subtree of the AST only if the entire subtree has already passed the AST manipulation phase.

This interleaving of AST manipulation and CTFE is what makes D's "compile\-time" features so powerful: you can perform arbitrarily complex computations inside CTFE (subject to certain limitations of the CTFE engine, of course), and then use the result to manipulate the AST of another part of the program. You can even have that other part of the program also pass through CTFE, and use the result of _that_ to affect the AST of a third part of the program, and so on, all as part of the compilation process. This is one of the keystones of metaprogramming in D.

Case Study: pragma(msg) and CTFE
--------------------------------

Another common complaint by D learners arises from trying to debug CTFE functions, and pertains to the "strange" way in which `pragma(msg)` behaves in CTFE.

First of all, if you're not familiar with it, `pragma(msg)` is a handy compiler feature that lets you debug certain compile\-time processes. When the `pragma(msg)` directive is processed by the compiler, the compiler outputs whatever message is specified as arguments to the `pragma`. For example:

template MyTemplate(T)
{
    pragma(msg, "instantiating MyTemplate with T=" ~ T.stringof);
    // ... insert actual code here
}

This causes the compiler to print "instantiating MyTemplate with T=int" when `MyTemplate!int` is instantiated, and to print "instantiating MyTemplate with T=float" when `MyTemplate!float` is instantiated. This can be a useful debugging tool to trace exactly what instantiations are being used in the code.

So far so good.

Complaints, however, tend to arise when people attempt to do things like this:

int ctfeFunc(int x)
{
    if (x < 100)
        return x;
    else
    {
        pragma(msg, "bad value passed in");
        return \-1;
    }
}
enum y \= ctfeFunc(50); // N.B.: enum forces CTFE on ctfeFunc

Even though the argument 50 is well within the bounds of what `ctfeFunc` can handle, the compiler persistently prints "bad value passed in". And it does the same if the argument is changed to something the function ostensibly rejects, like 101. What gives?

"Compiler bug!" some would scream.

By now, however, you should be able to guess at the answer: `pragma(msg)` is a construct that pertains to the AST manipulation phase. The compiler prints the message while it is building the AST of `ctfeFunc`, well before it even knows that it needs to invoke CTFE on it. The `pragma(msg)` is then discarded from the AST. As we have mentioned, during the AST manipulation phase the compiler has not yet attached any meaning to `if` or any value to the identifier `x`; these are seen merely as syntax nodes to be attached to the AST being built. So the `pragma(msg)` is processed without any regard to the semantics of the surrounding code \-\- said semantics haven't been attached to the AST yet! Since there are no AST manipulation constructs that would prune away the subtree containing the `pragma(msg)`, the specified message is _always_ printed regardless of what the value of `x` will be in CTFE. By the time this function gets to CTFE, the `pragma(msg)` has already been discarded from the AST, and the CTFE engine doesn't even see it.

Case Study: static if and \_\_ctfe
----------------------------------

Another common source of misunderstandings is the built\-in magic variable `__ctfe`. This variable evaluates to `true` when inside the CTFE engine, but always evaluates to `false` at runtime. It is useful for working around CTFE engine limitations when your code contains constructs that work fine at runtime, but aren't currently supported in CTFE. It can also be used for optimizing your code for the CTFE engine by taking advantage of its known performance characteristics.

As a simple example, as of this writing `std.array.appender` is generally recommended for use at runtime when you're appending a large number of items to an array. However, due to the way the current CTFE engine works, it is better to simply use the built\-in array append operator `~` when inside the CTFE engine. Doing so would reduce the memory footprint of CTFE, and probably improve compilation speed as well. So you would test the `__ctfe` variable in your code and choose the respective implementation depending on whether it is running in CTFE or at runtime.

Since `__ctfe` is, ostensibly, a "compile\-time" variable, useful only for targeting the CTFE engine, a newcomer to D may be tempted to write the code like this:

int\[\] buildArray()
{
    static if (\_\_ctfe)  // <\-\- this is line 3
    {
        // We're in CTFE: just use ~= for appending
        int\[\] result;
        foreach (i; 0 .. 1\_000\_000)
            result ~= i;
        return result;
    }
    else
    {
        // This is runtime, use appender() for faster performance
        import std.array : appender;
        auto app \= appender!(int\[\]);
        foreach (i; 0 .. 1\_000\_000)
            app.put(i);
        return app.data;
    }
}

This code, unfortunately, gets rejected by the compiler:

test.d(3): Error: variable \_\_ctfe cannot be read at compile time

which, almost certainly, elicits the response, "What?! What do you mean `__ctfe` cannot be read at compile time?! Isn't it specifically designed to work in CTFE, which is a compile\-time feature??"

Knowing what we now know, however, we can understand why this doesn't work: `static if` is a construct that pertains to the AST manipulation phase of the code, whereas `__ctfe` is clearly something specific to the later CTFE phase. At the AST manipulation phase of compilation, the compiler doesn't even know whether `buildArray` is going to be evaluated by CTFE or not. In fact, it hasn't even assigned a semantic meaning to the identifier `__ctfe` yet, because semantic analysis is not performed until the construction of the AST has been completed. Identifiers are not assigned concrete meanings until semantic analysis is done. So even though both `static if` and `__ctfe` are "compile\-time" features, the former relates to an earlier phase of compilation, and the latter to a later phase. Again, we see that conflating the two under the blanket term "compile\-time" leads to confusion.

### Solution: Just use if

The solution is simple: just replace `static if` with `if`:

int\[\] buildArray()
{
    if (\_\_ctfe)   // <\-\-\- N.B. no longer static if
    {
        // We're in CTFE: just use ~= for appending
        int\[\] result;
        foreach (i; 0 .. 1\_000\_000)
            result ~= i;
        return result;
    }
    else
    {
        // This is runtime, use appender() for faster performance
        import std.array : appender;
        auto app \= appender!(int\[\]);
        foreach (i; 0 .. 1\_000\_000)
            app.put(i);
        return app.data;
    }
}

Now `buildArray` works correctly, because the AST of this function can be fully built, analysed, and then, if necessary, passed to the CTFE engine for execution. When the CTFE engine interprets the code, it can then assign semantic meaning to `__ctfe` and take the true branch of the if\-statement. At runtime, `__ctfe` is always `false` and the false branch is always taken.

### But what of runtime performance?

One question that may still be lingering, though, is whether this "non\-static" `if`, ostensibly a runtime construct, would generate redundant code in the executable. Since `__ctfe` will always be false at runtime, it would be a waste of CPU resources to always perform an unconditional branch over the CTFE\-specific version of the code. On modern CPUs, branches can cause the instruction pipeline to stall, leading to poor performance. The CTFE\-specific part of the code would also be dead weight, taking up space in the executable and using up memory at runtime, but serving no purpose since it will never be run.

Compiling the code and examining it with a disassembler, however, shows that such fears are unfounded: the branch is elided by the compiler's code generator because the value of `__ctfe` is statically `false` outside of the CTFE engine. So the optimizer sees that the true branch of the if\-statement is dead code, and simply omits it from the generated object code. There is no performance penalty and no additional dead code in the executable.

Case Study: foreach over a type list
------------------------------------

Let's now turn to something that might trip up even experienced D coders. Consider the following function:

void func(Args...)(Args args)
{
    foreach (a; args)
    {
        static if (is(typeof(a) \== int))
        {
            pragma(msg, "is an int");
            continue;
        }
        pragma(msg, "not an int");
    }
}
void main()
{
    func(1);
}

Trick question: what is the compiler's output when this program is compiled?

If your answer is "is an int", you're wrong.

Here's the output:

is an int
not an int

Now wait a minute! Surely this is a bug? There is only one argument passed to `func`; how could it possibly have _two_ lines of output?

Let's go through the paces of what we've learned so far, and see if we can figure this out.

First, `func` is a template function, so it is not semantically analyzed until it is instantiated by a function call that specifies its argument types. This happens when the compiler is processing the `main` function, and sees the call `func(1)`. So, by IFTI (Implicit Function Template Instantiation \-\- the process of inferring the template arguments to a template function by looking at the types of the runtime arguments that are passed to it), the compiler assigns `Args` to be the single\-member sequence `(int)`.

That is, the function call is translated as:

func!(int)(1);

This causes the instantiation of `func`, which causes the compiler to build an AST for this particular instantiation based on the template body \-\- i.e., it enters the AST manipulation phase for the (copy of the) function body.

### Automatic unrolling

There is a `foreach` over `args`. There's a tricky bit involved here, in that this `foreach` isn't just any `foreach` loop; it is a loop over variadic arguments. Such loops are treated specially in D: they are automatically unrolled. In AST terms, this means that the compiler will generate n copies of the AST for the loop body, once per iteration. Note also that this is done at the AST manipulation phase; _there is no CTFE involved here_. This kind of `foreach` loop is different from the usual "runtime" `foreach`.

Then the compiler processes the loop body, and sees `static if`. Since the condition is true (the current element being looped over, which is also the only argument to the function, is an `int` with a value of 1), the compiler expands the `true` branch of the `static if`.

Then it sees the `pragma(msg)`, and emits the message "is an int".

Following that, it sees `continue`. And here's the important point: since we are in AST manipulation phase, `continue` is just another syntax node to be attached to the AST being built. The `continue` is not interpreted by the AST manipulation phase!

And so, moving on to the next item in the loop body, the AST manipulation code sees another `pragma(msg)` and outputs "not an int".

It is important to note here, and we repeat for emphasis, that:

1.  CTFE is _not involved_ here; the loop unrolling happens in the AST manipulation phase, not in CTFE;
2.  the `continue` is not interpreted by the AST manipulation phase, but is left in the AST to be translated into code later on.

### foreach over a type list does NOT interpret break and continue

This last point is worth elaborating on, because even advanced D users may be misled to think that foreach over a type list interprets `break` and `continue` specially, i.e., during the unrolling of the loop. The next code snippet illustrates this point:

import std.stdio;
void func(Args...)(Args args)
{
    foreach (arg; args)    // N.B.: this is foreach over a type list
    {
        static if (is(typeof(arg) \== int))
            continue;

        writeln(arg);

        static if (is(typeof(arg) \== string))
            break;

        writeln("Got to end of loop body with ", arg);
    }
}
void main()
{
    func(1, "abc", 3.14159);
}

What do you think is the output of this program? (Not a trick question.)

Here's the output:

abc

This seems to confirm our initial hypothesis that `continue` and `break` are interpreted by the foreach, such that the first argument, which is an `int`, causes the rest of the loop body to be skipped until the next iteration, and the second argument, which is a `string`, breaks out of the loop itself and thus causes the loop unrolling to be interrupted.

However, this is not true, as can be proven by replacing the last `writeln` with a `static assert`:

import std.stdio;
void func(Args...)(Args args)
{
    foreach (arg; args)    // N.B.: this is foreach over a type list
    {
        static if (is(typeof(arg) \== int))
            continue;

        writeln(arg);

        static if (is(typeof(arg) \== string))
            break;

        // This should be true, right?
        // Since the string case has broken out of the loop?
        static assert(!is(typeof(arg) \== string));  // line 16
    }
}
void main()
{
    func(1, "abc", 3.14159);
}

Here is what the compiler has to say:

test.d(16): Error: static assert  (!true) is false
test.d(21):        instantiated from here: func!(int, string, double)

What's going on here?

It seems counterintuitive, but it's actually very simple, and should be readily understandable now that we have a clearer idea of the role of AST manipulation. Simply put, the foreach does _not_ interpret `continue` and `break` at all during the AST manipulation phase. They are treated merely as nodes in the AST being constructed, and thus the compiler continues process the rest of the loop body. Thus, the `static assert` is evaluated _in all three iterations of the loop_, including the second iteration where it fails because `typeof(arg) == string`.

### What foreach over a type list actually does

But if this is the case, then why does the original loop appear to obey `continue` and `break`? To answer that, let's take a look at the actual AST as printed by the D compiler `dmd` (with additional comments added by yours truly):

@safe void func(int \_param\_0, string \_param\_1, double \_param\_2)
{
        import std.stdio;
        /\*unrolled\*/ {
                {
                        int arg \= \_param\_0;
                        continue;
                        writeln(arg);  // N.B.: NOT skipped!
                }
                {
                        string arg \= \_param\_1;
                        writeln(arg);
                        break;
                }
                {
                        // N.B.: this iteration is NOT skipped!
                        double arg \= \_param\_2;
                        writeln(arg);  // N.B.: NOT skipped!
                }
        }
}

During code generation (which is another phase that comes after AST manipulation), however, the compiler's code generator notices that the first loop iteration begins with an unconditional branch to the next iteration. As such, the rest of the first iteration is dead code, and can be elided altogether. Similarly, in the second loop iteration, the code generator notices that there is an unconditional branch to the end of the loop, so the rest of that iteration is also dead code and can be elided. Lastly, the third loop iteration is never reached \-\- it is dead code, and gets elided as well.

After these elisions, what's left is:

void func!(int, string, double)(int \_\_arg0, string \_\_arg1, double \_\_arg2)
{
    writeln(\_\_arg1);
}

which is what produced the observed output.

In other words, it wasn't the foreach over the type list that pruned the code following the `break` and the `continue`; it's actually the compiler's optimizer, which is part of the code generator, getting rid of dead code so that the final executable doesn't waste space on what will never be executed.

### Possible solutions

The simplest solution to the conundrum posed by the original code in this case study is to use an `else` clause with the `static if`:

void func(Args...)(Args args)
{
    foreach (a; args)
    {
        static if (is(typeof(a) \== int))
        {
            pragma(msg, "is an int");
            continue;
        }
        else    // <\-\-\-\- N.B.: else clause
            pragma(msg, "not an int");
    }
}
void main()
{
    func(1);
}

This ensures that the second `pragma(msg)` is correctly elided from the generated AST when the condition of the `static if` is false.

Summary
-------

In summary, we learned that there are (at least) two distinct stages of compilation that a piece of D code passes through:

1.  The AST manipulation phase, where templates are expanded and `static if` is processed. In this phase, we are manipulating the structure of the code itself in the form of its AST (Abstract Syntax Tree). Semantic concepts such as variables, the meaning of control\-flow constructs like `break` or `continue` do not apply in this stage.
2.  The semantic analysis phase, where meaning is attached to the AST. Notions such as variables, arguments, and control\-flow are applied here. AST manipulation constructs can no longer be applied at this point. CTFE (Compile\-Time Function Evaluation) can only be used for code that has already passed the AST manipulation phase and the semantic analysis phase. By the time the CTFE engine sees the code, anything involving templates, `static if`, or any of the other AST manipulation features has already been processed, and the CTFE engine does not see the original AST manipulation constructs anymore.

Each piece of code passes through the AST manipulation phase and the semantic analysis phase, _in that order_, and never the other way around. Consequently, CTFE can only run on a piece of code _after_ it has finished its AST manipulation phase.

Nevertheless, it is possible for _another_ part of the program to still be in the AST manipulation phase, depending on a value computed by a piece of code that has already passed the AST manipulation phase and is ready to be interpreted by the CTFE engine. This interleaving of AST manipulation and CTFE is what makes D's "compile\-time" features so powerful. But it is subject to the condition that the code running in CTFE must itself have already passed its AST manipulation phase; it cannot depend on anything that hasn't reached the semantic analysis phase yet.

Mixing up AST manipulation constructs with CTFE\-specific semantic notions is what causes most of the confusion and frustrations with D's "compile\-time" features.
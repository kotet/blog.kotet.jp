---
title: "ロスト・イン・トランスレーション：カプセル化【翻訳】"
date: 2018-12-24
tags:
- dlang
- tech
- translation
- d_blog
- advent_calendar
---

これは
[Lost in Translation: Encapsulation – The D Blog](https://dlang.org/blog/2018/11/06/lost-in-translation-encapsulation/)
を
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
翻訳した
[D言語 Advent Calendar 2018 - Qiita](https://qiita.com/advent-calendar/2018/dlang)
24日目の記事です。

誤訳等あれば気軽に
[Pull requestを投げてください](https://github.com/kotet/blog.kotet.jp)。

---

<!-- > I first learned programming in BASIC. Outgrew it, and switched to Fortran. Amusingly, my early Fortran code looked just like BASIC. My early C code looked like Fortran. My early C++ code looked like C. – [Walter Bright, the creator of D](http://walterbright.com/) -->

> 私はプログラミングをBASICで学びました。
> そこで成長し、そしてFortranに移りました。
> 興味深いことに、私の初期のFortranコードはBASICのような見た目でした。
> 私がCを書き始めたときのコードはFortranのような見た目でした。
> 私がC++を書き始めたときのコードはCのような見た目でした。
>  – [Walter Bright、Dの創始者](http://walterbright.com/)

<!-- Programming in a language is not the same as _thinking_ in that language. A natural side effect of experience with one programming language is that we view other languages through the prism of its features and idioms. Languages in the same family may look and feel similar, but there are guaranteed to be subtle differences that, when not accounted for, can lead to compiler errors, bugs, and missed opportunities. Even when good docs, books, and other materials are available, most misunderstandings are only going to be solved through trial\-and\-error. -->

ある言語でプログラミングをすることはその言語で**考えること**とは異なります。
あるプログラミング言語での経験による自然な副作用として、
我々は他の言語の機能やイディオムを色眼鏡を通して見ることになります。
同じファミリーに属する言語からは同じような印象を受けますが、
そこにはコンパイルエラーやバグ、機会損失につながることのないほど僅かながら確実に違いがあります。
優れたドキュメント、書籍、その他さまざまなものが利用できるにもかかわらず、
多くの誤解は試行錯誤によって解決されてしまいます。

<!-- D programmers come from a variety of programming backgrounds, C\-family languages perhaps being the most common among them. Understanding the differences and how familiar features are tailored to D can open the door to more possibilities for organizing a code base, and designing and implementing an API. This article is the first of a few that will examine D features that can be overlooked or misunderstood by those experienced in similar languages. -->

DプログラマはC系の言語をはじめさまざまな言語からやってきています。
それらとの違いと、それをどう使いこなすかを理解することで、
D言語においてコードベースの管理や、APIの設計と実装について多くの可能性が開かれます。
この記事は、似たような言語の経験がもとで見過ごされ誤解されるDの機能について詳説する最初の記事です。

<!-- We’re starting with a look at a particular feature that’s common among languages that support Object\-Oriented Programming (OOP). There’s one aspect in particular of the D implementation that experienced programmers are sure they already fully understand and are often surprised to later learn they don’t. -->

最初に見ていくのはオブジェクト指向プログラミング（OOP）をサポートする言語においては一般的な機能です。
ここには経験豊富なプログラマーが既に完全に理解しているところと、知らなくて驚くところがあります。

<!-- Encapsulation
------------- -->

### カプセル化

<!-- Most readers will already be familiar with the concept of encapsulation, but I want to make sure we’re on the same page. For the purpose of this article, I’m talking about encapsulation in the form of separating interface from implementation. Some people tend to think of it strictly as it relates to object\-oriented programming, but it’s a concept that’s more broad than that. Consider this C code: -->

読者の多くはカプセル化の概念についてよく知っているでしょうが、ちゃんと読んでほしいところです。
この記事では、カプセル化についてインターフェースの実装からの分離の形で考えます。
これはオブジェクト指向プログラミングと強く結びついたものだ、
というふうに考えがちな人もいるでしょうが、実際はそれよりも幅の広いものです。
こちらのCのコードについて考えてみます。

```c
#include <stdio.h>

static size_t s_count;

void print_message(const char* msg) {

    puts(msg);

    s_count++;

}

size_t num_prints() { return s_count; }
```

<!-- In C, functions and global variables decorated with `static` become private to the _translation unit_ (i.e. the source file along with any headers brought in via `#include`) in which they are declared. Non\-static declarations are publicly accessible, usually provided in header files that lay out the public API for clients to use. Static functions and variables are used to hide implementation details from the public API. -->

Cにおいて、関数と`static`のついたグローバル変数はそれが宣言された**翻訳単位**
（例：`#include`で多数のヘッダーと関連しているソースファイル）からプライベートになります。
クライアントの使うパブリックなAPIが置かれるヘッダーファイルに書かれることの多い非静的の宣言は、
パブリックにアクセス可能です。
静的な関数と変数はパブリックAPIから実装の詳細を隠すために使われます。

<!-- Encapsulation in C is a minimal approach. C++ supports the same feature, but it also has anonymous namespaces that can encapsulate type definitions in addition to declarations. Like Java, C#, and other languages that support OOP, C++ also has _access modifiers_ (alternatively known as access specifiers, protection attributes, visibility attributes) which can be applied to `class` and `struct` member declarations. -->

Cにおけるカプセル化はミニマルなアプローチです。
C++も同じ機能をサポートしていますが、
それは宣言に加えて型定義もカプセル化できる匿名名前空間でもあります。
JavaやC#、その他OOPをサポートする言語のように、
C++にも`class`や`struct`のメンバの宣言に適用できる**アクセス修飾子**
（access specifier、protection attribute、visibility attributeとも呼ばれます）があります。

<!-- C++ supports the following three access modifiers, common among OOP languages: -->

C++ には、OOP言語では一般的な以下の3つのアクセス修飾子があります。

<!-- *   `public` – accessible to the world
*   `private` – accessible only within the class
*   `protected` – accessible only within the class and its derived classes -->

- `public` – 世界全体からアクセス可能
- `private` – クラスの中でのみアクセス可能
- `protected` – クラスとそれを継承したクラスの中からのみアクセス可能

<!-- An experienced Java programmer might raise a hand to say, “Um, excuse me. That’s not a complete definition of `protected`.” That’s because in Java, it looks like this: -->

Javaを経験したプログラマーは手を挙げてこう言うかもしれません。
「あー、ちょっといいですか。これは`protected`の完璧な定義ではありません。」
Javaではこのようになっているからです。

<!-- *   `protected` – accessible within the class, its derived classes, and classes in the same package. -->

- `protected` – クラス、継承したクラス、同じパッケージ内のクラスの中からのみアクセス可能

<!-- Every class in Java belongs to a package, so it makes sense to factor packages into the equation. Then there’s this: -->

Javaにおいて各クラスはパッケージに属しているため、
ここにはパッケージが関わっているとしたほうが自然です。
したがってこのようになります。

<!-- *   _package\-private_ (not a keyword) – accessible within the class and classes in the same package. -->

- *package-private*（キーワードではありません） – クラス、継承したクラス、同じパッケージ内のクラスの中からのみアクセス可能

<!-- This is the default access level in Java when no access modifier is specified. This combined with `protected` make packages a tool for encapsulation beyond classes in Java. -->

これはJavaにおいてアクセス修飾子を指定しなかった場合のデフォルトのアクセスレベルです。
Javaにおいてパッケージをクラスを超えたカプセル化の道具にする`protected`と組合わさります。

<!-- Similarly, C# has assemblies, [which MSDN defines as](https://msdn.microsoft.com/en-us/library/ms973231.aspx) “a collection of types and resources that forms a logical unit of functionality”. In C#, the meaning of `protected` is identical to that of C++, but the language has two additional forms of protection that relate to assemblies, and that are analogous to Java’s `protected` and package\-private. -->

同じように、C#にはアセンブリ、[MSDNによると](https://msdn.microsoft.com/en-us/library/ms973231.aspx)「型の集合であり、論理機能単位をつくるリソース」があります。
C#では、`protected`の意味はC++のそれと同じですが、
この言語ではそれに加えてアセンブリに関する、
Javaの`protected`やpackage-privateと似ている2つの形態があります。

<!-- *   `internal` – accessible within the class and classes in the same assembly.
*   `protected internal` – accessible within the class, its derived classes, and classes in the same assembly. -->

*   `internal` – クラスと同じアセンブリ内のクラス内でのみアクセス可能
*   `protected internal` – クラス、継承したクラス、同じアセンブリ内のクラス内からのみアクセス可能

<!-- Examining encapsulation in other programming languages will continue to turn up similarities and differences. Common encapsulation idioms are generally adapted to language\-specific features. The fundamental concept remains the same, but the scope and implementation vary. So it should come as no surprise that D also approaches encapsulation in its own, language\-specific manner. -->

他のプログラミング言語のカプセル化について調べることでその類似点と相違点を見つけることができます。
一般的なカプセル化のイディオムは言語特有の機能として存在します。
基本となる概念は同じですが、そのスコープと実装はさまざまです。
なのでDに独自のカプセル化アプローチ、言語特有のやり方があったとしても驚くことではありません。

<!-- Modules
------- -->

### モジュール

<!-- The foundation of D’s approach to encapsulation [is the module](https://dlang.org/spec/module.html). Consider this D version of the C snippet from above: -->

Dのカプセル化のアプローチの基礎となるのは[モジュールです](https://dlang.org/spec/module.html)。
上記のCコードのDバージョンを考えてみましょう。

```d
module mymod;

private size_t _count;

void printMessage(string msg) {

    import std.stdio : writeln;

    writeln(msg);

    _count++;

}

size_t numPrints() { return _count; }
```

<!-- In D, access modifiers can apply to module\-scope declarations, not just `class` and `struct` members. `_count` is `private`, meaning it is not visible outside of the module. `printMessage` and `numPrints` have no access modifiers; they are `public` by default, making them visible and accessible outside of the module. Both functions could have been annotated with the keyword `public`. -->

Dにおいて、アクセス修飾子は`class`や`struct`のメンバのみならず、
モジュールスコープの宣言にも適用できます。
`_count`は`private`、つまりこのモジュールの外からは見えません。
`printMessage`と`numPrints`にはアクセス修飾子がついていません。
これらはデフォルトで`public`であり、モジュールの外から見えて、アクセス可能です。
両関数はキーワード`public`で修飾することもできます。

<!-- _Note that imports in module scope are `private` by default, meaning the symbols in the imported modules are not visible outside the module, and local imports, as in the example, are never visible outside of their parent scope._ -->

モジュールスコープでのimportはデフォルトで`private`であり、
インポートされたモジュールのシンボルはインポートしたモジュールの外からは見えません。
またこの例で使われているようなローカルインポートは絶対に親スコープから見ることができません。

<!-- Alternative syntaxes are supported, giving more flexibility to the layout of a module. For example, there’s C++ style: -->

これ以外の構文もサポートされており、モジュールのレイアウトにフレキシビリティを提供しています。
たとえば、C++スタイル構文もあります。

<!-- ```d
module mymod;

// Everything below this is private until either another

// protection attribute or the end of file is encountered.

private:

    size\_t \_count;

// Turn public back on

public:

    void printMessage(string msg) {

     import std.stdio : writeln;

     writeln(msg);

     \_count++;

    }

    size\_t numPrints() { return \_count; }
``` -->

```d
module mymod;

// これより下にあるすべては他の保護属性が現れるか

// ファイルの終わりまでprivateになります

private:

    size_t _count;

// publicに戻します

public:

    void printMessage(string msg) {

     import std.stdio : writeln;

     writeln(msg);

     _count++;

    }

    size_t numPrints() { return _count; }
```

<!-- And this: -->

このようにもできます。

<!-- ```d
module mymod;

private {

    // Everything declared within these braces is private.

    size\_t \_count;

}

// The functions are still public by default

void printMessage(string msg) {

    import std.stdio : writeln;

    writeln(msg);

    \_count++;

}

size\_t numPrints() { return \_count; }
``` -->

```d
module mymod;

private {

    // このブレースのなかで宣言されるものはすべてprivateになります

    size_t _count;

}

// この関数はデフォルトのpublicのままです

void printMessage(string msg) {

    import std.stdio : writeln;

    writeln(msg);

    _count++;

}

size_t numPrints() { return _count; }
```

<!-- Modules can belong to packages. A package is a way to group related modules together. In practice, the source files corresponding to each module should be grouped together in the same directory on disk. Then, in the source file, each directory becomes part of the module declaration: -->

モジュールはパッケージに属することができます。
パッケージは関連するモジュールをまとめる手段です。
各モジュールに対応するソースファイルは実際にディスク上の同じディパッケージとモジュールについては将来の記事で詳しく取り扱います。レクトリにある必要があります。
ソースファイルのなかで、ディレクトリはモジュール宣言の一部になります。

```d
// mypack/amodule.d

mypack.amodule;

// mypack/subpack/anothermodule.d

mypack.subpack.anothermodule;
```

<!-- _Note that it’s possible to have package names that don’t correspond to directories and module names that don’t correspond to files, but it’s bad practice to do so. A deep dive into packages and modules will have to wait for a future post._ -->

ディレクトリと対応しないパッケージ名をつけたり、
ファイルと対応しないモジュール名をつけることも可能ですが、それはバッドプラクティスです。
パッケージとモジュールについては将来の記事で詳しく取り扱います。

<!-- `mymod` does not belong to a package, as no packages were included in the module declaration. Inside `printMessage`, the function `writeln` is imported from the `stdio` module, which belongs to the `std` package. Packages have no special properties in D and primarily serve as namespaces, but they are a common part of the codescape. -->

モジュール宣言にパッケージが含まれていないため、`mymod`はパッケージに属しません。
`printMessage`のなかで、関数`writeln`は`stdio`モジュールからインポートされていますが、
`stdio`モジュールは`std`パッケージに属しています。
Dにおいてパッケージは特殊な機能を持っているわけではなく主に名前空間として機能しますが、
but they are a common part of the codescape.
（訳注：ここよく意味がわからなかった。codescapeはなにかのスペルミス？）

<!-- In addition to `public` and `private`, the `package` access modifier can be applied to module\-scope declarations to make them visible only within modules in the same package. -->

モジュールスコープ宣言には`public`と`private`に加えて、`package`アクセス修飾子も適用できます。
同じパッケージの中でのみ見えるようになります。

<!-- Consider the following example. There are three modules in three files (only one module per file is allowed), each belonging to the same root package. -->

以下の例について考えてみます。
3つのファイルの中に3つのモジュールがあり（ファイルあたり1モジュールだけが存在できます）、
それぞれ同じrootパッケージに属しています。

```d
// src/rootpack/subpack1/mod2.d

module rootpack.subpack1.mod2;

import std.stdio;

package void sayHello() {

    writeln("Hello!");

}

// src/rootpack/subpack1/mod1.d

module rootpack.subpack1.mod1;

import rootpack.subpack1.mod2;

class Speaker {

    this() { sayHello(); }

}

// src/rootpack/app.d

module rootpack.app;

import rootpack.subpack1.mod1;

void main() {

    auto speaker = new Speaker;

}
```

<!-- Compile this with the following command line: -->

これを以下のコマンドでコンパイルします。

```console
cd src

dmd -i rootpack/app.d
```

<!-- _The `-i` switch tells the compiler to automatically compile and link imported modules (excluding those in the standard library namespaces `core` and `std`). Without it, each module would have to be passed on the command line, else they wouldn’t be compiled and linked._ -->

`-i`スイッチはインポートしたモジュールを自動的にコンパイルしてリンクするようコンパイラに指示します
（標準ライブラリの名前空間`core`と`std`を除く）。
これがない場合、各モジュールはコマンドラインで渡されなければならず、
渡されなかった場合それはコンパイルされないしリンクもされません。

<!-- The class `Speaker` has access to `sayHello` because they belong to modules that are in the same package. Now imagine we do a refactor and we decide that it could be useful to have access to `sayHello` throughout the `rootpack` package. D provides the means to make that happen by allowing the `package` attribute to be parameterized with the fully\-qualified name (FQN) of a package. So we can change the declaration of `sayHello` like so: -->

クラス`Speaker`は同じパッケージのモジュールに属しているため`sayHello`へのアクセス権を持ちます。
リファクタリングの結果`sayHello`が`rootpack`パッケージ全体からアクセスできると便利だ、
と考えた場合を想像してみましょう。
Dはそのための手段としてパッケージの完全修飾名（Fully-qualified name、FQN）
を使いパラメタライズされた`package`属性を提供します。
これを使うと`sayHello`の宣言をこのように変更できます。

```d
package(rootpack) void sayHello() {

    writeln("Hello!");

}
```

<!-- Now all modules in `rootpack` and _all modules in packages that descend from `rootpack`_ will have access to `sayHello`. Don’t overlook that last part. A parameter to the `package` attribute is saying that a package and all of its descendants can access this symbol. It may sound overly broad, but it isn’t. -->

これで`rootpack`に属するモジュールと
**`rootpack`以下のパッケージに属するすべてのモジュール**は`sayHello`へのアクセス権を持ちます。
後者を見落とさないでください。
`package`属性のパラメータはパッケージとそのすべての子孫がこのシンボルにアクセスできると言っています。
あまりに幅広すぎると思うかもしれませんが、そうではありません。

<!-- For one thing, only a package that is a direct ancestor of the module’s parent package can be used as a parameter. Consider a module `rootpack.subpack.subsub.mymod`. That name contains all of the packages that are legal parameters to the `package` attribute in `mymod.d`, namely `rootpack`, `subpack`, and `subsub`. So we can say the following about symbols declared in `mymod`: -->

ひとつには、親パッケージの先祖だけがパラメータに使えるということです。
`rootpack.subpack.subsub.mymod`というモジュールをもとに考えてみます。
この名前は`mymod.d`内の`package`属性において合法なすべてのパラメータを含んでいます。
つまり、`rootpack`、`subpack`、`subsub`です。
`mymod`内で宣言されたシンボルについて以下の属性が付けられます。

<!-- *   `package` – visible only to modules in the parent package of `mymod`, i.e. the `subsub` package.
*   `package(subsub)` – visible to modules in the `subsub` package and modules in all packages descending from `subsub`.
*   `package(subpack)` – visible to modules in the `subpack` package and modules in all packages descending from `subpack`.
*   `package(rootpack`) – visible to modules in the `rootpack` package and modules in all packages descending from `rootpack`. -->

- `package` – `subsub`パッケージのような、`mymod`の親パッケージ内のモジュールからのみ可視。
- `package(subsub)` – `subsub`パッケージと`subsub`のすべての子孫パッケージ内のモジュールから可視。
- `package(subpack)` – `subpack`パッケージと`subpack`のすべての子孫パッケージ内のモジュールから可視。
- `package(rootpack)` – `rootpack`パッケージと`rootpack`のすべての子孫パッケージ内のモジュールから可視。

<!-- This feature makes packages another tool for encapsulation, allowing symbols to be hidden from the outside world but visible and accessible in specific subtrees of a package hierarchy. In practice, there are probably few cases where expanding access to a broad range of packages in an entire subtree is desirable. -->

この機能によりパッケージはカプセル化のツールになり、外の世界からシンボルを隠し、
しかしパッケージヒエラルキーの特定のサブツリーからのみ可視かつアクセス可能にできるようになります。
実際には、アクセス権をサブツリー全体にひろげるのが望ましいというケースは多くありません。

<!-- It’s common to see parameterized package protection in situations where a package exposes a common public interface and hides implementations in one or more subpackages, such as a `graphics` package with subpackages containing implementations for DirectX, Metal, OpenGL, and Vulkan. Here, D’s access modifiers allow for three levels of encapsulation: -->

たとえば`graphics`パッケージと、
DirextX、Metal、OpenGL、Vulkanなどのための実装を含むサブパッケージのように、
パブリックなインターフェースを公開し、
なおかつ1つ以上のサブパッケージ内にある実装を隠したいというシチュエーションでは、
パラメタライズされたパッケージ保護は一般的に見られます。
Dのアクセス修飾子は3段階のカプセル化を可能にします。

<!-- *   the `graphics` package as a whole
*   each subpackage containing the implementations
*   individual modules in each package -->

- 全体は`graphics`パッケージ
- 各サブパッケージは実装を含む
- 各パッケージは独立したモジュールになっている

<!-- Notice that I didn’t include `class` or `struct` types as a fourth level. The next section explains why. -->

私は4段階目として`class`や`struct`を入れていません。
次のセクションで理由を説明します。

<!-- Classes and structs
------------------- -->

### クラスと構造体

<!-- Now we come to the motivation for this article. I can’t recall ever seeing anyone [come to the D forums](https://forum.dlang.org/) professing surprise about package protection, but the behavior of access modifiers in classes and structs is something that pops up now and then, largely because of expectations derived from experience in other languages. -->

この記事で書きたかったところにやってきました。
どれほどの人が
[Dフォーラムに来て](https://forum.dlang.org/)
パッケージ保護について驚きを表明したかもはや覚えていませんが、
クラスと構造体の中のアクセス修飾子の振る舞いは、主に他の言語での経験から生じる期待のために、
唐突に飛び出してきたように感じるものです。

<!-- Classes and structs use the same access modifiers as modules: `public`, `package`, `package(some.pack)`, and `private`. The `protected` attribute can only be used in classes, as inheritance is not supported for structs (nor for modules, which aren’t even objects). `public`, `package`, and `package(some.pack)` behave exactly as they do at the module level. The thing that surprises some people is that `private` also behaves the same way. -->

クラスと構造体はモジュールのそれと同じアクセス修飾子を使います。
`public`、`package`、`package(some.pack)`、`private`です。
構造体が継承をサポートしていないため（モジュールもオブジェクトではないため）、
`protected`属性はクラスでのみ使えます。
`public`、`package`、`package(some.pack)`はモジュールレベルのそれと同様に振る舞います。
驚く人がいるのは`private`を同じように使ったときです。

```d
import std.stdio;

class C {

    private int x;

}

void main() {

    C c = new C();

    c.x = 10;

    writeln(c.x);

}
```

<!-- _[Run this example online](https://run.dlang.io/is/L7geN6)_ -->

_[この例をオンラインで実行](https://run.dlang.io/is/L7geN6)_

<!-- Snippets like this are posted in the forums now and again by people exploring D, accompanying a question along the lines of, “Why does this compile?” (and sometimes, “I think I’ve found a bug!”). This is an example of where experience can cloud expectations. Everyone knows what `private` means, so it’s not something most people bother to look up in the language docs. However, [those who do would find this](https://dlang.org/spec/attribute.html#visibility_attributes): -->

Dについて調べる人によってこのようなコード片が、
「なぜこれがコンパイルされるのですか？」
（ときに「バグを見つけたかもしれません！」）という質問とともに度々投稿されます。
これは経験が予想を誤らせる例です。
`private`の意味はみんな知っているので、
多くの人が言語仕様のドキュメントを読んで悩むようなものではないはずです。
しかし、[ドキュメントを読んだ人はこのような記述を見つけます](https://dlang.org/spec/attribute.html#visibility_attributes)。

<!-- > Symbols with private visibility can only be accessed from within the same module. -->

> privateのついたシンボルは同じモジュール内からのみアクセスできます。

<!-- `private` in D always means _private to the module_. The module is the lowest level of encapsulation. It’s easy to understand why some experience an initial resistance to this, that it breaks encapsulation, but the intent behind the design is to _strengthen_ encapsulation. It’s inspired by the C++ `friend` feature. -->

Dにおける`private`は常に**モジュールのprivate**を意味しています。
モジュールはカプセル化の最低段階です。
これがカプセル化を破っていると言われる理由を理解することもできますが、
これはカプセル化を**強化する**ためのものです。
これはC++の`friend`機能からインスパイアされたものです。

<!-- Having implemented and maintained a C++ compiler for many years, Walter understood the need for a feature like `friend`, but felt that it wasn’t the best way to go about it. -->

C++コンパイラを長年実装、メンテナンスしてきたことにより、
Walterは`friend`のような機能の必要性を理解しましたが、
これが目的を達成する最善の方法ではないとも思いました。

<!-- > Being able to declare a “friend” that is somewhere in some other file runs against notions of encapsulation. -->

> どこか別のファイルで走る"friend"を宣言できるようにすることはカプセル化と逆行しています。

<!-- An alternative is to take a Java\-like approach of one class per module, but he felt that was too restrictive. -->

他の方法としてモジュールあたり1つのクラスというJava風のアプローチがありますが、
彼はこれを厳しすぎると思いました。

<!-- > One may desire a set of closely interrelated classes that encapsulate a concept, and those should go into a module. -->

> 概念をカプセル化する相互に強く接続されたクラスが必要とされていて、それはモジュールに入るべきです。

<!-- So the way to view a module in D is not just as a single source file, but as a unit of encapsulation. It can contain free functions, classes, and structs, all operating on the same data declared in module scope and class scope. The public interface is still protected from changes to the private implementation inside the module. Along those same lines, `protected` class members are accessible not just in derived classes, but also in the module. -->

Dにとってモジュールは単なる1つのソースファイルではなく、カプセル化の1ユニットです。
関数、クラス、構造体がその中に含まれ、
そのすべてがモジュールスコープとクラススコープで宣言された同じデータを操作できます。
しかしやはり、パブリックなインターフェースはモジュール内のプライベートな実装から保護されています。
同様に、`protected`なクラスメンバは継承先クラスからアクセス可能なだけでなく、
モジュール内からもアクセス可能です。

<!-- Sometimes though, there really is a benefit to denying access to private members in a module. The bigger a module becomes, the more of a burden it is to maintain, especially when it’s being maintained by a team. Every place a `private` member of a class is accessed in a module means more places to update when a change is made, thereby increasing the maintenance burden. The language provides the means to alleviate the burden in the form of [the special _package module_](https://dlang.org/spec/module.html#package-module). -->

そうはいっても、モジュール内からのプライベートなメンバのアクセスを禁止する利点も存在します。
大きなモジュールは、特にそれをチームでメンテしている場合、メンテする負担が大きくなってきます。
どのクラスの`private`メンバもモジュール内からアクセスされるということは、
変化を起こしうる場所が増えるということであり、そのためメンテナンスの負担を増やします。
この言語は[特殊な**パッケージモジュール**](https://dlang.org/spec/module.html#package-module)
の形で負担を軽減する手段を提供しています。

<!-- In some cases, we don’t want to require the user to import multiple modules individually. Splitting a large module into smaller ones is one of those cases. Consider the following file tree: -->

時に、ユーザーに複数のモジュールを別々にインポートする手間をかけさせたくない、
という状況があります。
大きなモジュールを小さく分割した時などはその一例です。
以下のようなファイルツリーについて考えてみます。

```
-- mypack

---- mod1.d

---- mod2.d
```

<!-- We have two modules in a package called `mypack`. Let’s say that `mod1.d` has grown extremely large and we’re starting to worry about maintaining it. For one, we want to ensure that private members aren’t manipulated outside of class declarations with hundreds or thousands of lines in between. We want to split the module into smaller ones, but at the same time we don’t want to break user code. Currently, users can get at the module’s symbols by importing it with `import mypack.mod1`. We want that to continue to work. Here’s how we do it: -->

`mypack`と呼ばれるパッケージに2つのモジュールがあります。
`mod1.d`が非常に大きく成長してしまいメンテナンスできるか心配になってきたとします。
プライベートなメンバが、クラスの宣言の外、何百行、
何千行とあるなかから操作されていないことを確実にしておきたいです。
モジュールをもっと小さくしたいですが、
それと同時にユーザーコードを破壊するようなこともしたくありません。
現在、ユーザーはモジュールのシンボルを`import mypack.mod1`とインポートできるようになっています。
これが動作し続けるようにしたいのです。
以下が現在の状況です。

```
-- mypack

---- mod1

------ package.d

------ split1.d

------ split2.d

---- mod2.d
```

<!-- We’ve split `mod1.d` into two new modules and put them in a package named `mod1`. We’ve also created a special `package.d` file, which looks like this: -->

`mod1.d`を新しい2つのモジュールに分割し、`mod1`という名前のパッケージに配置しました。
ここで以下のような`package.d`という特殊なファイルも作っています。

```d
module mypack.mod1;

public import mypack.mod1.split1,

   mypack.mod1.split2;
```

<!-- When the compiler sees `package.d`, it knows to treat it specially. Users will be able to continue using `import mypack.mod1` without ever caring that it’s now split into two modules in a new package. The key is the module declaration at the top of `package.d`. It’s telling the compiler to treat this package as the module `mod1`. And instead of automatically importing all modules in the package, the requirement to list them as public imports in `package.d` allows more freedom in implementing the package. Sometimes, you might want to require the user to explicitly import a module even when a `package.d` is present. -->

コンパイラが`package.d`を見つけると、それは特別に扱われます。
ユーザーはモジュールが新しいパッケージ内の2つのモジュールに分割されたことを気にすること無く
`import mypack.mod1`を使い続けられます。
カギとなるのは`package.d`の上の部分のモジュール宣言です。
この宣言は、このパッケージをモジュール`mod1`として扱うようコンパイラに指示します。
そしてモジュール内のすべてのパッケージは自動的にインポートされず、
かわりに`package.d`内のパブリックなインポートとしてリストする必要があります。
これによりパッケージの実装がより自由になります。
`package.d`がありながら、ユーザーにはモジュールの明示的なインポートを要求したいときもあるでしょう。

<!-- Now users will continue seeing `mod1` as a single module and can continue to import it as such. Meanwhile, encapsulation is now more stringently enforced internally. Because `split1` and `split2` are now separate modules, they can’t touch each other’s private parts. Any part of the API that needs to be shared by both modules can be annotated with `package` protection. Despite the internal transformation, the public interface remains unchanged, and encapsulation is maintained. -->

ユーザーは`mod1`を単一のモジュールとして扱い続けることもできるし、
そのようにインポートし続けることもできます。
同時に、内部のカプセル化はより強力に行われるようになりました。
`split1`と`split2`は分離したモジュールのため、他方のプライベートな部分に触ることはできません。
両モジュールで共有されてほしいAPIの各部分は`package`で修飾できます。
内部的な変化にかかわらず、パブリックなインターフェースは変化せず、カプセル化は保たれています。

<!-- Wrapping up
----------- -->

### 要約

<!-- The full list of access modifiers in D can be defined as such: -->

以下がDで宣言できるアクセス修飾子の完全なリストです。

<!-- *   `public` – accessible everywhere.
*   `package` – accessible to modules in the same package.
*   `package(some.pack)` – accessible to modules in the package `some.pack` and to the modules in all of its descendant packages.
*   `private` – accessible only in the module.
*   `protected` (classes only) – accessible in the module and in derived classes. -->

- `public` – どこからでもアクセス可能。
- `package` – 同じパッケージのモジュールからアクセス可能。
- `package(some.pack)` – パッケージ`some.pack`とその子孫パッケージ内のモジュールからアクセス可能。
- `private` – モジュール内でのみアクセス可能。
- `protected` （クラスでのみ有効） – モジュールと継承先クラスからアクセス可能。

<!-- Hopefully, this article has provided you with the perspective to think in D instead of your “native” language when thinking about encapsulation in D. -->

この記事があなたに「母国語」ではなくDで考える視点を、Dのカプセル化について与えられたなら幸いです。

<!-- _Thanks to Ali Çehreli, Joakim Noah, and Nicholas Wilson for reviewing and providing feedback on this article._ -->

*この記事のレビューとフィードバックの提供をしてくれた Ali Çehreli、 Joakim Noah、 Nicholas Wilson に感謝します。*

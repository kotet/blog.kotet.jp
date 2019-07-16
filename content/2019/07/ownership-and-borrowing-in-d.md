---
title: "所有権と借用をD言語に組み込む【翻訳】"
date: 2019-07-16
tags:
- dlang
- tech
- translation
- d_blog
---

[Ownership and Borrowing in D – The D Blog](https://dlang.org/blog/2019/07/15/ownership-and-borrowing-in-d/)
を
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
翻訳しました。

誤訳等あれば気軽に
[Pull requestを投げてください](https://github.com/kotet/blog.kotet.jp)。

---

<!-- Nearly all non-trivial programs allocate and manage memory. Getting it right is becoming increasingly important, as programs get ever more complex and mistakes get ever more costly. The usual problems are: -->

ほとんどのプログラムはメモリを確保し、管理します。
プログラムが複雑になり、失敗がより大きな損害を引き起こすようになるにつれて、
メモリ管理を正しく行うことはますます重要になってきています。
一般的には以下のような問題があります。

<!-- 1.  memory leaks (failure to free memory when no longer in use)
2.  double frees (freeing memory more than once)
3.  use-after-free (continuing to refer to memory already freed) -->

1. メモリリーク（使っていないメモリを解放しない）
1. 二重フリー（複数回メモリを解放する）
1. use-after-free（すでに開放されたメモリを参照する）

<!-- The challenge is in keeping track of which pointers are responsible for freeing the memory (i.e. owning the memory), which pointers are merely referring to the memory, where they are, and which are active (in scope). -->

問題は、どのポインタがメモリを解放する責任を持つか（つまり、メモリを所有しているか）、
どのポインタがメモリを参照しているか、どれが（スコープ内で）アクティブかです。

<!-- The common solutions are: -->

一般に以下のような解決策があります。

<!-- 1.  Garbage Collection – The GC owns the memory and periodically scans memory looking for any pointers to that memory. If none are found, the memory is released. This scheme is reliable and in common use in languages like Go and Java. It tends to use much more memory than strictly necessary, have pauses, and slow down code because of inserted write gates.
2.  Reference Counting – The RC object owns the memory and keeps a count of how many pointers point to it. When that count goes to zero, the memory is released. This is also reliable and is commonly used in languages like C++ and ObjectiveC. RC is memory efficient, needing only a slot for the count. The downside of RC is the expense of maintaining the count, building an exception handler to ensure the decrement is done, and the locking for all this needed for objects shared between threads. To regain efficiency, sometimes the programmer will cheat and temporarily refer to the RC object without dealing with the count, engendering a risk that this is not done correctly.
3.  Manual – Manual memory management is exemplified by C’s `malloc` and `free`. It is fast and memory efficient, but there’s no language help at all in using them correctly. It’s entirely up to the programmer’s skill and diligence in using it. I’ve been using `malloc` and `free` for 35 years, and through bitter and endless experience rarely make a mistake with them anymore. But that’s not the sort of thing a programming shop can rely on, and note I said “rarely” and not “never”. -->

1. ガベージコレクション（Garbage Collection）  
    GCがメモリを所有し、時々メモリをスキャンすることで所有するメモリを指すポインタを探します。
    ひとつも見つからなかった場合、メモリを解放します。
    このスキームは信頼性があり、GoやJavaのような言語でよく使われています。
    書き込みゲートが挿入されるため、実際に必要な量より多くのメモリを使用し、
    停止し、プログラムの速度を遅くする傾向があります。
1. 参照カウンティング（Reference Counting）   
    RCオブジェクトがメモリを所有し、そのメモリを指すポインタがいくつあるかをカウントします。
    カウントがゼロになると、メモリが開放されます。
    これも信頼性がありC++やObjectiveCのような言語で使われています。
    RCはメモリ効率が高く、カウントのための領域しか必要としません。
    RCのマイナス面はカウントのコストが高いことです。
    デクリメントが確実に行われるように例外ハンドラを作り、スレッド間で共有されるオブジェクトの場合はロックも必要です。
    速度のためにプログラマはチートをして、RCオブジェクトに対してカウントをせずに参照をしてしまうことがあり、
    その結果事故が起こるリスクが発生します。
1. 手動  
    手動メモリ管理の例としてCの`malloc`と`free`があります。
    これは高速でメモリ効率が高いですが、言語の手助けは一切ありません。
    完全にプログラマのスキルと努力に依存します。
    私は`malloc`と`free`を35年使ってきた苦く終わりのない経験のために失敗をすることはほとんどありません。
    しかし私が「まったく」ではなく「ほとんど」と書いたことからもわかるように、これは信頼できるものではありません。

<!-- Solutions 2 and 3 more or less rely on faith in the programmer to do it right. Faith-based systems do not scale well, and memory management issues have proven to be very difficult to audit (so difficult that some coding standards prohibit use of memory allocation). -->

ソリューション2と3はプログラマーが正しくメモリ管理が出来るという信頼にいくぶん頼っています。
信頼ベースのシステムはスケールせず、メモリ管理の問題は監査が非常に難しいです
（難しいため、メモリ確保を禁止しているコーディング規約も存在します）。

<!-- But there is a fourth way – Ownership and Borrowing. It’s memory efficient, as performant as manual management, and mechanically auditable. It has been recently popularized by the Rust programming language. It has its downsides, too, in the form of a reputation for having to rethink how one composes algorithms and data structures. -->

しかし4番目の方法があります – 所有権と借用です。
これはメモリ効率が高く、手動管理と同じくらい高速で、機械的監査が可能です。
所有権と借用はプログラミング言語Rustで有名になりました。
これにも欠点はあり、アルゴリズムやデータ構造の構成方法を考え直さなければならないと評判です。

<!-- The downsides are manageable, and the rest of this article is an outline of how the ownership/borrowing (OB) system works, and how we propose to fit it into D. I had originally thought this would be impossible, but after spending a lot of time thinking about it I’ve found a way to fit it in, much like we’ve fit functional programming into D (with transitive immutability and function purity). -->

この欠点は対処可能なものであり、この記事の残りでは所有権/借用（ownership/borrowing、OB）システムがどのように動作するか、
そしてそれをDに組み込む提案について話します。
最初私は不可能だと思っていましたが、時間をかけて考えた結果、方法はあるとわかりました。
（推移的イミュータビリティと関数の純粋性によって）関数型プログラミングをDに組み入れたのと同じように。

<!-- Ownership
--------- -->

### 所有権

<!-- The solution to who owns the memory object is ridiculously simple—there is only one pointer to it, so that pointer must be the owner. It is responsible for releasing the memory, after which it will cease to be valid. It follows that any pointers in the memory object are the owners of what they point to, there are no other pointers into the data structure, and the data structure therefore forms a tree. -->

誰がメモリオブジェクトを所有するかはバカバカしいほどシンプルです。
ひとつのポインタがメモリを所有するため、ポインタが所有者です。
ポインタはそれが有効であることをやめた後にメモリを解放する責任を持ちます。
当然メモリオブジェクト内のすべてのポインタはそのポインタが指す先のメモリの所有者であり、
データ構造内にそれ以外のポインタは存在せず、したがってデータ構造は木構造のかたちをとります。

<!-- It also follows that pointers are not copied, they are moved: -->

ポインタはコピーされず、ムーブされます。

<!-- ```d
T* f();

void g(T*);

T* p = f();

T* q = p; // value of p is moved to q, not copied

g(p);     // error, p has invalid value
``` -->

```d
T* f();

void g(T*);

T* p = f();

T* q = p; // pの値はqにムーブされました。コピーされてはいません

g(p);     // エラー。pは不正な値を持ちます
```

<!-- Moving a pointer out of a data structure is not allowed: -->

データ構造の外にはポインタをムーブできません。

<!-- ```d
struct S { T* p; }

S* f();

S* s = f();

T* q = s.p; // error, can't have two pointers to s.p
``` -->

```d
struct S { T* p; }

S* f();

S* s = f();

T* q = s.p; // エラー。s.pへのポインタを複数持つことはできません
```

<!-- Why not just mark `s.p` as being invalid? The trouble there is one would need to do so with a runtime mark, and this is supposed to be a compile-time solution, so attempting it is simply flagged as an error. -->

なぜ単に`s.p`を不正としないのでしょうか？
それは実行時にマークされる必要があり、今はコンパイル時のソリューションを想定しているので、
それは単にエラーになります。

<!-- Having an owning pointer fall out of scope is also an error: -->

スコープを超えてポインタを所有することもエラーになります。

<!-- ```d
void h() {

  T* p = f();

} // error, forgot to release p?
``` -->

```d
void h() {

  T* p = f();

} // エラー。pの解放を忘れていますね？
```

<!-- It’s necessary to move the pointer somewhere else: -->

ポインターはどこかにムーブする必要があります。

<!-- ```d
void g(T*);

void h() {

  T* p = f();

  g(p);  // move to g(), it's now g()'s problem

}
``` -->

```d
void g(T*);

void h() {

  T* p = f();

  g(p);  // g()にムーブしたので、これはもうg()の問題です

}
```

<!-- This neatly solves memory leaks and use-after-free problems. (Hint: to make it clearer, replace `f()` with `malloc()`, and `g()` with `free()`.) -->

これによりメモリリークとuse-after-freeの問題はきっぱり解決されます
（ヒント：わかりやすくするために、`f()`を`malloc()`に、`g()`を`free()`に置き換えてみましょう）。

<!-- This can all be tracked at compile time through a function by using [Data Flow Analysis (DFA)](https://en.wikipedia.org/wiki/Data-flow_analysis) techniques, like those used to compute [Common Subexpressions](https://en.wikipedia.org/wiki/Common_subexpression_elimination). DFA can unravel whatever rat’s nest of `goto`s happen to be there. -->

これは関数内では、
[共通部分式](https://ja.wikipedia.org/wiki/%E5%85%B1%E9%80%9A%E9%83%A8%E5%88%86%E5%BC%8F%E9%99%A4%E5%8E%BB)
を求めるのに使われているような
[データフロー解析（DFA）](https://ja.wikipedia.org/wiki/%E3%83%87%E3%83%BC%E3%82%BF%E3%83%95%E3%83%AD%E3%83%BC%E8%A7%A3%E6%9E%90)
を用いてコンパイル時に追跡できます。
DFAは`goto`が何重にも折り重なった中に潜むどんなネズミも見逃しません。

<!-- Borrowing
--------- -->

### 借用

<!-- The ownership system described above is sound, but it is a little too restrictive. Consider: -->

上で説明した所有権システムは堅実ですが、制約が厳しすぎます。
以下のようなコードを考えてみましょう。

<!-- ```D
struct S { void car(); void bar(); }

struct S* f();

S* s = f();

s.car();  // s is moved to car()

s.bar();  // error, s is now invalid
``` -->

```D
struct S { void car(); void bar(); }

struct S* f();

S* s = f();

s.car();  // sはcar()にムーブされました

s.bar();  // エラー。sは不正です
```

<!-- To make it work, `s.car()` would have to have some way of moving the pointer value back into `s` when `s.car()` returns. -->

これを動作させるためには、`s.car()`から戻ってきたときにムーブしたポインタを`s`に返す方法が必要です。

<!-- In a way, this is how borrowing works. `s.car()` borrows a copy of `s` for the duration of the execution of `s.car()`. `s` is invalid during that execution and becomes valid again when `s.car()` returns. -->

ある意味、これは借用の仕組みそのものです。
`s.car()`は`s.car()`が実行される間`s`のコピーを借用します。
`s`はこの実行の間不正になり、`s.car()`から返ってきたときふたたび有効になります。

<!-- In D, struct member functions take the `this` by reference, so we can accommodate borrowing through an enhancement: taking an argument by ref borrows it. -->

Dにおいて、構造体のメンバ関数は`this`を参照としてとるため、エンハンスメントを通して借用に適応できます。
つまり、引数をrefでとるとそれは借用されます。

<!-- D also supports scope pointers, which are also a natural fit for borrowing: -->

Dはscopeポインタもサポートしているため、これも借用に自然と適応します。

<!-- ```d
void g(scope T*);

T* f();

T* p = f();

g(p);      // g() borrows p

g(p);      // we can use p again after g() returns
``` -->

```d
void g(scope T*);

T* f();

T* p = f();

g(p);      // g()はpを借用します

g(p);      // g()から返ってきた後はまたpを使用できます
```

<!-- (When functions take arguments by ref, or pointers by scope, they are not allowed to escape the ref or the pointer. This fits right in with borrow semantics.) -->

（
関数が引数をrefまたはscopeポインタとしてとるとき、refやポインタから脱出することはできません。
これは借用セマンティクスに適合します。
）

<!-- Borrowing in this way fulfills the promise that only one pointer to the memory object exists at any one time, so it works. -->

この方法で借用を実現すれば、
あるメモリオブジェクトを指すポインタは同時にただひとつ存在するという保証ができるため、動作します。

<!-- Borrowing can be enhanced further with a little insight that the ownership system is still safe if there are multiple const pointers to it, as long as there are no mutable pointers. (Const pointers can neither release their memory nor mutate it.) That means multiple const pointers can be borrowed from the owning mutable pointer, as long as the owning mutable pointer cannot be used while the const pointers are active. -->

ミュータブルなポインタが存在せず、変更できないポインタだけが複数あるという状況でも所有権システムは安全なままである、
という小さな洞察によって借用は更に強化できます。
（constポインタはメモリの解放も変更もしません。）
これはメモリを所有しているミュータブルなポインタがアクティブでない間であれば、
複数のconstなポインタがそのポインタの指すメモリを借用できるということを意味します。

<!-- For example: -->

例えば以下のようになります。

<!-- ```d
T* f();

void g(T*);

T* p = f();  // p becomes owner

{

  scope const T* q = p; // borrow const pointer

  scope const T* r = p; // borrow another one

  g(p); // error, p is invalid while q and r are in scope

}

g(p); // ok
``` -->

```d
T* f();

void g(T*);

T* p = f();  // pは所有者になります

{

  scope const T* q = p; // constなポインタを借用

  scope const T* r = p; // もうひとつ借用

  g(p); // エラー。qとrがスコープ内にある間はpは不正です

}

g(p); // ok
```

<!-- Principles
---------- -->

### 原理

<!-- The above can be distilled into the notion that a memory object behaves as if it is in one of two states: -->

上記はメモリオブジェクトが2つのうち1つの状態をとるかのように振る舞うという概念に蒸留できます。

<!-- 1.  there exists exactly one mutable pointer to it
2.  there exist one or more const pointers to it -->

1. メモリオブジェクトへのミュータブルなポインタがただ1つ存在する
1. メモリオブジェクトへのconstポインタが1つ以上存在する

<!-- The careful reader will notice something peculiar in what I wrote: “as if”. What do I mean by that weasel wording? Is there some skullduggery going on? Why yes, there is. Computer languages are full of “as if” dirty deeds under the hood, like the money you deposit in your bank account isn’t actually there (I apologize if this is a rude shock to anyone), and this isn’t any different. Read on! -->

注意深い読者は私が書いた「かのように」という言葉に気づいたことでしょう。
わざと曖昧な言葉遣いをしたのはなぜでしょうか？
なにかごまかしが行われようとしていたのでしょうか？
そうです、これはごまかしです。
コンピュータ言語は「かのように」でいっぱいであり、裏側では銀行に預けたお金が実際には銀行に存在しないのとおなじように
（だれかショックを受けた人がいたなら謝罪します）ダーティなことが行われています。
読んでいきましょう！

<!-- But first, a bit more necessary exposition. -->

でもまずは、少々解説が必要でしょう。

<!-- Folding Ownership/Borrowing into D
---------------------------------- -->

### Dに所有権/借用を組み入れる

<!-- Isn’t this scheme incompatible with the way people normally write D code, and won’t it break pretty much every D program in existence? And not break them in an easily fixed way, but break them so badly they’ll have to redesign their algorithms from the ground up? -->

このスキームは人々が普通に書いているDのコードと互換性がありません。
既存のDプログラムをすべて壊してしまわないといけないのでしょうか？
そして簡単に修正ができなかった場合、アルゴリズムを再設計しなければいけないのでしょうか？

<!-- Yup, it sure is. Except that D has a (not so) secret weapon: function attributes. It turns out that the semantics for the Ownership/Borrowing (aka OB) system can be run on a per-function basis after the usual semantic pass has been run. The careful reader may have noticed that no new syntax is added, just restrictions on existing code. D has a history of using function attributes to alter the semantics of a function&mdash;for example, adding the `pure` attribute causes a function to behave as if it were pure. To enable OB semantics for a function, an attribute `@live` is added. -->

まあ、そうなります。
ただしそれはDの隠し玉（別に隠してはいませんが）、関数属性がない場合の話です。
所有権/借用（OB）システムのセマンティクスは通常のセマンティック解析が実行された後に関数単位で行えることがわかりました。
注意深い読者は新しい構文の追加が不要で、既存のコードに制約を課すだけでいいということに気づくでしょう。
Dには関数属性を関数のセマンティクスを変化させるために使ってきた歴史があります。
例えば、`pure`属性を追加すると関数は純粋であるかのように振る舞います。
OBセマンティクスを関数に適用するには、`@live`属性を追加します。

<!-- This means that OB can be added to D code incrementally, as needed, and as time and resources permit. It becomes possible to add OB while, and this is critical, keeping your project in a fully functioning, tested, and releasable state. It’s mechanically auditable how much of the project is memory safe in this manner. It adds to the list of D’s many other memory-safe guarantees (such as no pointers to the stack escaping). -->

つまりOBは、必要に応じて、そして時間とリソースに応じてDのコードにインクリメンタルに追加できます。
プロジェクトを完全に機能し、テストされ、リリース可能な状態に保ちつつOBを追加できるようになります。
プロジェクトのどれくらいがこの規則の上でメモリ安全化を機械的に監査可能です。
これはDのさまざまなメモリセーフ保証（スタックを脱出するポインタが存在しない、のような）のリストに加わります。

<!-- As If
----- -->

### 「かのように」

<!-- Some necessary things cannot be done with strict OB, such as reference counted memory objects. After all, the whole point of an RC object is to have multiple pointers to it. Since RC objects are memory safe (if built correctly), they can work with OB without negatively impinging on memory safety. They just cannot be built with OB. The solution is that D has other attributes for functions, like `@system`. `@system` is where much of the safety checking is turned off. Of course, OB will also be turned off in `@system` code. It’s there that the RC object’s implementation hides from the OB checker. -->

リファレンスカウントされるメモリオブジェクトのような、厳格なOBの重要な要素がまだできていません。
なんといってもRCオブジェクトの本質は複数のポインタが存在することにあります。
RCオブジェクトは（正しく構築された場合）メモリ安全であるため、メモリ安全との悲劇的衝突をせずにOBと同居できます。
OBの上でRCの構築はできないというだけなのです。
ソリューションとして、Dには他にも`@system`のような関数に対する属性があります。
`@system`では様々な安全性チェックが切られます。
もちろん、OBも`@system`コードでは無効化されます。
これによりRCオブジェクトの実装をOBチェッカーから隠すことができます。

<!-- But in OB code, the RC object looks to the OB checker like it is obeying the rules, so no problemo! -->

しかしOBコードの中で、OBチェッカーの目にはRCオブジェクトがルールに従っているように見えます。
これで問題ないですね！

<!-- A number of such library types will be needed to successfully use OB. -->

数多くのライブラリがOBを使えるようになるでしょう。

<!-- Conclusion
---------- -->

### 結論

<!-- This article is a basic overview of OB. I am working on a much more comprehensive specification. It’s always possible I’ve missed something and that there’s a hole below the waterline, but so far it’s looking good. It’s a very exciting development for D and I’m looking forward to getting it implemented. -->

この記事はOBの基礎の概観をしました。
私はさらに総合的な仕様について作業をしています。
なにかを見逃しており水面下に穴があるという可能性は常にありますが、これまでのところ大丈夫そうです。
このDのとてもエキサイティングな開発が実装されるのが楽しみです。
---
title: "std.container for 競プロer"
date: 2019-12-12
tags:
- dlang
- advent_calendar
- tech
---

この記事はD言語 Advent Calendar 12日目の記事です。
大学でD言語はいいぞと言い続けていたら[~~感染~~開眼したD言語er](https://atcoder.jp/users/Coleball)との共著です。
この記事は前後編に分かれているうちの後編です。
前編は[D言語くん Advent Calendar 12日目の記事](/2019/12/doubly-linked-dman)として投稿されています。
前編の内容も非常に重要で示唆に富んでいるので必ず見ましょう。

---

競技プログラミングでは十分に速いプログラムをできるだけ短時間で書き上げる必要があります。
言語そのものが低速だと想定解のアルゴリズムが書けたとしても定数倍で不正解にされてしまうことがまれにあります。
また、普通に書いていても言語仕様の穴に頻繁に引っかかるような言語では高速なプログラミングは難しいでしょう。
その点、D言語は競プロ(競技プログラミング)向けの言語です。
速度と書きやすさとを両立しており、標準ライブラリも充実しています。

AtCoderでは使用言語にD言語が選べます。
執筆時点ではバージョンが古いため`import std;`ができない等不便な点がありますが、
~~最近大学でC++ばっか書いてて最新情報を追えてないので都合が良い~~
近いうちアップデートを行うそうなので期待して待ちましょう。

### 標準ライブラリ、把握できてますか

そんなD言語ですが、その魅力を競プロのために**最大限**活かすのは大変です。
標準ライブラリに需要を満たす関数があることに気づかず、自分で実装してしまうことも多いです。
もちろんD言語は速いので自前実装でもきちんと書けていれば速度で困ることはないでしょうし、
競プロで必要なデータ構造やアルゴリズムをいちどは自分で実装してみることには大きな意味があります。
しかし競プロではバグりにくいプログラミングをするのも大切です。
仕組みを理解できているのに実装でミスってバグを出してしまうくらいなら標準ライブラリを使っちゃいましょう！

というわけで今回は`std.container`の中で競プロで使えそうなものを紹介します。

### DList

双方向連結リストです。
キューにもスタックにもなる便利なやつです。

rootノードが先頭と末尾のノードにつながっているリング状の構造をしているタイプの双方向連結リストのようです。
先頭/末尾要素の削除が$O(1)$でできます。
ドキュメントには先頭/末尾への挿入操作が$O(\log(n))$と書いてありますが、
[ソース見る限り](https://github.com/dlang/phobos/blob/451c8e79ff07515d9b4de5e862ef9cad9697a345/std/container/dlist.d#L765)
1要素の時は$O(1)$でできているように見えます。
挿入系関数にはレンジも渡せるのですが、それはレンジの長さに対して$O(n)$かかっているように見えます。
$O(\log(n))$要素どこ……？$n$とは……？

```d
DList!(long) dl;
dl.insertBack(1); // 末尾に挿入
dl.insert(2); // 上のエイリアス
dl.insertFront(3); // 先頭に挿入

assert(dl.front == 3); // 先頭要素
assert(dl.back == 2); // 末尾要素

dl.removeFront(); // 先頭要素を削除
dl.removeBack(); // 末尾要素を削除

assert(dl.front == 1);
assert(dl.back == 1);
```

[Iterable](https://dlang.org/phobos/std_traits.html#isIterable)なので`foreach`や`reduce`、`array`に渡せます。
デバッグ用に全体を表示したいときは`array`で配列にします。

```d
auto dl = DList!(long)([1, 2, 3, 4, 5]);
foreach (x; dl)
    writeln(x);
dl.reduce!(max)().writeln();
dl.writeln();
dl.array().writeln();
// 出力
// 1
// 2
// 3
// 4
// 5
// 5
// DList!long(7FCF7A443020)
// [1, 2, 3, 4, 5]
```

以下のように再帰で書かれた深さ優先探索プログラムがあったとします。

```d
void dfs(T arg)
{
    if (/* ... */) // 終了条件
        return;

    // do something...

    // 再帰
    dfs(a);
    dfs(b);
}

void main()
{
    dfs(x);
}
```

これは`DList`をスタックとして使って以下のように変換できます。

```d
void main()
{
    DList!T stack;

    stack.insert(x);

    while (!stack.empty)
    {
        T arg = stack.back;
        stack.removeBack();

        if (/* ... */) // 終了条件
            continue;

        // do something...

        // 再帰
        stack.insert(b);
        stack.insert(a);
    }
}
```

状況に合わせて書きやすい方を使っていきましょう。

キューとして使うと幅優先探索ができます。

```d
void main()
{
    DList!T Q; // queueって打ちにくくない？

    Q.insert(x);

    while (!Q.empty)
    {
        T arg = Q.front;
        Q.removeFront();

        if (/* ... */) // 終了条件
            continue;

        // do something...

        Q.insert(a);
        Q.insert(b);
    }
}
```

### BinaryHeap

二分ヒープです。
ヒープソートのあれですね。
競プロではプライオリティキューとか優先度付きキューとか呼ばれていて、
今まで挿入した要素の中で最大のものが最初に出てくるキューとして使います。

二分ヒープは二分木を使ったヒープ構造を作ることで最大値の取得が高速にできます。
具体的には入っている要素数$n$に対して値の追加と最大値の削除が$O(\log(n))$で可能です。

`BinaryHeap`はランダムアクセス可能な列構造の上にヒープを構成します。
競プロで`BinaryHeap`を使う際は以下のように`std.container.array`の`Array`を使って書くと手軽です。

```d
BinaryHeap!(Array!long) bh;
```

書くのがめんどくさいためエイリアスをはっておきます。

```d
alias PQueue = BinaryHeap!(Array!long);
```

するとこのように優先度付きキューを使うことができます。

```d
PQueue pq;
foreach (x; [0, 1, 9, 2, 8, 3, 7, 4, 6, 5])
    pq.insert(x);
foreach (_; 0 .. pq.length)
{
    writeln(pq.front);
    pq.removeFront();
}
// 9
// 8
// 7
// 6
// 5
// 4
// 3
// 2
// 1
// 0
```

さらに、大小比較の方法を変えたり、要素の型を変えたりするためにエイリアステンプレートにすると便利でしょう
(執筆中に気がついた)
。

```d
alias PQueue(T, alias less = "a<b") = BinaryHeap!(Array!T, less);

PQueue!long pq1;
PQueue!(long, "b<a") pq2; // 最小値が取り出せるようになる
```

`InputRange`なので`InputRange`を受け取ることのできる関数が使えます。
使えたからといってどう役に立つのかすぐには思いつきませんが……。

### RedBlackTree

赤黒木です。
大小比較可能な要素の追加、削除、探索が$O(\log(n))$でできます。
連想配列で`bool[T]`とやるより集合を自然に扱えます。
また、連想配列と違って最悪計算量が$O(\log(n))$であるという安心感があります。
ただ、AtCoderでは基本的に連想配列を攻撃するような入力は来ないので大抵の場合では連想配列のほうが速いです。

```d
auto rb = new RedBlackTree!long();
rb.insert(1); // 追加
rb.insert(2);
rb.insert(3);
rb.removeKey(2); // 削除

writeln(rb);
writeln(1 in rb);
writeln(2 in rb);
// RedBlackTree([1, 3])
// true
// false
```

上の2つと違って初期化の際は`new`するので注意しましょう。

### 使用例

#### DList

- [C - 幅優先探索](https://atcoder.jp/contests/abc007/tasks/abc007_3)
    - [提出 #8831748 - AtCoder Beginner Contest 007](https://atcoder.jp/contests/abc007/submissions/8831748)

- [C - Unification](https://atcoder.jp/contests/abc120/tasks/abc120_c)
    - [提出 #8897235 - AtCoder Beginner Contest 120](https://atcoder.jp/contests/abc120/submissions/8897235)

#### BinaryHeap + Associative Array (連想配列)

- [D - Cake 123](https://atcoder.jp/contests/abc123/tasks/abc123_d)
    - [提出 #8899582 - AtCoder Beginner Contest 123](https://atcoder.jp/contests/abc123/submissions/8899582)

#### BinaryHeap + RedBlackTree

- [D - Cake 123](https://atcoder.jp/contests/abc123/tasks/abc123_d)
    - [提出 #8836186 - AtCoder Beginner Contest 123](https://atcoder.jp/contests/abc123/submissions/8836186)


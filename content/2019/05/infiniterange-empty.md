---
title: "無限レンジを作るときはemptyの実装に気をつけなければならない"
date: 2019-05-27
tags:
- dlang
- tech
---

D言語で無限レンジを作るときに注意しなければならないこと。
ドキュメントをちゃんと読み込んでなかったので長らく気づきませんでした。

### 無限レンジ

無限レンジとは要素数が無限のレンジです。
例えばこれは1が無限に続くレンジです。

```d
struct One {
    long front(){ return 1; }
    void popFront() {}
    bool empty()
    {
        return false;
    }
}
```

こんな感じに`take`とかと組み合わせて使います。

```d
import std.range : take;
import std.stdio : writeln;

void main()
{
    One().take(10).writeln(); // [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
}
```

### isInfinite!One == false

しかしここで`isInfinite`を使ってみると`false`になります。

```d
assert(isInfinite!One); // Assertion failure
```

今まで使ってきたなかでこれで困ったことはありませんが、ライブラリを作るときや、
契約で無限レンジのみを受け取るようにしている関数を使うようなことがあるとマズいです。

### enumを使う

`empty`が定数`false`を返しているので無限レンジとして成り立っているように思えますが、
これはコンパイル時的にはアウトのようです。
この関数が常に`false`を返すのか確かめるすべがありません。

関数ではなく`enum`を使ってコンパイル時定数にしてやる必要があります。

```d
struct Two {
    long front(){ return 2; }
    void popFront() {}
    enum bool empty = false;
}
```

これで`isInfinite`は`true`になります。

```d
assert(isInfinite!Two); // Pass
```

今までずっと関数で書いてたので、自分が書いていたものは何ひとつ"Infinite range"ではなかったということになります。

調べてみたらdlang-tourも11月まで間違えて
`const`に[していました](https://github.com/dlang-tour/english/commit/0e56f1c29162d2a0a8d800c67b80761d7ac009f6#diff-bf645f6a9762b3f8d4e560c91ad842bc)。
`const`が使えなくなったのはDMD 2.067.1からのようです。
ちなみに関数の`empty`が`isInfinite`に認められていた時期は一度もありません。

### 追記: 重要なのは静的にわかるかどうか

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">staticをつけてもいいですよ <a href="https://t.co/VSmGIT59AM">https://t.co/VSmGIT59AM</a></p>&mdash; karita (@kari_tech) <a href="https://twitter.com/kari_tech/status/1133023001014706176?ref_src=twsrc%5Etfw">May 27, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

というわけで`static`関数なら大丈夫です。

```d
struct Two {
    long front(){ return 2; }
    void popFront() {}
    static bool empty()
    {
        return false;
    }
}

import std.range : isInfinite;

static assert(isInfinite!Two); // Pass
```

`isInfinite`の中身を見てみればどういうことか理解できます。
というか真っ先に読んでみるべきでしたね……

[phobos/primitives.d at v2.086.0 · dlang/phobos](https://github.com/dlang/phobos/blob/v2.086.0/std/range/primitives.d#L1593)

```d
/**
Returns `true` if `R` is an infinite input range. An
infinite input range is an input range that has a statically-defined
enumerated member called `empty` that is always `false`,
for example:
----
struct MyInfiniteRange
{
    enum bool empty = false;
    ...
}
----
 */

template isInfinite(R)
{
    static if (isInputRange!R && __traits(compiles, { enum e = R.empty; }))
        enum bool isInfinite = !R.empty;
    else
        enum bool isInfinite = false;
}
```

見ての通り`isInfinite`は非常にシンプルなテンプレートです。

`isInfinite`が`true`になるのは、インプットレンジ`R`について`enum e = R.empty;`がコンパイルできる、
つまり`R.empty`にコンパイル時にアクセスできるときで、なおかつ`R.empty`が`false`になるときです。
最初のコードは普通のメンバ関数がインスタンスなしに直接`R.empty`を呼び出せないので`false`になっていたというわけですね。
もちろん`static`関数でもコンパイル時に決まらないような内容だと`false`になります。

単に`false`を返すだけなら行数が増えるだけなので通常は`enum`を使えばいいと思います。
`static`関数はテンプレート引数によって無限か有限かが切り替わるようなレンジを作るときに役に立つでしょうか？

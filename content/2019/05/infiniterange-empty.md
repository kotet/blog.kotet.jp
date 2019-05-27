---
title: "無限レンジを作るときはemptyをenumにしなければならない"
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
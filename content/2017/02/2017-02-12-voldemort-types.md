---
date: 2017-02-12
title: "名前を言ってはいけないあの型 - Voldemort Types"
tags:
- dlang
- tech
---

[こちら](http://p0nce.github.io/d-idioms/#Voldemort-types)
のサイトでVoldemort Typesとかいう衝撃的な名前のものを見たのでしっかり読み込んでみた。

## 前提

まずインデックスの2乗が得られる構造体があるとする。

```d
module voldemort;

struct TomRiddle
{
    size_t opIndex(size_t n)
    {
        return n*n;
    }
}
```

そしてそれを返す関数がある。

```d
TomRiddle generator()
{
    return TomRiddle();
}
```

このモジュールを使ってこのようなコードを書く。

```d
import std.stdio;
import voldemort;

void main()
{
    TomRiddle square = generator();
    foreach(i;0 .. 5)
    {
        writeln(square[i]);
    }
}
```

実行するとこうなる。

```
0
1
4
9
16
```

ユーザーコードに`TomRiddle`が出てきているので、カプセル化に失敗している。
たとえばこの型を`Voldemort`に変えると当然動かなくなる。

```d
module voldemort;

struct Voldemort
{
    size_t opIndex(size_t n)
    {
        return n*n;
    }
}

Voldemort generator()
{
    return Voldemort();
}

```
```
source/app.d(6,15): Error: undefined identifier 'TomRiddle'
```

## Voldemort Types

ここで構造体`Voldemort`の定義を`generator`の中に入れる。

```d
module voldemort;

auto generator()
{
    struct Voldemort
    {
        size_t opIndex(size_t n)
        {
            return n*n;
        }
    }
    return Voldemort();
}
```

すると`Voldemort`はVoldemort Typeになる。
Voldemort Typeは関数の外でその名前を呼ぶことができない。
以下のようにちゃんと正しい名前で呼んであげてもエラーが出る。

```d
import std.stdio;
import voldemort;

void main()
{
    Voldemort square = generator();
    foreach(i;0 .. 5)
    {
        writeln(square[i]);
    }
}
```
```
source/app.d(6,15): Error: undefined identifier 'Voldemort', did you mean import 'voldemort'?
```

Voldemort Typeは型推論を介してしか渡すことができなくなる。
つまりこのようなコードになる。

```d
import std.stdio;
import voldemort;

void main()
{
    auto square = generator();
    foreach(i;0 .. 5)
    {
        writeln(square[i]);
    }
}
```
```
0
1
4
9
16
```

こんな感じで新しいインスタンスを生成しようとしてみる。

```d
auto square = generator();
typeof(square) square2;
```

しかしコンパイラは関数のスコープの外で`Voldemort`がインスタンス化されるのを許さない。

```
source/app.d(7,20): Error: cannot access frame pointer of voldemort.generator.Voldemort
```

## まとめ

Voldemort Typeは型をカプセル化する方法であり、Andrei Alexandrescuによって命名された。
Rangeとかに使うと便利らしい。
これには実行可能ファイルのサイズが大きくなる欠点があるらしく、それを防ぐためにHorcrux（分霊箱） Methodというのがあるようだが、ちょっとそれはまた今度。

---

追記: オブジェクトファイルが大きくなる問題は[DMD 2.077.0で改善されたらしい]({% include relative %}{% post_url 2017/11/2017-11-04-dmd-2-077-0-released %})。
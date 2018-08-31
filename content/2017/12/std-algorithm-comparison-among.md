---
date: 2017-12-01
title: "「どれかと等しい」を簡潔に書く"
tags:
- dlang
- tech
- log
excerpt: "`a == b || a == c || a == d || a == e`のような同じ値に対して何度も同値比較をするコードを簡潔に書く方法を学んだので日記を兼ねて書く。"
---

`a == b || a == c || a == d || a == e`のような同じ値に対して何度も同値比較をするコードを簡潔に書く方法を学んだので日記を兼ねて書く。

### いきさつ

あれは今から6日……いや、8日前の出来事だったか。
まあいい、このブログにおいては多分……4日後の出来事だ。
自分は`static foreach`を使ったFizzBuzzを書いていた。

D言語を書くときはフォーマッターである[Dfmt](https://github.com/dlang-community/dfmt)を定期的に走らせるのが癖になっているのだが、`static foreach`が正しく整形されないことに気がついた。
以下のようにカッコのインデントが過剰に深くなってしまうのだ。

```d
static foreach (/* ... */)
        {
        /* ... */
    }
```

この時は手で整形することで対処したが、少しDfmtのコードを読んでみようと思った。

OSSのソースを読むことは以前から定期的に試みては挫折していた。
しかしD言語の性質か、Dfmtが特別きれいなコードを書いているのか、割と簡単に理解することができ、また自分にも修正できそうだと思った。
どうやら`static foreach`はまだサポートされていないようだったので、そのためのコードを書いてプルリクエストを送った。

[Add support for `static foreach` by kotet · Pull Request #304 · dlang-community/dfmt](https://github.com/dlang-community/dfmt/pull/304)

すると反応があった。

### 実例

最初自分は以下のようなコードを書いた。
`arr[i + 1]`に対して何度も同値比較をしてORでつないでいる。

```d
if (arr[i] == tok!"static" && (arr[i + 1] == tok!"if"
    || arr[i + 1] == tok!"else" || arr[i + 1] == tok!"foreach"
    || arr[i + 1] == tok!"foreach_reverse") && (i + 2 >= index || arr[i + 2] != tok!"{"))
// 後略
```

それに対してこのようなレビューをもらった。

> I would `import std.algorithm : among` and make this
> ```d
> arr[i + 1].among!(tok!"if", tok!"else", tok!"foreach", tok!"foreach_reverse")
> ```
> because it has a lot of cases now [^1]

[^1]: [github.com/dlang-community/dfmt/pull/304#discussion_r153042727](https://github.com/dlang-community/dfmt/pull/304#discussion_r153042727)

ここまでケースが増えた場合は`among`を使うといい、ということらしい。

### `std.algorithm.comparison.among`

`std.algorithm.comparison.among`は複数の引数を取り、第1引数と等しい物があった場合は`1`から始まるインデックスを返す。
等しい物がなかった場合`0`を返す。

DはCと同じように`0`は`false`、それ以外は`true`とみなされる。
そのため

```d
among(arr[i + 1], tok!"if", tok!"else", tok!"foreach", tok!"foreach_reverse")
```

は

```d
(arr[i + 1] == tok!"if"
    || arr[i + 1] == tok!"else" || arr[i + 1] == tok!"foreach"
    || arr[i + 1] == tok!"foreach_reverse")
```

と同じ効果をもつのだ。
数値が`bool`扱いされる仕様は[バグの元になったりする](http://furutsuki.hatenablog.com/entry/2017/11/18/143014)ので、
以上の仕組みを理解したうえで使うようにしたほうが良いと思う。

さらにこの関数にはテンプレート版があり、比較する値たちがコンパイル時に決まっている場合以下のようにすると最適化してくれる。

```d
among!(tok!"if", tok!"else", tok!"foreach", tok!"foreach_reverse")(arr[i + 1])
```

そこに[UFCS](https://qiita.com/nak2yoshi/items/1bbd91fb23d7cc67109e)とカッコの省略を組み合わせると最初のコードになる。

```d
arr[i + 1].among!(tok!"if", tok!"else", tok!"foreach", tok!"foreach_reverse")
```

### 感想

たしか自作でないソフトウェアに自分の書いたDのコードがマージされるのは初めてのことである。
なんだかようやく自分がプログラマであるという保証が得られたようで嬉しい。

OSSに参加するというのは全く予想していなかった知識が得られて楽しいなと思った。
たぶん一人では`among`の存在になかなか気づかなかっただろうし、仮に見つけたとしても数値と`bool`の関係を思い出してこのように使えるものだと思うことはなかっただろう。

`std.algorithm.comparison`にあるということはひょっとして初めからこの目的で作られた関数だったんだろうか?
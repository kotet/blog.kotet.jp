---
date: 2017-07-05
title: "binary.h in D"
tags:
- dlang
- tech
excerpt: "C言語にはなぜか二進数リテラルがないため、そういうことをしたい場合自分で何とかする必要がある。
        D言語には普通に二進数リテラルがあるが、同じことをするコードを書いてTemplate Mixinの練習をすることにした。"
image: 2017/07/05/twitter.png
---

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">なんか、見てはいけないものを見てしまった気がする <a href="https://t.co/MP4aw9gXqg">pic.twitter.com/MP4aw9gXqg</a></p>&mdash; すぱっしゅ＠こーせんちほーぐらし！ (@hajime__725) <a href="https://twitter.com/hajime__725/status/882048385791832064">2017年7月4日</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

C言語にはなぜか二進数リテラルがないため、そういうことをしたい場合自分で何とかする必要がある。
D言語には普通に二進数リテラルがあるが、同じことをするコードを書いてTemplate Mixinの練習をすることにした。
与えられた型の表現できる範囲の二進数リテラルを生成する。

<script src="https://gist.github.com/kotet/d06125b1d3b14f101742b1411d83c46f.js?file=binary.d"></script>

どんなコードが生成されているか見てみる。

```console
$ dmd binary.d -unittest -main -vcg-ast
```

![binary.d.cg](/assets/2017/07/05/binary.png)

全体は[こちら](https://gist.github.com/kotet/d06125b1d3b14f101742b1411d83c46f#file-binary-d-cg)。
`ubyte`で表現できるすべての値の8文字以下の二進数表現を網羅している。
コードの文字列を生成して、1つの`mixin`に渡している。

```d
mixin template binary(T)
{
    foreach(...){
        mixin(...);
    }
}
```

上のように`mixin`を`foreach`で回したいところだが、それをするための`static foreach`はまだ
[Preliminary Review Round 1](https://github.com/dlang/DIPs/blob/d2dc77802c74378cf4545069eced21f85fbf893f/DIPs/DIP1010.md)
なのでのんびり待とう。

**追記：** [`static foreach`が使えるようになった!](/2017/09/2017-09-03-dmd-2-076-0-released)
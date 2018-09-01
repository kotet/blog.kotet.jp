---
date: 2017-10-13
aliases:
- /2017/10/13/article-counter.html
title: "GitHub Pagesで総記事数を表示する"
tags:
- jekyll
- tech
excerpt: "タグページではタグごとの記事数を見ることができるようになっているが、サイトの総記事数は確認できるようになっていなかった。ふと思い立ってトップページで総記事数を確認できるようにした。"
---

タグページではタグごとの記事数を見ることができるようになっているが、サイトの総記事数は確認できるようになっていなかった。
ふと思い立ってトップページで総記事数を確認できるようにした。

ところで「github pages 総記事数」とか「jekyll 総記事数」でググってもそれらしい記事がトップに出てこない。
どんなに当たり前なことでも日本語化されていなければ記事を書いて、コピペプログラマを量産する邪悪な人間になるための第一歩として記事を書く。

### `size` liquid fliter

`site.posts` でPostのリストが取得できる。
それに[`size`](https://shopify.github.io/liquid/filters/size/)フィルタをかけると長さが取得できる。

```html
  <h1 class="page-heading">{{ site.posts | size }} Posts</h1>
```

すると以下のように総記事数を表示できる。

---

<h1 class="page-heading">{{ site.posts | size }} Posts</h1>

---

記事執筆時点ではこの記事を含め90件だった。
もうすぐ100件だ!

以下のようにドット記法を使っても同じ結果が得られるが、なんだか普通のプロパティと区別がつかなくてバグを発生させそうなのでふつうにフィルタを使ったほうがいいと思う。

```html
  <h1 class="page-heading">{{ site.posts.size }} Posts</h1>
```
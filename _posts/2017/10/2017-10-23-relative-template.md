---
layout: post
title: "GitHub Pagesで相対パスを使う"
tags: jekyll tech github
excerpt: "IPFS上でサイトをホストしたりするとドメインがコロコロ変わったりするので、今のうちにすべてのリンクを相対パスにしておきたくなった。
しかしGitHub Pagesにおいてそれは簡単なことではない。"
---

IPFS上でサイトをホストしたりするとドメインがコロコロ変わったりするので、今のうちにすべてのリンクを相対パスにしておきたくなった。
しかしGitHub Pagesにおいてそれは簡単なことではない。

### だめなやつら

- `relative_url` フィルタ

名前からしてそれっぽいがこれではダメである。
これは`/path/to/file`のような「ルートからの」相対パスになる。

- Jekyllプラグイン

これが使えれば一番楽だろうが、残念ながらGitHub Pagesではプラグインの導入が自由でない。

### 自作テンプレート

そういうわけでなんとか今使える機能だけで相対パスを生成する必要がある。
探してみたところこのようなものがあった。

[How to deploy a jekyll site locally with css, js and background images included? - Stack Overflow](https://stackoverflow.com/questions/7985081/how-to-deploy-a-jekyll-site-locally-with-css-js-and-background-images-included)

ここにあった以下のテンプレートを参考に改良を加える。
読めばわかるが、`page.url`の最後がファイル名でも`/`でも動作するようになっている。

```html
{% raw %}{% assign lvl = page.url | append:'X' | split:'/' | size %}
{% capture relative %}{% for i in (3..lvl) %}../{% endfor %}{% endcapture %}

<link href="{{ relative }}css/main.css" rel="stylesheet" />
<script src="{{ relative }}scripts/jquery.js"></script>{% endraw %}
```

まず、すべてのページに2行のテンプレートを入れるのはめんどくさすぎるので別ファイルに分ける。

#### `_includes/relative`

```html
{% raw %}{% assign lvl = page.url | append:'X' | split:'/' | size %}
{% capture relative %}{% for i in (3..lvl) %}../{% endfor %}{% endcapture %}{% endraw %}
```

これで`/path/to/file`や`/path/to/directory/`の形をしたルートからの相対パスの前に
`{% raw %}{% include relative %}{% endraw %}`をつけるだけで`../..//path/to/file`のような相対パスになる。
ちょっと`/`が多い気がするが問題なく動作する。

しかしこのままでは改行が入ってしまうので1行にする。

```html
{% raw %}{% assign lvl = page.url | append:'X' | split:'/' | size %}{% capture relative %}{% for i in (3..lvl) %}../{% endfor %}{% endcapture %}{% endraw %}
```

問題はまだある。
このままでは`/`で使った時に空文字列を返してしまい、URLが`/path/to/file`、つまりルートからのパスになってしまう。
これではIPFS式のURL`/ipfs/<hash>/path/to/file`に対応できない。
しかしこれは最後に`.`をつけてやるだけで解決する。

```html
{% raw %}{% assign lvl = page.url | append:'X' | split:'/' | size %}{% capture relative %}{% for i in (3..lvl) %}../{% endfor %}{% endcapture %}.{% endraw %}
```

これが完成形である。
ルートから遠いところでは`../.././path/to/file`、ルートでは`./path/to/file`のようなURLをこれを使って作ることができる。

以下は実際の使用例である。

#### before

```html
{% raw %}{% post_url 2017/10/2017-10-20-ipfs-browser-extention %}{% endraw %}
```

```
{% post_url 2017/10/2017-10-20-ipfs-browser-extention %}
```

#### after

```html
{% raw %}{% include relative %}{% post_url 2017/10/2017-10-20-ipfs-browser-extention %}{% endraw %}
```

```
{% include relative %}{% post_url 2017/10/2017-10-20-ipfs-browser-extention %}
```

このとおり、相対的なパスを作ることができた。
ただ、いちばん面倒なのはここではなく、既存のすべてのリンクにもれなくこの`{% raw %}{% include relative %}{% endraw %}`
を[つけることだったりする](https://github.com/kotet/kotet.github.io/commit/d0057ecd2a60b48a0ad0901d6f5518ce69a49cf5)。

---

追記: このテンプレートは404ページにリダイレクトされた時に動作しない。
`/404.html`のつもりでHTMLが生成されるのだが、実際のlocationはアクセスしようとしたページのものになるので、階層がずれてしまう。
完全な静的サイトだと信じきっていたので思わぬ落とし穴だった。
404ページを内部リンクのないシンプルなHTMLにすることで対処した。
今までどおりの404ページを使う方法を考えたい。
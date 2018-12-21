---
title: "highlight.jsの言語自動判定を無効化する"
date: 2018-12-21
tags:
- tech
---

Hugoのデフォルトのシンタックスハイライトが微妙なため
（何よりこのサイトで最も多く出現するD言語に対応していない！）、
このサイトでは[highlight.js](https://highlightjs.org/)を使っています。
しかし、コードブロックに言語を何も指定しないとhighlight.jsは勝手に言語を判断してしまいます。

### 自動判定機能

たとえばmarkdownでこのようにテキストをコードブロックで囲んでみます。

``````markdown
```
highlight.js

Syntax highlighting for the Web

    185 languages and 89 styles
    automatic language detection
    multi-language code highlighting
    available for node.js
    works with any markup
    compatible with any js framework
```
``````

すると以下のようなHTMLになります。
言語を指定すると`language-markdown`などのようなクラスが`<code>`タグにつくのですが、
指定しなかった場合はこのようにシンプルな`<pre>`タグと`<code>`タグになります。

```html
<pre><code>highlight.js

Syntax highlighting for the Web

    185 languages and 89 styles
    automatic language detection
    multi-language code highlighting
    available for node.js
    works with any markup
    compatible with any js framework
</code></pre>
```

ここで`<head>`タグあたりに以下のようにしてhighlight.jsを導入します。

```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js"></script>
<script>
hljs.initHighlightingOnLoad();
</script>
```

すると以下のようなHTMLに変換されます。
見ての通り勝手にPython扱いしてくれています。
どんな言語になるかはテキストの内容によって異なりますが、
いずれにしてもそんな言語を書いた覚えはないです。

```html
<pre><code class="hljs python">highlight.js

Syntax highlighting <span class="hljs-keyword">for</span> the Web

    <span class="hljs-number">185</span> languages <span class="hljs-keyword">and</span> <span class="hljs-number">89</span> styles
    automatic language detection
    multi-language code highlighting
    available <span class="hljs-keyword">for</span> node.js
    works <span class="hljs-keyword">with</span> any markup
    compatible <span class="hljs-keyword">with</span> any js framework
</code></pre>
```

上のHTMLをこのページに埋め込んでみたのがこちらです。
Pythonのキーワードや数値が勝手に強調されています。
これはまだ邪魔にはなりませんが、
自動認識した言語でシンタックスエラーになるようなテキストだと真っ赤になって非常に辛い感じになります。
シンタックスエラーになる時点でおかしいと気づいてくれ……（高望み）

<pre><code class="hljs python">highlight.js

Syntax highlighting <span class="hljs-keyword">for</span> the Web

    <span class="hljs-number">185</span> languages <span class="hljs-keyword">and</span> <span class="hljs-number">89</span> styles
    automatic language detection
    multi-language code highlighting
    available <span class="hljs-keyword">for</span> node.js
    works <span class="hljs-keyword">with</span> any markup
    compatible <span class="hljs-keyword">with</span> any js framework
</code></pre>

無効な言語を指定すると勝手に違う言語にすることはありませんが、
こんどは全く触らなくなってしまうので背景色など最低限の整形もしてくれなくなってしまいます。

一応これはプレインテキストだ、と明示する方法もあって、`plaintext`クラスをつければ良いです。
しかしHugoのマークダウンプロセッサは`language-<言語名>`という規則でクラス名をつけます。
そのため、素直に```` ```plaintext````などと書いてもクラス名は`language-plaintext`になり、
プレインテキストとして処理してはくれません。
無効な言語として、全く処理してくれなくなります。
コードブロックに独自のクラスをつける方法は探せば見つかるでしょうが、
既存のコードで```` ``` ````と囲ってしまっているのを書き換えたくはないし、めんどくさいです。
それにmarkdown側で解決すべき問題ではない気もします。

### languagesオプション

探したら`languages`オプションというのがありました。
これは、highlight.jsが言語の自動認識をする際に候補として使う言語のリストで、
配列の形で指定します。
これを空にしてやると、言語の自動認識は行われません。
しかし`hljs`クラスは付加されるので、ちゃんと背景等のスタイリングは行われます。
自分のサイトではハイライトしてほしいコードブロックではすべて言語を明示しているので、
自動認識は無効化してしまっていいでしょう。

設定は`configure`関数に渡す形で行います。

```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/styles/github.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/highlight.min.js"></script>
<script>
hljs.configure({languages: []})
hljs.initHighlightingOnLoad();
</script>
```

すると余計なハイライトが行われなくなります。

```html
<pre><code class="hljs">highlight.js

Syntax highlighting for the Web

    185 languages and 89 styles
    automatic language detection
    multi-language code highlighting
    available for node.js
    works with any markup
    compatible with any js framework
</code></pre>
```

```
highlight.js

Syntax highlighting for the Web

    185 languages and 89 styles
    automatic language detection
    multi-language code highlighting
    available for node.js
    works with any markup
    compatible with any js framework
```

---
date: 2018-04-11
title: "GitHub Pagesでも目次(ToC)は作れる"
tags:
- jekyll
- tech
- github
---

スクロールがめんどくさくなってきたので目次(Table of Contents: ToC)を設置しようと思った。
しかしGitHub Pagesでは新しいプラグインの導入ができない。
GitHub Pages組み込みのJekyllの、ソースさえコミットすれば更新できる気軽さを維持したままToCを導入したい。

しかし日本語の情報を探してみると誰も彼もプラグインを導入している。
やはりどうしようもないのか……と思ったら普通にliquidテンプレートだけで作ったToCがあった。
なぜ日本語の記事がないのか、まあ自分はそれでいいんだけどせっかくなのでこうして記事を書いている。

### Javascriptを使う

これなら割と何でもできてしまうが、できる限りJSは減らしたいのでボツ。

### kramdownの機能を使う

kramdownにもToC生成機能があるらしい。
ただしこれはmarkdownにしか設置できず、`_layouts`のHTMLで使うことはできない。
なのでToCがほしい記事に個別に設置する形になると思う。
めんどくさいし、ブログの機能のために`_posts`以下のファイルを編集したくないのでそんなことはしない。

### allejo/jekyll-toc

[allejo/jekyll-toc: A GitHub Pages compatible Table of Contents generator without a plugin or JavaScript](https://github.com/allejo/jekyll-toc)

そのものズバリなリポジトリが存在する。
以下使い方。

#### `toc.html`の配置

リポジトリをクローンしてきて、`_includes/toc.html`を自分のサイトの`_includes`フォルダに入れる。

#### include

`_layouts`以下の好きなファイルの好きな場所で`_includes/toc.html`をincludeする。

```
{% include toc.html html=content %}
```

これで`content`内のhタグを探して自動的にToCを生成してくれる。

#### サニタイズ

自分の記事だとタイトルをリンクにすることがあるので、そのままToCを生成すると二重aタグになってしまう。
最初気が付かずにテンプレートの改造をしてしまったのだが、このテンプレートにはそういうときのための機能もある。

```
{% include toc.html html=content sanitize=true %}
```

こうするとToCの要素がリンクなどを外したプレインテキストになる。

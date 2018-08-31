---
date: 2017-05-10
title: "記事の編集履歴、PR作成、その他Qiitaにあるような3つの機能の代替"
tags:
- jekyll
- tech
- github
---

**追記：現在は以下のテンプレートは動かないかもしれない。[更新版](/2018/01/jekyll-templates-update)**

このサイトの各ページの下にある"Improve this page"について書く。
GitHub Pagesでは、GitHubリポジトリの名前、ブランチ、現在のページに対応するソースファイルのパスが変数として得られる。
なのでテンプレートを使ってQiitaの"編集履歴"、"編集リクエスト"のような機能を実現することができる。
この2つは技術系記事が載るサイトにあるべき機能だと思う。
というかあらゆるウェブサイトに付いてほしい。

### 現在のページの編集(commit)履歴

```
https://github.com/{{ site.github.repository_nwo }}/commits/{{ site.github.source.branch }}/{{ page.path }}
```

[サンプル](https://github.com/{{ site.github.repository_nwo }}/commits/{{ site.github.source.branch }}/{{ page.path }})

### 現在のページの編集リクエスト(editing)ページ

```
https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }}
```

[サンプル](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})

### Markdownで本文を見る(raw)

```
https://raw.githubusercontent.com/{{ site.github.repository_nwo }}/{{ site.github.source.branch }}/{{ page.path }}
```

[サンプル](https://raw.githubusercontent.com/{{ site.github.repository_nwo }}/{{ site.github.source.branch }}/{{ page.path }})

多分他にもいろいろできると思う。
---
date: 2017-01-09
aliases:
- /2017/01/09/64fd38ef5e10bf8ae3fa.html
title: "Qiitaの記事をJekyllの投稿の形式に変換してバックアップする"
tags:
- qiita
- tech
- jekyll
excerpt: "ひょっとしたら隕石が落ちてきたりしてQiitaに投稿した記事が消えてしまうことがあるかもしれない。対策として自分ですべてを管理できるところにも記事をバックアップできるスクリプトを書いた。画像も取得してリンクを書き換えてくれる。"
---
この記事はQiitaに投稿されたものの転載です。

---
ひょっとしたら隕石が落ちてきたりしてQiitaに投稿した記事が消えてしまうことがあるかもしれない。  
対策として自分ですべてを管理できるところにも記事をバックアップできるスクリプトを書いた。
画像も取得してリンクを書き換えてくれる。

[kotet/qiita-to-jekyll](https://github.com/kotet/qiita-to-jekyll)

## つかいかた

1. [管理画面](https://qiita.com/settings/applications)からアクセストークンを入手する。
2. `python qiita-to-jekyll.py <アクセストークン>`
3. 記事や画像が取得され、変換し保存される。


#### 変換結果の例/`2016-12-14-a2203a400136ba50b41e.md`
```md
---
layout: post
title: "GitHubのissueを悪用して画像をホストする"
tags: Qiita
---
この記事はQiitaに投稿されたものの転載です。

---
知らなかったので投稿。  
[Dash](https://github.com/Circular-Studios/Dash)というDで書かれたゲームエンジンがあるのだが、そのreadmeの一番上にあるでっかいロゴの画像ファイルがどこにおいてあるのか気になった。  
![でかい](/assets/qiita/0/57768/cabd3a50-395c-ee60-6068-875e6b6a96f7.png)
//以下省略//
```

## オプション

### --tag

tagsを指定できる。

### --note

`この記事はQiitaに投稿されたものの転載です。\n---`というところを指定できる。

### --imgpath

画像のURLを置き換える。

### --postdir

変換後の記事の保存場所

### --imagedir

画像の保存場所

---

いい感じになってきたが、[まだうまく動かない場合とかもある](https://github.com/kotet/qiita-to-jekyll/issues)。~~誰か作って~~そのうちなんとかしたい。

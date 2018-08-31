---
date: 2018-01-01
title: "記事の編集履歴、PR作成、ソース表示 in GitHub Pages 2018"
tags:
- jekyll
- tech
- github
excerpt: "以前書いた記事 のJekyllテンプレートが動かなくなっていた。現在でも使えるように書き換えていく。"
---

[以前書いた記事](/2017/05/2017-05-10-commits-and-edit)
のJekyllテンプレートが動かなくなっていた。

現在でも使えるように書き換えていく。

### 何が変わったのか

`site.branch`が動いていないっぽい。
なぜか探しても[GitHubのすっごい古いアーカイブ](https://github.com/jekyll/jekyll-help/issues/5#issuecomment-39040524)しか見つからない。
去年の自分はどこからこの情報を見つけてきたんだ……？
いつ消えてもおかしくないタイプの機能だったんだろうか？

というわけで代わりに[Repository metadata](https://help.github.com/articles/repository-metadata-on-github-pages/)
の`site.github.source.branch`に置き換えていく。

### Commit log

```
https://github.com/{{ site.github.repository_nwo }}/commits/{{ site.github.source.branch }}/{{ page.path }}
```

[サンプル](https://github.com/{{ site.github.repository_nwo }}/commits/{{ site.github.source.branch }}/{{ page.path }})

### Editing page

```
https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }}
```

[サンプル](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})

### Raw file

```
https://raw.githubusercontent.com/{{ site.github.repository_nwo }}/{{ site.github.source.branch }}/{{ page.path }}
```

[サンプル](https://raw.githubusercontent.com/{{ site.github.repository_nwo }}/{{ site.github.source.branch }}/{{ page.path }})
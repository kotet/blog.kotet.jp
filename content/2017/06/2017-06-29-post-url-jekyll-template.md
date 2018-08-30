---
date: 2017-06-29
title: "GitHub Pagesで内部リンクを貼るpost_urlテンプレートについて"
tags:
- jekyll
- tech
---

Jekyllの`post_url`テンプレートについて日本語の情報が見つからず苦労したので書く。

どうもGitHub Pages(Jekyll)のURL生成規則が変わったらしく、このサイトの一部投稿のURLが変わってしまっている。
その結果、`post_url`テンプレートを使わずにURLを直打ちしていた内部リンクが切れてしまった。
一番悪いのはURLが変わってしまったことなのだが、
すでにGoogleにも新しいURLでインデックスが始まっているし変わってしまったものは仕方がないとする。
この機会に内部リンクの直打ちをやめ、
ちゃんと`post_url`を使おうと思ったところエラーが出ないようにするのにかなり手間取った。
ここに現在の`post_url`の使い方について具体例を記す。

例として`_posts/2017/06/2017-06-26-life-in-the-fast-lane.md`へのリンクを貼る。

### うまくいかない例

まず[日本語ドキュメント](http://jekyllrb-ja.github.io/docs/templates/#post--url)には2つの例が載っている。

```markdown
{% raw %}{% post_url 2010-07-21-name-of-post %}{% endraw %}
```

```markdown
{% raw %}{% post_url /subdir/2010-07-21-name-of-post %}{% endraw %}
```

これを真似してリンクを貼ってみる。

```markdown
{% raw %}{% post_url 2017-06-26-life-in-the-fast-lane %}{% endraw %}
```

```
{% raw %}Deprecation: A call to '{{ post_url 2017-06-26-life-in-the-fast-lane }}' did not match a post using the new matching method of checking name (path-date-slug) equality. Please make sure that you change this tag to match the post's name exactly.{% endraw %}
```

ファイル名だけを指定しても一応動作するようだが、`_posts`直下でなくサブディレクトリ内の記事を指定するとDeprecationエラーが出る。
`_posts`直下にファイルがある場合はこれでも大丈夫。

```markdown
{% raw %}{% post_url /_posts/2017/06/2017-06-26-life-in-the-fast-lane %}{% endraw %}
```

```
{% raw %}Deprecation: A call to '{{ post_url /_posts/2017/06/2017-06-26-life-in-the-fast-lane }}' did not match a post using the new matching method of checking name (path-date-slug) equality. Please make sure that you change this tag to match the post's name exactly.{% endraw %}
```

こちらも動作はするもののエラーが出てしまう。

### 正しいっぽい書き方

```markdown
{% raw %}[test]({% post_url 2017/06/2017-06-26-life-in-the-fast-lane %}){% endraw %}
```

[test]({% post_url 2017/06/2017-06-26-life-in-the-fast-lane %})

このテンプレートでは`/2017/06/26/life-in-the-fast-lane.html`という文字列が生成される。
`{% raw %}{{ site.baseurl }}{% endraw %}`と組み合わせて

```markdown
{% raw %}{{ site.baseurl }}{% post_url 2017/06/2017-06-26-life-in-the-fast-lane %}{% endraw %}
```

とすると確実である。
わかれば簡単なことなのに、結構な時間迷っていた。
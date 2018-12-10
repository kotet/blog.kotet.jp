---
title: "Wordで暴れまわるD言語くん"
date: 2018-12-09
tags:
- dlangman
- advent_calendar
---

この記事は[D言語くん Advent Calendar 2018](https://qiita.com/advent-calendar/2018/d-man)
9日目の記事です。
友人を「特にネタがない？大丈夫大丈夫、締切を作ればなにか思いつくって！」
とテキトーに誘った結果、締切になっても何も思いつかなかったそうなので代わりに投稿です。

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">暴れまわるD言語くんでシェア取っていこうな <a href="https://t.co/zLXD7dOgLY">https://t.co/zLXD7dOgLY</a></p>&mdash; lempiji@思秋期 (@lempiji) <a href="https://twitter.com/lempiji/status/1072014058889469952?ref_src=twsrc%5Etfw">December 10, 2018</a></blockquote>

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">なるほど <a href="https://twitter.com/hashtag/dlangman?src=hash&amp;ref_src=twsrc%5Etfw">#dlangman</a> <a href="https://t.co/RwHcuVeZ5u">pic.twitter.com/RwHcuVeZ5u</a></p>&mdash; Kotet (@kotetttt) <a href="https://twitter.com/kotetttt/status/1072017983701053441?ref_src=twsrc%5Etfw">December 10, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

D言語くんの3DモデルをWordのドキュメントに貼り付けるのにちょっと作業が必要だったのでそれについて書きます。

### D言語くんの3Dモデル

[「D言語くん」 / ueshita さんの作品 - ニコニ立体](https://3d.nicovideo.jp/works/td28301)

<iframe src="https://3d.nicovideo.jp/externals/embedded?id=td28301" style="width: 485px; height: 385px;" frameborder="0" scrolling="no" allowfullscreen="allowfullscreen"><a href="http://3d.nicovideo.jp/works/td28301">D言語くん</a></iframe>

こちらD言語くん Advent Calendar 2016 2日目の3Dモデルです。
[煮るなり焼くなり好きにしろ](http://www.kmonos.net/nysl/)とのことなのでWordで暴れ回らせたいと思います。

### 変換

どうもダウンロード & 展開したそのままの状態ではうまく読み込めなかったので、いい感じにします。
まず展開した`Dman.fbx`をペイント 3Dで開きます。

![](/img/blog/2018/12/edit-with-paint3d.png)

するとこんな感じのアレがアレするので、`Dman.fbx`があるのと同じフォルダを開きます。

![](/img/blog/2018/12/texture-import.png)

テクスチャ（赤白黒の3色）がちゃんと貼られた状態で読み込まれます。

![](/img/blog/2018/12/dman-in-paint3d.png)

メニューから名前を付けて保存すると、Wordで開ける状態になっています。

### 完成

![](/img/blog/2018/12/a-lot-of-dman.png)

チラシにも、レポートにも、退職願にも。
文書のアクセントとしてD言語くんを解き放ち、すべてをぶち壊しましょう。おわり。
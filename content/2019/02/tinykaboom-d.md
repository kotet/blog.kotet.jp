---
title: "ライブラリ不使用、数百行でレイマーチングを行い爆発した"
date: 2019-02-15
tags:
- dlang
- tech
largeimage: /img/blog/2019/02/raymarching.jpg
---

レイマーチングという3Dレンダリング手法があります。
Wikipediaの記事もないくらい知名度の低い手法ですが、
簡単に説明すると描画したいオブジェクトの距離関数をもとにレイの衝突判定をするものです。
距離関数を書くことさえできればレイトレーシングと比べてはるかに複雑なものが描けるという特徴があります。
[フラクタル図形](https://cgworld.jp/feature/201602-kado01-cgw211.html)とか、
[雲とか](https://www.famitsu.com/news/201808/23162812.html)が描きやすいらしいですね。

### tinykaboom

そんなレイマーチングの仕組みのわかる学習用リポジトリがあります。

[ssloy/tinykaboom: A brief computer graphics / rendering course](https://github.com/ssloy/tinykaboom)

これは200行足らずのコードでレイマーチングを行い、爆発のようなものを描画します。
前回のレイトレーサーを前提に説明しているので、学習はその順番で行うといいでしょう。

### tinykaboom-d

そういうわけでDで書きました。
実行すると100枚のppm画像が出力されます。

![](/img/blog/2019/02/raymarching.jpg)

動画にするとこんな感じになります。

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">よしできた <a href="https://t.co/2h4D3G66f2">pic.twitter.com/2h4D3G66f2</a></p>&mdash; Kotet (@kotetttt) <a href="https://twitter.com/kotetttt/status/1095975324574134272?ref_src=twsrc%5Etfw">February 14, 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

作った感想ですが、レイトレーシングと違い物理法則に基づいたなにがしとかではないので新世界の神感はないです。
マジックナンバーもいっぱいです。
しかし上のリンクのようにアニメーションやゲームでは大いに役立ちます。

未だに少し処理を追えてなかったりコードの意図がわからないところもあるので今回はただの日記です。

---
date: 2017-11-08
title: "ニコニコ動画のプレーヤーを埋め込むJekyllテンプレート"
tags:
- jekyll
- tech
excerpt: "ニコニコ動画のプレーヤー等の埋め込みコードがようやく、ようやくHTTPSに対応した。ので、早速埋め込んでみる。"
---

ニコニコ動画のプレーヤー等の埋め込みコードがようやく、ようやくHTTPSに対応した。

[「動画埋め込みコード」HTTPS対応のお知らせ\|ニコニコインフォ](http://blog.nicovideo.jp/niconews/49321.html)

ので、早速埋め込んでみる。

### プレーヤー

```
<script type="application/javascript" src="https://embed.nicovideo.jp/watch/sm27881238/script?w=320&h=180"></script><noscript><a href="http://www.nicovideo.jp/watch/sm27881238">【AviUtl】もっと簡単に滑らかなアニメーションができるスクリプト</a></noscript>
```

<script type="application/javascript" src="https://embed.nicovideo.jp/watch/sm27881238/script?w=320&h=180"></script><noscript><a href="http://www.nicovideo.jp/watch/sm27881238">【AviUtl】もっと簡単に滑らかなアニメーションができるスクリプト</a></noscript>

動画は一度投稿すると修正できないため、時間がたつにつれてどんどん悪い点が目立って見えてくる。
たとえ今でも見に来た人が高く評価してくれるような動画であっても時々削除したい衝動と戦うくらいなのだが、精神の修行も兼ねてここはあえて自分の動画を使う。

そのまま貼り付けるとスマホなどで表示が崩れてしまうので小さめのものを貼っている。
特に問題なさそうである。

### 動画情報とサムネイル

```
<iframe width="312" height="176" src="https://ext.nicovideo.jp/thumb/sm27881238" scrolling="no" style="border:solid 1px #ccc;" frameborder="0"><a href="http://www.nicovideo.jp/watch/sm27881238">【AviUtl】もっと簡単に滑らかなアニメーションができるスクリプト</a></iframe>
```

<iframe width="312" height="176" src="https://ext.nicovideo.jp/thumb/sm27881238" scrolling="no" style="border:solid 1px #ccc;" frameborder="0"><a href="http://www.nicovideo.jp/watch/sm27881238">【AviUtl】もっと簡単に滑らかなアニメーションができるスクリプト</a></iframe>

一応対応できてるっぽいが、どうも執筆時点で以下の画像のようにコメントが見切れているようだ。
仕様ではないと思うのだが、HTTPバージョンの頃からこんな感じだったのかはわからない。

![スクショ](/assets/2017/11/08/screenshot.png)

### レスポンシブ対応とテンプレート化

動画情報は見切れているので、プレーヤーの方を使っていく。
せっかくなので大きいサイズのものを使いたいが、プレーヤーをこのまま埋め込むとスマホなど幅の狭いブラウザで見た時に縦幅が横幅に応じて変化せず邪魔な感じになる。

![スクショ](/assets/2017/11/08/longcat.png)

そこで以下のようなCSS（SASS）を書く。
"Youtube レスポンシブ"とかでググッて出てくるやつである。

```css
.nicovideo-wrapper {
  position: relative;
  width: 100%;
  padding-top: 66.67%; /* 480 / 720 */
}
.nicovideo-wrapper iframe {
  position: absolute;
  top: 0;
  right: 0;
  width: 100% !important;
  height: 100% !important;
}
```

そしてテンプレートを書く。
Javascriptを切った時のための`noscript`タグを削除したが、まあこのサイトはずっとJavascriptを切った時のことなど想定せずに作ってきたので今更問題ないだろう。

#### `_includes/nicovideo.html`

```html
<div class="nicovideo-wrapper">
    <script type="application/javascript" src="https://embed.nicovideo.jp/watch/{{ include.id }}/script"></script>
</div>
```

すると以下のように画面幅に合わせていい感じに縦横比を保ちつつ伸縮してくれるプレーヤーを埋め込むことができる。

```
{% include nicovideo.html id="sm27881238" %}
```

{% include nicovideo.html id="sm27881238" %}
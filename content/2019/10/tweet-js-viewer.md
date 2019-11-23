---
title: "Twitterデータの全ツイート履歴を見られるように簡易ビューアを作った"
date: 2019-10-12
tags:
- tech
---

Twitterには全ツイート履歴をダウンロードして閲覧する機能がありました。
しかし最近はJavascript(`.js`ファイル)
としてのデータだけを渡すようになり、一般ユーザーが閲覧する方法がなくなっているようです。
実際ググってみると「ツイート履歴 index ない」、「twitterデータ ダウンロード 見れない」、
「twitterデータ ダウンロード js」などが関連検索キーワードとして出てきたりします。

というわけでごくごく簡易的に全ツイートを見られるようなサイトを作りました。

[超簡易tweet.jsビューアー](https://kotet.jp/twitter-data-viewer/)

新しい「Twitterデータ」はツイート履歴だけではなく本当に「全データ」が得られるらしく、
なにを検索したか、どんな広告を閲覧したかや、これまでツイートやDMで送ってきた画像もすべてそのまま入っています。
今回はそのうち全ツイート履歴に相当する「`tweet.js`」だけを見るためのツールです。

### 使い方

[サイトにアクセスする](https://kotet.jp/twitter-data-viewer/)と以下のような素朴な選択画面が出てきます。

![](/img/blog/2019/10/file-choose.png)

ファイル選択ボタン(上の画像では"Choose File"と書かれているボタン)
をクリックするとファイル選択ダイアログが出てくるので、ダウンロードしてきたTwitterデータの中にある`tweet.js`を選択します。
すると少しの読み込み時間の後、ツイートが表示され始めます。

![](/img/blog/2019/10/tweet-list.png)

「Show details」ボタンを押すとその場にツイートが埋め込まれ、詳しい情報を見ることができます。

![](/img/blog/2019/10/show-details.png)

全ツイートを一度に読み込み一度に表示するので、大量のメモリを消費します。
大量と言っても`tweet.js`の数倍程度なのですが、普段からメモリが足りなくて動作が重いような人には厳しいかもしれません。

### おわりに

この素朴さではたしてどれくらいの人の役に立つのか疑問ですが、とにかく作りました。
Twitterが公式に閲覧方法を用意してくれればそちらを使えばいいし、
もし公式からビューアが現れることが今後なかったとしても誰かがもっと便利で多機能なビューアを作ってくれるでしょう。
作ってくれるはずです。
誰か作ってください。

このビューアがそれまでのつなぎになってくれると良いなと思いました。
動かない等なにか問題があれば[Twitter(@kotetttt)](https://twitter.com/kotetttt)まで連絡ください。

### 追記: 他の人が作ったビューア

記事の公開からしばらく経ちますがアクセスが途切れることがありません。
かなりの人が困っているんだろうなと感じます。

そろそろ他の人もビューアを公開し始めているので紹介しようと思います。
自分のビューアはこれ以上の機能追加等を行う予定はないので、
機能不足を感じたら以下のビューアも試してみてください。

#### オンライン

Webサイトに`tweet.js`をアップして処理するタイプです。

- [Twitterデータの tweet.js を読み込んで全ツイート履歴を表示するツール「tweet.js loader」を作った - to-me-mo-rrow - 未来の自分に残すメモ -](https://r17n.page/2019/10/22/tweet-js-loader-introduction/index.html)
- [tweet.js Web](http://all-tweets-history.0so.tokyo/)
- [Tweet見る](https://json2html-94a7c.firebaseapp.com/)
- [Twitterデータのツイートをリツイート順に並べるやつ](https://shiosyakeyakini.info/TwitterDataTool/)

#### オフライン

`tweet.js`のあるフォルダと同じ位置に保存して開くタイプです。

- [Twitter archive browser](https://gist.github.com/tiffany352/9ee7e0d4fd7e08ede9d0314df9eab672)

<blockquote class="twitter-tweet" data-conversation="none"><p lang="ja" dir="ltr">捨てる神あれば拾う神あり<br><br>有志がつくってくれた index.html を使ってとりあえずブラウザで「全ツイート履歴」を閲覧・検索できた<br><br>引用したツイのリンク先を開いて Ctrl+s で index.html として保存。それを全ツイート履歴のトップフォルダに放り込めばいいみたい<a href="https://t.co/P51UmWTu2n">https://t.co/P51UmWTu2n</a></p>&mdash; ォヶラ (@okerror) <a href="https://twitter.com/okerror/status/1193690101622001664?ref_src=twsrc%5Etfw">November 11, 2019</a></blockquote>

---

[@okerror](https://twitter.com/okerror)から情報提供をいただきました。
上のオフラインビューアの作者が専ブラを作り始めたようです。

- [tiffany352/twitter-archive-browser: Desktop app for browsing your Twitter Archive](https://github.com/tiffany352/twitter-archive-browser)

リリースページはこちら: [Releases · tiffany352/twitter-archive-browser](https://github.com/tiffany352/twitter-archive-browser/releases)

<blockquote class="twitter-tweet" data-conversation="none"><p lang="ja" dir="ltr">インストール方法メモ(Win10)<br><br>1) リンク先で最新バージョンのタイトルをクリック（現在だとAlpha 3）<br><br>2) Twitter-Archive-Browser-Setup-(version).exe をダウンロード<br><br>3) 保護云々と出たら詳細情報→実行<br><br>Releases · tiffany352/twitter-archive-browser · GitHub <a href="https://t.co/e7CxOc4fdH">https://t.co/e7CxOc4fdH</a></p>&mdash; ォヶラ (@okerror) <a href="https://twitter.com/okerror/status/1197830319413481472?ref_src=twsrc%5Etfw">November 22, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

![](/img/blog/2019/10/2019-11-23-0.png)

Twitterデータのzipファイル、またはそれを展開したフォルダをドラッグ&ドロップすることで閲覧ができるようになります。
執筆時点ではzipファイルを渡すとクラッシュしてしまうようなので、展開したフォルダを渡してあげましょう。

![](/img/blog/2019/10/2019-11-23-1.png)

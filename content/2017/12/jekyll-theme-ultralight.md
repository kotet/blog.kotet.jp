---
date: 2017-12-27
title: "超軽量、IPFS対応レスポンシブJekyll theme ”ultralight”を作った"
tags:
- jekyll
- ipfs
- tech
excerpt: "CNNの低帯域の人向けのテキストオンリーのサイトlite.cnn.ioを見た。 とても軽い。 しかしニュースを快適に閲覧するための要素はすべて満たしており、むしろ色々くっついたオリジナルのCNNよりも見やすいかもしれないと思った。"
image: 2017/12/27/twitter.png
---

CNNの低帯域の人向けのテキストオンリーのサイト[lite.cnn.io](http://lite.cnn.io/)を見た。
とても軽い。
しかしニュースを快適に閲覧するための要素はすべて満たしており、むしろ色々くっついた[オリジナルのCNN](http://edition.cnn.com/)よりも見やすいかもしれないと思った。

自分のサイトは[Minima](https://github.com/jekyll/minima)ベースのJekyll themeを使っていた。
名前の通りかなりシンプルなThemeなのだが、lite.cnn.ioを見ているとこれすらも過剰に見えてきた。
自分のサイトに来る人が見ているのは記事、主にその中のプレインテキストであって、画面幅によってハンバーガーメニューに変わるページのリストではないはずだ。

また、将来このサイト全体をIPFSでホストすることを考えると、それを考慮していないThemeを使うのは大変そうだ。
現在のIPFSでは同じコンテンツでも`ipfs.io/ipns/ipfs.io`、`ipfs.io/ipfs/QmQrX8hka2...`、
`localhost:8080/ipfs/QmQrX8hka2...`のようにドメインやパスがコロコロ変わるため、
それらすべての環境で閲覧できるようにするには内部リンクを相対パスにしておく必要がある。
既存のThemeを使うなら、サイト内のコンテンツのURLをすべて探し出して書き換えなければならない。

そこで、[lite.cnn.io](http://lite.cnn.io/)、[Motherfucking Website](http://motherfuckingwebsite.com/)、
[Better Motherfucking Website](http://bettermotherfuckingwebsite.com/)などを参考にJekyll theme "ultralight"を作った。
そして現在このサイトではそのThemeを使っている。

### 無くしたものと残したもの

旧サイトから様々なものが無くなった。

たとえばシェアボタン群、これは旧サイトでも使おうとしたときだけ読み込むことでかなり軽量化されていた。
しかしそもそも自分でさえ使わないものがほとんどなのでなくすことにした。
ブックマークレットとかブラウザ備え付けのシェア機能とかを使えばいいし、自分はシェアボタンがあっても無視してそうしていた。

スタイルも最小限にしてある。
全部足してもそれほど大きくなく、ひょっとして工夫して遅延読み込みしなくても
[ATFコンテンツが14kb未満](https://developers.google.com/speed/docs/insights/mobile?hl=ja)
になっているのではないかと思いすべてHTMLに埋め込んでみた。

また、ヘッダやフッタの線は`border`ではなく`<hr>`である。
これによって[Lynx](https://ja.wikipedia.org/wiki/Lynx_(%E3%82%A6%E3%82%A7%E3%83%96%E3%83%96%E3%83%A9%E3%82%A6%E3%82%B6))
などのテキストベースブラウザでも同じように表示される。
というか今試したらあまりにも正常に表示されてびっくりした。

![スクショ](/assets/2017/12/27/lynx.png)

コンテンツの中央寄せ、幅の制限、コードブロックのシンタックスハイライトは残している。
これはやっておかないと見るときストレスになるし、閲覧者側での対処が大変だからだ。

### 結果

このようにゼロから最低限必要な要素のみを選んで追加していった結果、情報量が少ないとはいえGitHub Pages単体でultralightのデモのPagespeedが100点になった。

![スクショ](/assets/2017/12/27/pagespeed.png)

また、[www.webpagetest.org](https://www.webpagetest.org)でSpeed Indexを計測したところ、阿部寛とGoogleの中間的な結果になった。
ダイヤルアップ回線でも[1秒台でファーストビューである](https://www.webpagetest.org/result/171227_Y6_52a1bff263c001164ab06ffb530567c2/)。

| abehiroshi.la.coocan.jp/ | google.com | kotet.github.io/ultralight/ | kotet.github.io |
|--------------------------|------------|-----------------------------|-----------------|
| 258                      | 631        | 300                         | 351             |

阿部寛が強すぎる……

### IPFS

すべての内部リンクは相対リンクになっている。
来年あたり常時稼働できるIPFSノードを作る予定なので、そのときには特に工夫しなくてもこのサイトをIPFS上でホストできるだろう。
一つ気になるのが、トラッカーや広告がIPFS上でどのように振る舞うかだ。
少なくともGoogle AnalyticsとA-adsは不特定多数のドメインでアクセスできるサイトというのを考慮した作りにはなっていない気がする。

### Jekyll Themes

ultralightは現在[Jekyll Themes](http://jekyllthemes.org/)へ追加リクエスト中である。

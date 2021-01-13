---
title: "Chrome Extensionのアクセス権を切り詰める"
date: 2021-01-13
tags:
- tech
- log
---

このブログは自分の日記でもあるので、小ネタをポコポコ書いていくのも大事だと思った。

### デジタル盆栽

最近、作業に使っているコンピュータの消費電力をできるだけ減らすというか、全体的に動作を軽くする遊びをしている。
もともとエネルギー効率のいい生活が好きだし、
趣味、仕事、学生生活すべてで使うコンピュータのリソースを最適化することで生産性の向上につながることもあるかもしれない。
たぶん。
おそらくデスクトップ環境をGnomeから変えるのがいちばんCPU時間やメモリ使用量を削減できる方法だが、
今の使い勝手を変えるような変更はできるだけ行わない。

たとえば、端末上に情報を表示する各種ソフトウェアを自作の高速なものに置き換えたりしている。
powerlineは自分の用途の割に機能が多すぎるし、Pythonで書かれている。
tmuxのステータスバーも、コマンドを組み合わせるのではなく項目ごとに適切な更新頻度で情報を取得する自作のソフトウェアに置き換えた。
プロンプトに関しては（powerlineの設定がおかしかったというのもあるが）明らかにレイテンシが改善した。

### Chromeを軽くする

そういうわけでChromeの拡張機能もかなり切り詰めている
（Chromeを使うのをやめると一番効果的だがこれは遊びなのでそういうことはしない）。
たまにしか使わないものは使うときだけ有効化するようにしたり、可能なものはブックマークレットにしたりした。
今有効になっている拡張機能は
- [LINE](https://chrome.google.com/webstore/detail/line/ophjlpahpchlmihnnnihgmmeilfjmjjc)
（Linux上でLINEを使ういい方法を探している。最近見かけたAndroidエミュレータとかどうなんだろうか？）
- [Enpass](https://chrome.google.com/webstore/detail/enpass-extension-requires/kmcfomidfpdkfieipokbalgegidffkal)
（パスワードマネージャ。もはやこれが無いとインターネット上で手足を失うのに等しい）
- [Instapaper](https://chrome.google.com/webstore/detail/instapaper/ldjkgaaoikpmhmkelcgkgacicjfbofhh)
（ブックマークレットの使い勝手が悪かったので拡張機能を使っている）
- [Tampermonkey](https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo)
（[AtCoder用の情報表示スクリプト](https://greasyfork.org/ja/scripts/369954-ac-predictor)を動かしている）

の4つだけになった。

### Chrome Extensionのサイトアクセス権限

さて、ここからさらになにか削れないだろうか。
そう考えたときに"Site access"の項目が気になった。
LINEもInstapaperも、あらゆるサイトにアクセスする権限があるように見える。
当然、これらの拡張機能は動くときしか動かないようになっているはずだが、なんとなく気持ち悪い。
これを制限したところで負荷が変わるかどうか怪しいが、これは遊びなので計測はしないし、気持ち悪さだけで理由は十分である。

というわけでアクセス権を"On click"に変更してみたら、LINEもInstapaperも動かない。

Tampermonkeyはスクリプトが動いている`https://atcoder.jp/*`を指定したら問題なく動いた。
スクリプトがデータを取得してくるらしい`https://data.ac-predictor.com/*`も許可する必要があるかもしれない。
Tampermonkeyのように、必要なサイトだけ許可するようにできないだろうか？

Chrome拡張はDeveloper modeをオンにするとインスペクタを開ける。
Site accessを"On click"にしたまま拡張機能を動かし、エラーメッセージに出てきたドメインを許可するリストに追加していく。
そうして判明した許可すべきサイトが以下である。
今回書きたかったのはこれだけなので、この記事はここで終わり。
だれかの役に立つと良いなと思う。

- LINE:
    - `https://*.line.naver.jp/*`
- Instapaper:
    - `https://www.instapaper.com/*`

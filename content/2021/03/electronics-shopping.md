---
title: "電子工作日記: LEDのデータシートを読む"
date: 2021-03-20
tags:
- electronics
- tech
- log
---

ブログを書かなければならない。なぜか。
定期的に更新しないとブログのリニューアルが全然進まないからだ。

### 電子工作をしよう

自分が配属された研究室はかなりハードウェア寄りで、
今は卒業研究が始まる前の勉強としてArduino互換ボードを作ったり集積回路を設計したりしている。
しかし自分は電子回路の知識がほぼない。
回路に関する講義はあったが、ついていくのが大変、というかついていけていなかった気がする。
はんだごてをまともに使った記憶は小学生くらいのときに行った電子工作教室でうっかり太ももをやけどしたところで止まっている。
そんな状態で集積回路の設計ができるだろうか、いやできない（反語）というわけで電子工作を始めることにした。

研究室で必要になるからということ以外にも電子工作を始める理由がある。
ちょっとした電子工作で生活を豊かにしたいのだ。
自分は困ったことがあるとプログラムを書いて解決することがある。
あらゆるサイトを統一したフォーマットでツイートしたいとき、
今見ているページのURLをmarkdownのリンクにしたいとき、
AtCoderのコンテストをカレンダーに登録したいとき、
そんなときブックマークを書けばワンクリックで解決できるボタンになる。
ウェブサイトの色やレイアウトがあまりにも見づらいときも自分で調整できる。
ウェブブラウザのようなみんなが使っているツールの困りごとをそんなふうに解決できたとき、
プログラミングができてよかったと心から思うことができる。
ハードウェアでもそういうことができたら最強だと思う。

せっかくブログのネタになりそうだし、学習ノートを作るかわりにここにいろいろ書き込んでいこうと思う。
たくさん書いてれば他の人の役に立つ記事も出てくるんじゃないかな、知らんけど。
本当に初心者なので変なことを書くかもしれない。
誤情報があれば教えてくれればすぐ直すので教えて欲しい。

### 道具を揃える

小学生のころに電子工作教室に連れて行かれる程度には親が電子工作をしていたため、既にいくつか機材がある。
出してきてもらったところ、はんだごてがあった。はんだごて台があった。はんだごて台にくっついてるスポンジはなくなっていた。
他にはブレッドボードやテスターも揃っていた。
まずはこのブレッドボードでいろいろ試す感じになるだろう。

しかし抵抗やコンデンサ等の基本部品がない。
というわけで
[電子工作基本部品セット](https://www.amazon.co.jp/dp/B01MFBMX8A)
を買った。
色々入ってるのでたぶんなんとかなるだろう。

あと秋月電子で
[替スポンジ](https://akizukidenshi.com/catalog/g/gT-13608/)や
[はんだ](https://akizukidenshi.com/catalog/g/gT-02594/)
を買った。
ちょくちょく名前が出てくるので存在は知っていたが、こんなに素朴なサイトだとは思わなかった。

電源は電池3本を直列接続できる電池ケースがあったが、作ったものがUSB電源で動いてほしい。
電池には問題が起きたときに電池ケースと電池がダメになるだけで済むという利点があるが、
USB接続の回路でやらかしたときに考えられる最大の被害はどれくらいだろうか？
USB充電器につないだままやらかしたら家全体が停電したりするだろうか？
この質問に自信を持って答える知識を今の自分は持っていないので、
とりあえず世の回路設計士たちが先回りして自分を守ってくれていると信じて
[電源用マイクロUSBコネクタDIP化キット](https://akizukidenshi.com/catalog/g/gK-10972/)
を買った。

### LEDを光らせたい

電子工作のHello Worldといえばなんだろう、Lチカとかだろうか。
しかしLチカは太ももをやけどするのでやりたくない。
そもそもLEDを満足に光らせられるかどうか怪しいのでそこから始めよう。

#### データシートを読む

この[適当に選んだ白色LED（OSPW5111A-YZ）](https://akizukidenshi.com/catalog/g/gI-01973/)
を光らせるにはどうすればいいか考えてみる。
LEDにかかる電圧を順方向電圧効果$\mathrm{V_F}$という。
そして順方向電圧をかけたときに流れる電流を順方向電流$\mathrm{I_F}$という。
LEDを光らせるためにはある一定の範囲の電圧をかける必要がある。

データシートを見てみると
Absolute Maximum Rating
と
Electrical-Optical Characteristics
という2つの表がある。
前者は許容できる最大値なので超えないように気をつける必要がある数値だ。
このブログを書くまでこの数値を基準に抵抗を計算していた。
ブログ書いてみて本当に良かった。

重要なのは後者で、これはある条件下でLEDがどのような挙動をするかを書いたものだ。
表には順方向電流$\mathrm{I_F}=20\mathrm{mA}$のときの挙動が書かれている。
$\mathrm{V_F}$の最小値が2.8V、最大値が4.0Vとかなり振れ幅が大きいが、
多分保証値という意味で広めにしていて、実際の分布はそんなでもないんだろう。たぶん。

#### 抵抗を選ぶ

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="302px" height="165px" viewBox="-0.5 -0.5 302 165" style="background-color: rgb(255, 255, 255);"><defs></defs><g><path d="M 200 80 L 245 80 M 255 50 L 255 110 M 255 80 L 300 80" fill="none" stroke="#000000" stroke-miterlimit="10" transform="translate(250,0)scale(-1,1)translate(-250,0)" pointer-events="all"></path><rect x="241" y="65" width="4" height="30" fill="#000000" stroke="#000000" transform="translate(250,0)scale(-1,1)translate(-250,0)" pointer-events="all"></rect><g transform="translate(-0.5 -0.5)"><switch><foreignObject style="overflow: visible; text-align: left;" pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe flex-start; justify-content: unsafe center; width: 1px; height: 1px; padding-top: 117px; margin-left: 250px;"><div style="box-sizing: border-box; font-size: 0; text-align: center; "><div style="display: inline-block; font-size: 12px; font-family: Verdana; color: #000000; line-height: 1.2; pointer-events: all; white-space: nowrap; ">V=5V</div></div></div></foreignObject><text x="250" y="129" fill="#000000" font-family="Verdana" font-size="12px" text-anchor="middle">V=5V</text></switch></g><rect x="100" y="70" width="100" height="20" fill="none" stroke="none" pointer-events="all"></rect><path d="M 100 80 L 118 80 L 122 70 L 130 90 L 138 70 L 146 90 L 154 70 L 162 90 L 170 70 L 178 90 L 182 80 L 200 80" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="all"></path><g transform="translate(-0.5 -0.5)"><switch><foreignObject style="overflow: visible; text-align: left;" pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe flex-end; justify-content: unsafe center; width: 1px; height: 1px; padding-top: 67px; margin-left: 150px;"><div style="box-sizing: border-box; font-size: 0; text-align: center; "><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: #000000; line-height: 1.2; pointer-events: all; white-space: nowrap; ">R</div></div></div></foreignObject><text x="150" y="67" fill="#000000" font-family="Helvetica" font-size="12px" text-anchor="middle">R</text></switch></g><rect x="0" y="50" width="100" height="65" fill="none" stroke="none" transform="rotate(-180,50,82.5)" pointer-events="all"></rect><path d="M 30 55 L 70 85 L 30 115 Z M 0 85 L 30 85 M 70 55 L 70 115 M 80 57 L 87 50 M 87 53 L 87 50 L 84 50 M 70 85 L 100 85" fill="#ffffff" stroke="#000000" stroke-miterlimit="10" transform="rotate(-180,50,82.5)" pointer-events="all"></path><path d="M 0 79.9 L 0 0 L 300 0 L 300 80" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="stroke"></path><path d="M 0 120 L 0 140 M 100 120 L 100 140 M 0 130 L 100 130" fill="#ffffff" stroke="#000000" stroke-miterlimit="10" pointer-events="all"></path><g transform="translate(-0.5 -0.5)"><switch><foreignObject style="overflow: visible; text-align: left;" pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe flex-start; justify-content: unsafe center; width: 98px; height: 1px; padding-top: 147px; margin-left: 1px;"><div style="box-sizing: border-box; font-size: 0; text-align: center; "><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: #000000; line-height: 1.2; pointer-events: all; white-space: normal; word-wrap: normal; ">V<sub>F</sub>=3.4V (20mA)</div></div></div></foreignObject><text x="50" y="159" fill="#000000" font-family="Helvetica" font-size="12px" text-anchor="middle">VF=3.4V (20mA)</text></switch></g><path d="M 100 120 L 100 140 M 200 120 L 200 140 M 100 130 L 200 130" fill="#ffffff" stroke="#000000" stroke-miterlimit="10" pointer-events="all"></path><g transform="translate(-0.5 -0.5)"><switch><foreignObject style="overflow: visible; text-align: left;" pointer-events="none" width="100%" height="100%" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: flex; align-items: unsafe flex-start; justify-content: unsafe center; width: 98px; height: 1px; padding-top: 147px; margin-left: 101px;"><div style="box-sizing: border-box; font-size: 0; text-align: center; "><div style="display: inline-block; font-size: 12px; font-family: Helvetica; color: #000000; line-height: 1.2; pointer-events: all; white-space: normal; word-wrap: normal; ">V<sub>R</sub></div></div></div></foreignObject><text x="150" y="159" fill="#000000" font-family="Helvetica" font-size="12px" text-anchor="middle">VR</text></switch></g></g><switch><g requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"></g><a transform="translate(0,-5)" xlink:href="https://www.diagrams.net/doc/faq/svg-export-text-problems" target="_blank"><text text-anchor="middle" font-size="10px" x="50%" y="100%">Viewer does not support full SVG 1.1</text></a></switch></svg>

というわけで、図のような回路を組んでLEDに適切な電圧をかけよう。
閉回路中の電圧降下の総和は起電力に等しい（キルヒホッフの法則）ので、
$\mathrm{V_F} + \mathrm{V_R} = \mathrm{V}$
という関係が成り立ち、これを解いて抵抗Rの電圧降下
$\mathrm{V_R} = \mathrm{V} - \mathrm{V_F} = 5.0-3.4 = 1.6$（V）を得る。
流したい電流も決まっているので、オームの法則から必要な抵抗値
$\mathrm{R}=\frac{1.6}{20\times 10^{-3}} = 80$Ωが求められた。

さて、先程買った部品セットに80Ωの抵抗は……ない。
ちょうどの抵抗を作ろうと思うと10Ωを8つ直列につなぐ等しなければならない。
しかし[秋月電子の公開しているPDF](https://akizukidenshi.com/download/led-r-calc.pdf)
の例を見てみると、1780Ωの抵抗が求められるところで1.5kΩや2kΩの抵抗が近似値として使えると書いてある。
十数パーセント程度の違いは誤差としていいということだろうか？

ここで商品画像の袋に貼られているシールを見てみると、
データシートに書かれていないVf: 2.9-3.6Vという情報が載っていた。
電圧をこの範囲に広げて再度計算してみると、$70<\mathrm{R}<155$（Ω）になる。
部品セットの抵抗の中で一番80Ωに近い100Ω抵抗はこの範囲に収まっているので大丈夫そうだ。
……本当に？流れる電流を固定して計算したがそれで良いのだろうか？

もうわからない。
買ったものは10個セットなので、実物が届いてから壊す勢いでいろいろ試してみることにしよう。
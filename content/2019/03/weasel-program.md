---
title: "無限の猿とイタチのプログラム"
date: 2019-03-22
tags:
- dlang
- tech
---

マシュー・サイドの「失敗の科学（原題：Black Box Thinking）」
を読んでいたらリチャード・ドーキンスの「盲目の時計職人」を参照したこのような一文がありました。

> もしタイプライターの鍵盤を猿がランダムに打ったとしたら、シェイクスピアの『ハムレット』の一節、
> "Methinks it is like a weasel"（おれにはイタチのようにも見えるがな）
> を打ち出す確率は一体どのくらいだろう？
>
> （中略）
> ここで登場するのが累積淘汰のメカニズムだ。
> まず、ドーキンスは猿が打つようなランダムな文章が
> 自動的に次々と生成されるコンピューター・プログラムを作った。
> しかしこのプログラムは、生成したデタラメな文章をその都度チェックして、目標の一節に
> （たとえわずかにでも）一番近いものだけを選択し、残りを全て排除する。
> そして選択した文章にはランダムな変化を加え―つまり突然変異を起こして―次世代の文章を作り上げ、
> そのあとまた同様のチェックを続けていく。
>
> （中略）
> そして最終的に、43世代目で、プログラムは正解を叩き出した。
> かかった時間は、ほんの30分だった。

「累積淘汰」があると単純なランダムよりも遥かに早く正解に近づくことができるという話です。
面白い話を聞きました。
ここに登場するプログラムはイタチのプログラム（Weasel program）などと呼ばれ、
単純になった遺伝的アルゴリズムのようなものです。
早速試してみましょう。

### 無限の猿定理

まず、単純なランダムでシェイクスピアの一節が現れる確率について考えてみましょう。
話を単純にするため、大文字と小文字を無視して`METHINKS IT IS LIKE A WEASEL`が出る確率を考えます。
この文章は空白も合わせると28文字あります。
AからZまでのアルファベットと空白の27種類の中からランダムに文字を28回選んで
`METHINKS IT IS LIKE A WEASEL`になる確率は、

$$ (\frac{1}{27})^{28} \fallingdotseq \frac{1}{1.197 × 10^{40}} $$

というわけで約1正分の1となります。
「正」が見慣れなさすぎて数字の単位として認識できませんね。
まず現実的な時間では無理でしょう。

### Weasel program

[Weasel program - Wikipedia](https://en.wikipedia.org/wiki/Weasel_program)

そこで冒頭のプログラムです。
ランダムなのは変わりませんが、世代ごとに正解と近いものを選んで変化させていきます。

というわけで完成したものがこちらになります。
120行にも満たないシンプルなプログラムです。

[kotet/weasel-program: D implementation of Richard Dawkin's weasel program.](https://github.com/kotet/weasel-program/tree/master)

実行してみるとあっという間に正解に近い文が出来上がっていく様子が見られます。

```console
$ dub run -q
Number of offspring per generation: 1000
Mutation rate: 0.090000
Target:   "METHINKS IT IS LIKE A WEASEL" (28 characters)
Gen 0000: "BQZTMLHTHYEDLFQAOITXXILNATPK" (score: 1)
Gen 0001: "BQZTMLHTHYEDLS AOITXXILYATPK" (score: 3)
Gen 0002: "BQZTMLHTHBTDLS AOITXXILNATZK" (score: 4)
Gen 0003: "BQZTMLHSH TDLS AIITXXILNATZK" (score: 6)
Gen 0004: "BQZTILHSH TDLS AIKVXXILNATZK" (score: 8)
Gen 0005: "BLZTINASH TDLS AIKVXXILNATEK" (score: 10)
Gen 0006: "BSWTINASH TDLS AIKEXXILNATEK" (score: 11)
Gen 0007: "BEWTINASH TDLS AIKENXIWNATEK" (score: 13)
Gen 0008: "BEWTINASH T LS AIKENXIWNATEK" (score: 14)
Gen 0009: "BEWTINAS  T LS AIKEXX WQATEK" (score: 16)
Gen 0010: "BEWTINAS RT LS AIKEXX WEATEK" (score: 17)
Gen 0011: "BEWTINAS RT LS AIKE X WEATEK" (score: 18)
Gen 0012: "BEWTINAS RT LS AIKE X WEATEL" (score: 19)
Gen 0013: "BETTINAS RT LS AIKE X WEATEL" (score: 20)
Gen 0014: "BETPINKS RT LS AIKE X WEATEL" (score: 21)
Gen 0015: "METPINKS RT LS AIKE X WEAJEL" (score: 22)
Gen 0016: "METPINKS OT XS AIKE X WEAJEL" (score: 22)
Gen 0017: "METPINKS OT IS AIKE X WEAJEL" (score: 23)
Gen 0018: "METHINKS OT IS VIKE X WEAJEL" (score: 24)
Gen 0019: "METHINKS IT IS VIKE X WEAJEL" (score: 25)
Gen 0020: "METHINKS IT IS VIKE X WEAJEL" (score: 25)
Gen 0021: "METHINKS IT IS VIKE A WEAJEL" (score: 26)
Gen 0022: "METHINKS IT IS VIKE A WEAJEL" (score: 26)
Gen 0023: "METHINKS IT IS VIKE A WEAJEL" (score: 26)
Gen 0024: "METHINKS IT IS VIKE A WEAJEL" (score: 26)
Gen 0025: "METHINKS IT IS JIKE A WEAHEL" (score: 26)
Gen 0026: "METHINKS IT IS LIKE A WEAHEL" (score: 27)
Gen 0027: "METHINKS IT IS LIKE A WEASEL" (score: 28)
```

ドーキンスが試した時は30分かかったようですが、四半世紀以上が経った現代では1秒もかかりません。

### パラメータを変化させてみる

1世代に生成する子孫の数を増やすと正解までの世代数は少なくなりますが、ある点から効果が弱くなっていきます。
以下の例では子孫の数を10倍にしていますが世代数は3しか減っていません。

```console
$ dub run -q -- -n 10000
Number of offspring per generation: 10000
Mutation rate: 0.090000
Target:   "METHINKS IT IS LIKE A WEASEL" (28 characters)
Gen 0000: "NRPZCGNDRLEWNMKRBZ LBXMAWLIG" (score: 0)
(中略)
Gen 0016: "METHINKS IT IS LIKE A WEASEL" (score: 28)
```
```console
$ dub run -q -- -n 100000
Number of offspring per generation: 100000
Mutation rate: 0.090000
Target:   "METHINKS IT IS LIKE A WEASEL" (28 characters)
Gen 0000: "ZIGHRAJPZW FRXCTW NWWZB LBWO" (score: 1)
(中略)
Gen 0013: "METHINKS IT IS LIKE A WEASEL" (score: 28)
```

ターゲット文字が長くなるとなかなか正解に到達しなくなります。
おそらくまだ正解と異なる場所が変異する確率に対して、
すでに正解と同じになっている場所の変異してしまう確率が大きくなってしまうのが原因です。

```console
$ dub run -q -- -t "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
Number of offspring per generation: 1000
Mutation rate: 0.090000
Target:   "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" (66 characters)
Gen 0000: "O HQGRSNFJTFDXZFGXJSBFWWLZISBZR BLTIQGCIJHJUZJEOPRANLIDCLFDKOJGTDC" (score: 1)
(中略)
Gen 1400: "AAAAAAAACAAAAAAAZAAAAAAAATAAAAAAAAAAAAABAVAAAAAAAAAAAAAAAAAAAAAAAA" (score: 61)
Gen 1401: "AAAAAAAACAAAAAAAZAAAAAAAATAAOAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 61)
Gen 1402: "AAAAAAAAXAAAAAAASAAAAAAAATAAOAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 61)
Gen 1403: "AAAAAAAAXAAAAAAASAAAAAAAATAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1404: "AAAAAAAAXAAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1405: "AAAAAAAAXAAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1406: "AAAAAAAAXAAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1407: "AAAAAAAA AAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1408: "AAAAAAAA AAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1409: "AAAAAAAA AAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1410: "AAAAAAAA AAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1411: "AAAAAAAA AAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1412: "AAAAAAAA AAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1413: "AAAAAAAA AAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1414: "AAAAAAAA AAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1415: "AAAAAAAA AAAAAAASAAAAAAAAAAAAAAAMAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1416: "AAAAAAAA AAHAAAASAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1417: "AAAAAAAA AAHAAAAKAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1418: "AAAAAAAA AAFAAAAKAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1419: "AAAAAAAA AAFAAAAKAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
Gen 1420: "AAAAAAAA AAFAAAAKAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 62)
```
変異率を適度に下げると正解が出てきます。

```console
$ dub run -q -- -r 0.001 -t "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
Number of offspring per generation: 1000
Mutation rate: 0.001000
Target:   "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" (66 characters)
Gen 0000: "RTNQVNLBBIDITHD QMRATFHMZNZIKIXLMKSN PSYGI GJAKCQCAHKPPUZRERZLINMU" (score: 3)
(中略)
Gen 0161: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" (score: 66)
```

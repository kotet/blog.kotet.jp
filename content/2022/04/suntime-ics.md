---
title: "日の出と日の入りの時刻をGoogle Calendarで表示するためにicsファイルを生成する"
date: 2022-04-17
tags:
  - python
  - tech
---

任意の地点の日の出と日の入りの時刻を計算して、Googleカレンダーに追加できる形式のファイルを生成するツールを作った。
この記事では製作過程の記録と、使い方の説明を書く。

---

**追記**: このページを見てくれる人がそれなりにいるっぽいので、非プログラマ向けにICSファイル配布サイトを作った。

[世界と日本の日の出と日の入りカレンダー - KotetJP](https://kotet.jp/suntime-ics-distribution/)

様々な地方について、iCal形式のカレンダーのURLがコピーできる。たとえば愛知県はここ。

[愛知県庁の日の出と日の入り - KotetJP](https://kotet.jp/suntime-ics-distribution/japan/23/)

Googleカレンダーには以下のヘルプの「リンクを使用して一般公開のカレンダーを追加する」の手順で追加できる。

[他のユーザーの Google カレンダーに登録する - パソコン - Google カレンダー ヘルプ](https://support.google.com/calendar/answer/37100)

---

### 前提

最近天気の悪い日や暗いときに気分がめちゃくちゃ落ち込んだり、体調が悪くなるようになった。
暗い時間帯に起き続けるコストが跳ね上がっているうえに、起きていても対して生産的なことはできない。
おいしいものとアルコールで気を紛らすことにひたすら時間が費やされるだけだ。
というわけで暗くなったら寝る生活を心がけたい。

そのために、日の出と日の入りの時刻を把握することが必要になった。
いつも使っているGoogleカレンダーに表示するようにしたいのだが、調べて出てくるものは微妙に使い勝手が悪い。
[わりと理想に近いサービス](https://github.com/allanlaal/sunrise-calendar-feed)
を公開している人はいたが、運用が止まってしまっている。
仕方がないので自作することにした。

### 仕様を考える

Googleカレンダーはicsというフォーマットを解釈できる。
このフォーマットのファイルをウェブ上に公開すると、それを「URLで追加」で購読して追加できる。
この場合RSSのように自動更新もできる。
独立したカレンダーとして追加されるので、表示・非表示の切り替えもしやすい。

ローカルで生成したicsファイルは「インポート」で読み込んで、その中の予定を既存のカレンダーに追加できる。
こちらはおそらく他のカレンダーアプリケーションからの乗り換えを想定したもので、新しいカレンダーが生成されるのではなく、既存のカレンダーに予定が追加される。
操作を間違えたり、間違った予定を大量に追加してしまったりすると元に戻すのが大変かもしれない。
今回の使い方の場合、日の出・日の入り専用のカレンダーを作成し、そこに予定をインポートするといいだろう。

上で言及した既存のサービスはPHPで書かれており、リクエストのたびにパラメータで指定した座標における日の出・日の入りの時刻を計算してicsデータを生成している。
また、GoogleのAPIを使って座標に応じたタイムゾーンを取得しているようだ。
運用が止まってしまっているのは、やはりPHPを動かし続けるサーバや、APIの権限の管理が負担だったのだろうか。
世界中で需要のあるサービスなので、アクセス数も相当大きかっただろう。
データを動的に生成するやり方は持続可能ではないということだ。

先人の失敗から学び、データは静的に生成するようにしよう。
ここで、更新を定期的に行う仕組みを作って配信してもいいが、個人的に使う分には一度生成すれば数年使い続けられるため、自動更新はまた元気のある時に考える。

### 作る

というわけで、日の出と日の入りの時刻のicsファイルを生成するツールを作る。
既存のライブラリの組み合わせだけでなんでも作れることでおなじみPythonで書いていく。
作りたいものがほとんど労力を使わず実現できるのでMP[^mp]切れを起こした状態の自分には非常にありがたいが、腰を据えてプログラムを書くということをしなくなってしまうのが少し怖くもある。

icsファイルの生成には[ics](https://pypi.org/project/ics/)というライブラリが使える。
日の出・日の入りの時刻の計算には[suntime](https://pypi.org/project/suntime/)というライブラリが使える。
この2つを組み合わせたら完成である。

[^mp]: まじめポイント

### 完成

というわけで完成した。

[kotet/suntime-ics-generator: 日の出と日の入りのicsファイルを生成するツール](https://github.com/kotet/suntime-ics-generator)

生成したデータを標準出力に書き出す。
他の人が使いやすいように、パラメータをいくつか用意している。
たとえば、東京駅の日の出の時刻を計算して、「SUNRISE」という名前の予定を今から100日前から300日後までの400件分生成したいとする。
東京駅の緯度と経度を調べると35.6812405、139.7649361なので、以下のようにする。

```console
$ poetry run python generate-calendar.py --disable-sunset --sunset-name="SUNRISE" --latitude=35.6812405 --longitude=139.7649361 --start-date-offset=-100 --end-date-offset=300 > tokyo-sunrise.ics
```

### デモ: 名古屋の日の出と日の入り

以下は自分用に生成した名古屋駅の日の出と日の入りの時刻である。
日本国内ならどこでも十数分程度の誤差にしかならないはずなので、ツールの使用が難しい人は活用してほしい。

<iframe src="https://calendar.google.com/calendar/embed?src=hkskj9ernjar4s5quona33jj5o7h1gl8%40import.calendar.google.com&ctz=Asia%2FTokyo" style="border: 0" width="800" height="600" frameborder="0" scrolling="no"></iframe>
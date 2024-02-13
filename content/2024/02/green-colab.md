---
date: 2024-02-05
title: "Green Softwareを目指して夜に動かないColab Notebookを作る"
tags:
    - python
    - tech
image: /img/blog/2024/02/cover.png
highlights:
    - python
---

"Building Green Software"という本が発売されるらしい。

[Building Green Software [Book]](https://www.oreilly.com/library/view/building-green-software/9781098150617/)


この本の著者の一人であるSara Bergman氏が、Green Softwareについての講演を行った動画を見た。

## Green Softwareとは

<iframe width="560" height="315" src="https://www.youtube.com/embed/_lYT-knNMTI?si=ba1Z_UT10cQ3jn6s" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

講演の内容のうち、ソフトウェアに強く関わるものをまとめると以下のようになる。

- 世界の二酸化炭素濃度は急激に増加しているので、ソフトウェアからもCO2排出の削減をしたい
  - ここでのCarbonとは、さまざまな温室効果ガスをCO2換算したもの（carbon dioxide equivalent, 二酸化炭素相当量）を指す
- 氏はGreen Software Foundationの設立メンバー（2021年5月設立）であり、individual contributorとして参加している
- Green Softwareとは、炭素排出が少ないソフトウェアのこと
  - ソフトウェアの電力効率を向上させる。コードや運用の工夫によってエネルギー消費を削減する
  - ハードウェアの電力効率を向上させる。寿命を伸ばすことや互換性をもたせることなどによりハードウェアを長く使い、製造の際の環境負荷を削減する
  - 炭素強度を意識する。電力あたりの炭素排出量は時期によって異なるので、環境負荷の低い時間帯に電力を使うようにする
- 消費エネルギーに、電力の炭素強度を乗じたソフトウェア炭素強度（software carbon intensity, SCI）を指標として導入する
  - SCI = Σ (消費エネルギー) * (その時の電力の炭素強度) + （ハードウェアの動作による炭素排出）

Linux FoundationにはGreen Softwareに関するコースがあるらしい。「表紙」が日本語だが、中身も日本語で受けられるのだろうか？
無料らしいので、あとで受けてみようかと思う。

[実践者向けのグリーン ソフトウェア トレーニング | Linux財団](https://training.linuxfoundation.org/ja/training/green-software-for-practitioners-lfc131/)

## 実践できることを考える

少ないリソースで動くシステムが個人的に好きで、前からいろいろ考えてはいた。
電力あたりの炭素排出量が低い時間帯に動くようなプログラムも、なんとか作れないか考えてみたことがある。
講演では、そのようなシステムの実例がいくつか紹介されていた。

- Windows 11は炭素強度データを取得して、炭素排出量の低い時間に更新のインストールを行う
  - [Windows Updateがカーボン対応になりました - Microsoft サポート](https://support.microsoft.com/ja-jp/windows/windows-update%E3%81%8C%E3%82%AB%E3%83%BC%E3%83%9C%E3%83%B3%E5%AF%BE%E5%BF%9C%E3%81%AB%E3%81%AA%E3%82%8A%E3%81%BE%E3%81%97%E3%81%9F-a53f39bc-5531-4bb1-9e78-db38d7a6df20)
- iPhoneの充電を環境負荷の低そうな時間に行う機能。アメリカ限定
  - [Use Clean Energy Charging on your iPhone - Apple Support](https://support.apple.com/en-us/108068)
- Xboxのアップデートを環境負荷の低そうな時間に行う機能
  - [Xbox Is Now the First Carbon Aware Console, Update Rolling Out to Everyone Soon - Xbox Wire](https://news.xbox.com/en-us/2023/01/11/xbox-carbon-aware-console-sustainability/)

これらの実例では、実際の炭素強度データを参照してスケジューリングを行っている。
しかし、iPhoneの機能がアメリカ限定だと明記されているように、リアルタイムの炭素強度データが取得できる地域は限られている。
日本に住む自分は、調べてもよさげな方法を見つけることができなかった。

比較的安定していると考えられる傾向として、昼間のほうが太陽光発電を利用できるぶん、電力当たりの炭素排出量の高い発電の割合が低くなるということがある。
もちろん、地域によって太陽光発電の割合は異なるし、天候によっても大きく変わる。
あと、原子力発電が利用できる地域では、総需要の少ない夜間のほうが炭素排出量が低いという可能性もある。
しかし、現状どこででも利用できる判断基準としては、比較的有効なんじゃないかと思う。
もっと信頼性の高くて気軽な方法が出てきてほしい……

というわけで、せめて夜中に電力を消費するようなプログラムを動かすのを避けることを考える。

## インスタンスが動いている時間帯を判断するGoogle Colab Notebook

自分が行っている活動の中で特に電力を消費するものは、Google ColabでGPUインスタンスを使うことだ。
画像生成とか、音声の書き起こしとかをしている。
これらのNotebookでGPUを動かす前に、インスタンスが動いている地域の時間帯を推定して、夜間であれば動作を中断するようなセルを書いてみた。
Notebookの冒頭に以下のセルを書いておけば、現地時間で8時から16時の間であればそのまま実行が続けられる。
それ以外の時間帯であれば、インスタンスが停止される。

中断されたときにできることは少ない。
インスタンスが動くリージョンはランダム（か、おそらくリソースの余っているリージョン）なので、数十分くらい待って再度実行すると別のリージョンで動くことがある。
ただ、偶然夜を追いかけてしまい、ずっと夜の時間帯から抜け出せないということもありうる。
日中に動かすという荒い方針なので、あまり無理することもない。
どうしてもすぐ動かしたいときのために、`IGNORE_DAYTIME`という変数を用意しておいた。
これをTrueにすれば、チェックがスキップされる。

```python
!pip install pytz

IGNORE_DAYTIME=False

import requests
from datetime import datetime
import json
import pytz

def is_daytime(verbose: bool):
  API_ENDPOINT = "https://ipinfo.io/json"
  response = requests.get(API_ENDPOINT)
  if response.status_code != 200:
    raise Exception(f"{response.status_code} from {API_ENDPOINT}")
  timezone_name = json.loads(response.content)["timezone"]
  timezone_info = pytz.timezone(timezone_name)
  local_time = datetime.now(timezone_info)
  if verbose:
    print(f"timezone: {timezone_name} - {local_time}")
  hour = local_time.hour
  return 8 <= hour and hour <= 16

if not IGNORE_DAYTIME and not is_daytime(verbose=True):
  print("It is night, exiting.")
  from google.colab import runtime
  runtime.unassign()
```

仕組みとしては、`ipinfo.io`というIPジオロケーションサービスを使って、インスタンスが動いている地域の推定タイムゾーンを取得する。
`ipinfo.io`のAPIは`Asia/Tokyo`のようなタイムゾーン名を返すので、`pytz`を使ってUTCオフセットを取得する。
現地時間が8時から16時の間であれば、そのまま実行を続ける。
そうでなければ、`google.colab.runtime.unassign()`を使ってインスタンスを停止する。

`import`をif文の中に書いているのは、少しでも起動コストを抑えてチェックそのものの負荷を減らすためと、
`print`を行ってすぐに`unassign`を呼び出すとメッセージが表示されないことがある現象の対策のためだ。
最初は`time.sleep`を使っていたが、Pythonのインポート処理はやたら遅いのでこれでも7割位の確率でうまくいくようだった。

このセルの実行時間は可能な限り短くしたいのだが、とにかく`import`が遅い。
UTCオフセットを取得するためだけにライブラリをダウンロードしてくるのも無駄が多い。
今回はコピペでどこででも動くことを重視したのでこのような形になったが、もっと便利なIPジオロケーションサービスを会員登録して使うとかすればもう少し効率的になるかもしれない。

動かすと以下のような出力が得られる。
まずは昼間のリージョンに当たったときの出力。

```
Requirement already satisfied: pytz in /usr/local/lib/python3.10/dist-packages (2023.4)
timezone: Asia/Singapore - 2024-02-06 14:58:10.596164+08:00
```

次に夜間のリージョンに当たったときの出力。

```
Requirement already satisfied: pytz in /usr/local/lib/python3.10/dist-packages (2023.4)
timezone: America/New_York - 2024-02-06 02:16:52.692341-05:00
It is night, exiting.
```

とりあえずGoogle Colabでできることはこれくらいかなと思う。
ローカルで動かしている日本のコンピュータにおいて、電力網の炭素強度データを取得する良い方法を知っている人がいたら教えてほしい。

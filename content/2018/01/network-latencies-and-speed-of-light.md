---
date: 2018-01-22
aliases:
- /2018/01/22/network-latencies-and-speed-of-light.html
title: "ネットワーク遅延と光速度【翻訳】"
tags:
- tech
- translation
excerpt: "この短い投稿で私は、現代のネットワーク（インターネット）のレイテンシが既に今の物理学上で可能な限界にかなり近く、勇敢な市民の行動と今後予測可能な範囲で普通のインターネットには使われそうにないネットワークエンジニアリングへの膨大な投資をもってしても2倍程度にしかならないため、今後も変わらないということを納得してもらうよう試みます。"
---

この記事は
[Network latencies and speed of light | The ryg blog](https://fgiesen.wordpress.com/2018/01/20/network-latencies-and-speed-of-light/)
を自分用に翻訳したものを
[許可を得て](https://twitter.com/rygorous/status/954912383687798784)
公開するものである。

ソース中にコメントの形で原文を残している。
誤字や誤訳など気になったら
[Pull requestを投げつけて](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})
くれると喜ぶ。

---

<!-- In this short post I’m going to attempt to convince you that current network (Internet) latencies are here to stay, because they are already within a fairly small factor of what is possible under known physics, and getting _much_ closer to that limit – say, another 2x gain – requires heroics of civil and network engineering as well as massive capital expenditures that are very unlikely to be used for general internet links in the foreseeable future. -->

この短い投稿で私は、現代のネットワーク（インターネット）のレイテンシが既に今の物理学上で可能な限界に**かなり**近く、今後予測可能な範囲で普通のインターネットには使われそうにない勇敢な土木とネットワークエンジニアリングへの膨大な投資をもってしても2倍程度にしかならないため、今後も変わらないということを納得してもらうよう試みます。

<!-- This is a conversation I’ve had a few times in my life, usually with surprised conversation partners; last year I happened to write a mail about it that I’m now going to recycle and turn into this blog post so that in the future, I can just link to this if it ever comes up again. :) -->

これは私がときどきある議論で、それを聞いた相手は大抵驚きます。
昨年それについてメールを書くことがあり、私はそれをリサイクルしこの投稿にしようと思い立ちました。今後同じことが起きたらここへのリンクを送るだけで良くなります。 :)

<!-- When I originally wrote said mail in October 2017, I started by pinging `csail.mit.edu`, a machine that as far as I know (and Geo-IP services are with me on this one) is actually at MIT, so in Cambridge, MA. I did this sitting at my Windows work machine in Seattle, WA, and got this result: -->

2017年10月に元のメールを書いた時、私は私が知る限り（そしてGeo-IPサービスでわかる限り）1番遠いマサチューセッツ州、ケンブリッジのMITにあるマシンである`csail.mit.edu`へpingをしました。
私はワシントン州、シアトルの仕事用Windowsマシンの前にいました。

<!-- ```console
Pinging csail.mit.edu [128.30.2.121] with 32 bytes of data:
Reply from 128.30.2.121: bytes=32 time=71ms TTL=48
Reply from 128.30.2.121: bytes=32 time=71ms TTL=48
Reply from 128.30.2.121: bytes=32 time=70ms TTL=48
Reply from 128.30.2.121: bytes=32 time=71ms TTL=48
``` -->

```console
Pinging csail.mit.edu [128.30.2.121] with 32 bytes of data:
Reply from 128.30.2.121: bytes=32 time=71ms TTL=48
Reply from 128.30.2.121: bytes=32 time=71ms TTL=48
Reply from 128.30.2.121: bytes=32 time=70ms TTL=48
Reply from 128.30.2.121: bytes=32 time=71ms TTL=48
```

<!-- Ping times are round-trip times and include the time it takes for the network packet to go from my machine to the MIT server, the time it takes for the server to prepare a reply, and the time for said reply to make it back to my machine and get delivered to the running `ping` process. The best guess for a single-way trip is to just divide the RTT by 2, giving me an estimate of about 35ms for my ping packet to make it from Seattle to Boston. -->

Ping timeはround-trip timeであり、ネットワークパケットが私のマシンからMITに送られる時間、サーバが返信を準備する時間、そして返信を送り、それが私のマシンへと帰ってきて、`ping`プロセスへと届けられるまでの時間が含まれます。
片道の時間はほぼRTTを2で割った時間であり、私のpingパケットはシアトルからボストンまで35ミリ秒で送られたと概算できます。

<!-- Google Maps tells me the great circle distance from my office to Cambridge MA is about 4000km (2500 miles, if a kilometer means nothing to you). Any network packets I’m sending these days over normal network infrastructure are likely to use either optical fiber (especially for long-distance links) or copper cable as a transmission medium. The rule of thumb I learned in university that effective signal transmission speed over both is about 2/3rds of the speed of light in vacuum. This is called the [velocity factor](https://en.wikipedia.org/wiki/Velocity_factor); that article has some actual numbers, which work out to 0.65c for Cat-6A twisted pair cable (used for 10Gbit Ethernet), 0.64c for Cat-5e (1Gbit Ethernet), and 0.67c for optical fiber, all of which are close enough to each other and to the aforementioned 2/3c rule of thumb that I won’t bother differentiating between different types of cables in the rest of this post. -->

Google Mapsによると私のオフィスからCambridge MAまでの大円距離はおよそ4000キロメートル（キロメートルがわからないなら、2500マイルとも言えます）です。
私が現在送るすべてのネットワークパケットは普通のネットワークインフラストラクチャの上を通っており、たいてい光ファイバー（特に長距離のリンクでは）か銅線を媒質に使っています。
私が大学で学んだ経験則では、実際のシグナルの伝送速度は両方ともだいたい真空中の光速の3分の2です。
これは[velocity factor](https://en.wikipedia.org/wiki/Velocity_factor)と呼ばれます。
この記事にはいくつか実際の値が載っており、それによるとカテゴリー6ツイストペアケーブル（10Gbit Ethernetで使われます）では0.65c、カテゴリー5e（1Gbit Ethernet）では0.64c、光ファイバーでは0.67cであり、どれも他と比べ先述の経験則の3分の2と近いため、以降この記事ではこれらを区別しません。

<!-- Divide our distance of 2500mi by 2/3c, we get about 4×106m / (2×108 m/s) = 2 × 10-2 s = 20ms. That is the transmission delay we would have for a hypothetical optical fiber strung along the great circle between Seattle and Cambridge, the shortest distance between two points on a sphere; I’m neglecting height differences and Earth being not quite spherical here, but I’m only doing a back-of-the-envelope estimate. Note that the actual measured one-way latency I quoted above is already well below twice that. Hence my earlier comment about even a factor-of-2 improvement being unlikely. -->

2500マイルを2/3cで割ると、4×106m / (2×108 m/s) = 2 × 10-2 s = 20ミリ秒が得られます。
これがシアトルとケンブリッジ間の大円、つまり球上での2点間の最短距離をまっすぐ張った仮想的光ファイバーによる伝達遅延です。
高低差を無視しているし地球は正確な球ではありませんが、ここでは概算にとどめておきます。
上で述べた片道のレイテンシの実測値が既にこの数値の2倍を下回っています。
従ってここまでの話では2倍の改善も起こりそうにありません。

<!-- Now, if your goal is actually building a network (and not just a single point-to-point link), you don’t want to have long stretches of cable in the middle of nowhere. Again as per Google Maps, the distance from Seattle to Cambridge actually driving along major roads is about 4800km (3000mi). So in this case, we get about 20% extra “overhead” distance from building a network that follows the lay of the land, goes through major population centers, and doesn’t try to tunnel below the Great Lakes or similar. That’s a decent trade-off when your plan is to have an actual Internet and not just one very fast link. So this extra 20% overhead puts our corrected estimate of transmission delay along a more realistic network layout at about 24ms. -->

さらに、目的がネットワークの構築（であり、単に2点間を繋ぐことではない）ならば、何もないところに長いケーブルを張りたくはありません。
再びGoogle Mapsによると、シアトルからケンブリッジまで主要な道を通った時の実際の距離はおよそ4800キロメートル（3000マイル）です。
なのでこの場合、ネットワーク構築の際に人口密集地を通り、五大湖の下にトンネルを掘ったりしないことによる20%の「オーバーヘッド」距離があります。
作りたいのが超高速リンクではなくインターネットの場合、これは適切なトレードオフです。
この20%のオーバーヘッドを計算に入れると伝達遅延は24ミリ秒になります。

<!-- That means that of our approximately 35ms one-way trip, 24ms is just from physics (speed of light, index of refraction of optical fiber) and logistics (not having a full mesh of minimum-distance point-to-point links between any two points in the network). The remaining 11ms of the transit time are, presumably, spent with the packets briefly enqueued in some routers, in signal boosters and network stacks. These are the parts that could be improved with advances in network technology. But even reducing that part of the cost to zero still wouldn’t give us even a full 1.5× speed-up. And that’s why I think mainstream network tech isn’t going to get that much faster anytime soon. -->

つまり、片道約35ミリ秒のうち、24ミリ秒は物理（光速度、光ファイバーの屈折率）とロジスティクス（ネットワークのリンクは2点間の最小距離のフルメッシュではない）によるものです。
残りの11ミリ秒はおそらくシグナルブースターとネットワークスタックのルータに少しの間エンキューされた時間です。
ここはネットワーク技術の発展で改善できます。
しかしこのコストをゼロにしたとしても1.5倍のスピードアップにしかなりません。
これがメインストリームのネットワーク技術が近いうちにこれ以上速くなることはないと考える理由です。

<!-- What if we _are_ willing to pay up and lay a private dedicated fiber link for that distance (or use some dark fiber going the right direction that’s already there)? That’s still using mainstream tech, just spending money to reduce the fraction of time spent on sub-optimal routing (physical route that is) and in the network, and it seems likely that you could get the RTT to somewhere between 45ms and 50ms using regular fiber if you were willing to spend the money to set it up (and maintain it). -->

もし距離を縮めるためプライベートの専用ファイバーリンクを敷くために金をかけるのもやむなしと考えるなら（またはそこに都合よく敷かれている正しい方を向いた未使用のファイバーを使うなら）どうでしょう？
まだメインストリームの技術のみを使い、余分なより道（物理的な道）にかかるほんの僅かの時間を削るためにお金をかけ、それを維持管理するつもりならば普通のファイバーでもRTTは45ミリ秒から50ミリ秒になるでしょう。

<!-- But that’s still assuming using something as pedestrian as fiber (or copper cable), and actually sticking to the surface of the Earth. Going even further along the “money is no object” scale, and edging a teensy bit into Bond Villain territory, we can upgrade our signal velocity to full light speed and also get rid of pesky detours like the curvature of the Earth by digging a perfectly straight tunnel between the two points, keeping a vacuum inside (not strictly necessary, but might as well while we’re at it) and then establishing a _really_ high-powered microwave link; it would have to be to make it along a distance of a few thousand kilometers, given beam divergence. Keeping in theme, such a link would then also be attractive because the transceivers at either end because a sufficiently high-powered microwave transmitter should make for a serviceable death ray, in a pinch. More seriously, high-powered point-to-point microwave links are a thing, and are used in very latency-sensitive applications such as high-frequency trading. However, as far as I know (which might be wrong – feel free to correct me!), individual segments typically span distances of a few miles, not tens of miles, and definitely not hundreds. Longer links are then built by chaining multiple segments together (effectively a sequence of repeaters), adding a small delay on every split, so the effective transmission speed is definitely lower than full speed of light, though I don’t know by how much. And of course, such systems require uninterrupted lines of sight, which (under non-Bond-villain conditions) means they tend to not work, or only work in a diminished capacity, under bad weather conditions with poor visibility. -->

しかし、これはまだファイバー（もしくは銅線）を使い、それが地球表面にくっつくように張られていると仮定しています。
「金に糸目をつけない」として、ボンド映画の悪役の領域に片足を突っ込むならば、2点間をつなぐ完璧に真っ直ぐなトンネルを掘り、内部を真空に保ち（厳密には真空にする必要はありませんが、せっかくなのでやっておきましょう）、**超**強力なマイクロ波で接続することで、信号の速度を完全な光速にまでアップグレードし、地球の曲率のような邪魔な回り道をなくすことができます。
ビームの発散を考慮すると数千キロメートルくらいが限界かもしれません。
本題に戻ると、十分に高出力なマイクロ波送信機はその気になればいい感じの殺人光線を出せるので、なかなか魅力的な気もします。
さらに真剣に考えてみると、高出力のポイント・ツー・ポイントマイクロ波リンクは現実のものであり、高頻度取引などの非常にレイテンシが重要な分野で使われています。
しかし私の知る限り（間違ってるかもしれないのでその時は教えてください！）個々のセグメントは数百マイル、数十マイルにも及ばず、通常数マイル程度です。
それ以上に長いリンクは複数のセグメントを連動させることで（事実上リピータの列）構築され、その分割のたびに小さな遅延が発生するため、実際どれくらいのものか知りませんが、伝送速度は完全な光速よりはるかに低くなります。
もちろんこのようなシステムは視界がまっすぐ通っている必要が（ボンド映画の悪役でない限り）あり、視界の悪くなる悪天候時などでは動作しないか、能力が低下します。

<!-- Anyway, for that level of investment, you should be able to get one-way trip times down to about 12ms or so, and round-trips of around 24ms. That is about 3× faster than current mainstream network tech, and gets us fairly close to the limits of known physics, but it’s also quite expensive to set up and operate, not as reliable, and has various other problems. -->

とにかく、そのレベルの投資をすれば片道の時間は12ミリ秒、往復24秒ほどになります。
これは現在のメインストリームのネットワーク技術の3倍速く、既知の物理学の限界にかなり近づきますが、構築、維持が非常に高くつき、信頼性など様々な問題があります。

<!-- So, summarizing: -->

つまり、まとめると:

<!-- *   If you have a good consumer/business-level Internet connection, ping someone who does likewise, and there are no major issues on the network in between, the RTTs you will get right now are within about a factor of 3 of the best they can possibly be as per currently known physics: unless we figure out a way around Special Relativity, it’s not getting better than straight-line line-of-sight light-speed communication. -->

 - あなたがコンシューマレベル/ビジネスレベルの優れたインターネットコネクションを持っているならば、同じ環境にいる人へPingをして、その間のネットワークに大きな問題がない場合は、RTTは現在知られている物理法則で可能な限界の3倍以内になります。我々が特殊相対性理論を回避する方法を見つけ出さない限り、まっすぐ視界の通った光速通信より速くなることはありません。

<!-- *   If you’re willing to spend a bunch of money to buy existing dark fiber  
    capacity that goes in the right direction and lay down some of your own  
    where there isn’t any, and you build it as a dedicated link, you should be able to get within 2× of the speed of light limit using fairly mainstream tech. (So about a 1.5× improvement over just using existing networks.) -->

 - 適切な方を向いて敷設されている未使用のファイバーを多額の費用をかけて買収する気があるなら、専用のリンクを構築することで十分メインストリームな技術で光速の限界の2倍以下の（そして通常のネットワークから1.5倍ほど改善した）速度が得られます。
    
<!-- *   Getting substantially better than that with current tech requires  
    major civil engineering as well as a death ray. Upside: a death ray is its own reward. -->

 - 現代の技術を超えて改善させるならば、大きな土木工学と殺人光線が必要です。利点:殺人光線はいいものです。

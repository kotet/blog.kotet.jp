---
date: 2017-10-15
aliases:
- /2017/10/15/no-bitcoin-based-protocol-can-handle-more-than-20m-users-per-month.html
title: "現Bitcoinベースのプロトコルでは月に2000万を超えるユーザに対応できない【翻訳】"
tags:
- tech
- translation
- bitcoin
excerpt: "Bitcoinのスケーラビリティー問題を解決するために、たくさんのいわゆる layer 2 プロトコルが提案されました。 それらのプロトコルは同じような、比較的シンプルな方針に従って動作します:"
---

この記事は、
[No Bitcoin-based protocol can handle more than 20M users per month (Rune K. Svendsen's Blog)](https://runeksvendsen.github.io/blog/posts/2017-10-08-no-bitcoin-based-protocol-can-handle-more-than-20m-users-per-month.html)を自分用に翻訳したものを
[許可を得て](https://twitter.com/runeksvendsen/status/919218487167471617)
公開するものである。

ソース中にコメントの形で原文を残している。
誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/kotet/blog.kotet.jp)だ!

---
<!-- To solve Bitcoin’s scalability challenge, many so-called _layer 2_ protocols have been proposed. All of these protocols operate on the same, relatively simple, principle: -->

Bitcoinのスケーラビリティー問題を解決するために、たくさんのいわゆる _layer 2_ プロトコルが提案されました。
それらのプロトコルは同じような、比較的シンプルな方針に従って動作します:

<!-- 1.  User deposits bitcoins (via the Bitcoin blockchain) into the layer 2 system
2.  Stuff happens within the layer 2 system – without touching the Bitcoin blockchain – which assigns arbitrarily small parts of the deposited bitcoins to other users (recipients) in the system
3.  Recipients withdraw received bitcoins (into the Bitcoin blockchain) -->

1. ユーザがBitcoinブロックチェーンよりlayer 2システムへBitcoinをデポジットする
2. Bitcoinブロックチェーンを介さず、デポジットされたBitcoinを他のユーザ(受取人)に任意の量配分することで、layer 2システム内で取引が進行する
3. 受取人が受け取ったBitcoinを(Bitcoinブロックチェーンへ)引き出す

<!-- This increases the scalability of transferring bitcoins from user to user, since at _Step 2_ nothing touches the blockchain. In fact, since nothing touches the blockchain, the transaction speed (as measured in transactions per second) is theoretically unlimited, and in practice only limited by latency and bandwidth between nodes. -->
**ステップ2**がブロックチェーンにタッチしないため、ユーザ間のBitcoinの送金のスケーラビリティが増加します。
実際、ブロックチェーンに全くタッチしないなら、処理スピード(秒あたりのトランザクション)は理論上無制限であり、現実的にも制限するのはノード間のレイテンシとバンド幅のみです。

<!-- The problem, however, is _Step 1_. When a user receives money – which humans usually receive monthly as wages/salaries – they need to deposit it into the layer 2 system, in order for it to be available within it. At the current block size limit of 1 MB, the maximum number of deposit transactions per month – assuming the simplest Bitcoin transaction (single-signature) with a size of 224 bytes is used – is 20 million[^1]. -->

しかし**ステップ1**に問題があります。
ユーザがお金、人間が通常給料として毎月受け取るお金を受け取る時、そのお金をlayer 2システムで利用するためにデポジットする必要があります。
現在のブロックサイズの上限1 メガバイトにおいて、最もシンプルな224バイトのBitcoinトランザクション(single-signature)が使われたと仮定した時、月あたりのデポジットトランザクションの最大数は……2000万です[^1]。

<!-- [^1]: 1,000,000 bytes per block/224 bytes per transactions = 4464 tx/block  
    4464 tx/block*6 blocks per hour*24 hours per day = ~643000 tx/day  
    643000 tx/day*30 days per month = ~20 million tx/month -->

[^1]: ブロックあたり1,000,000バイト / トランザクションあたり224バイト = ブロックあたり4464トランザクション
    ブロックあたり4464トランザクション * 1時間あたり6ブロック * 1日24時間 = ~1日あたり643000 トランザクション
    1日あたり643000 トランザクション * 1ヶ月30日 = ~月あたり2000万トランザクション

<!-- This is a maximum, since a single-signature Bitcoin transaction isn’t very interesting in the context of layer 2 protocols (it essentially constitutes sending your bitcoins to a trusted third party). Thus, with more complex (e.g. multi-signature) deposit transactions, the number of monthly users will be less than 20 million. Furthermore, this figure does not include the withdrawal transactions (where recipients withdraw funds from the layer 2 system to their private Bitcoin address), which will decrease the maximum number of supported users even further. -->

Single-signature Bitcoinトランザクションによるこの上限は、本質的にBitcoinを信頼できる第三者に送るための構成要素であるlayer 2プロトコルの文脈において面白くないものです。
Multi-signatureのようなより複雑なデポジットトランザクションでは、月間ユーザの数は2000万からより少なくなります。
さらに、引き落としトランザクション(受取人が資金をlayer 2システムから個人のBitcoinアドレスに引き出す)はこの数値に含まれておらず、対応できるユーザ数の上限はさらに減少します。

<!-- In conclusion, if Bitcoin is to scale to more than ~0.2% of the world’s population, layer 2 protocols – operating on the principle described above – will not be sufficient. The Bitcoin blockchain will need to increase its capacity in conjunction with layer 2 protocols, or it will not have sufficient capacity to support more than – at most – 20 million users per month. -->

結論として、Bitcoinが世界人口の~0.2%を上回り拡大すると、上で説明した方針で動作するlayer 2プロトコルでは十分でなくなります。
Bitcoinブロックチェーンが月に2000万を超えるユーザをサポートするには、layer 2プロトコルと合わせて容量も増加させる必要があります。
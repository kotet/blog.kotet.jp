---
title: "エイシング プログラミング コンテスト 2020"
date: 2020-07-11
tags:
- atcoder
- dlang
- tech
---

ABC相当のコンテスト。

### 結果

4完848位。
EとFが難しかったっぽい。
Dもわからなくて絶望しかけてたけどなんとかコンテスト中に解法を思いついたのでレートの暴落は回避されHighest更新。

[コンテスト成績証 - AtCoder](https://atcoder.jp/users/kotet/history/share/aising2020)

### A - Number of Multiples

単純に指示された範囲の整数に対して$d$の倍数かどうかを判定して数えれば良い。
指示された範囲内だけ正確に列挙できるようにループの書き間違いには気をつけよう（1敗）

[提出 #15146161 - エイシング プログラミング コンテスト 2020](https://atcoder.jp/contests/aising2020/submissions/15146161)

……というふうにコンテスト中は書いたが、1から$x$までの$d$の倍数の数は$x/d$で求められるので、
$R/d - (L-1)/d$のようにすれば$O(1)$で求められると思う。

### B - An Odd Problem

普通に条件を満たしているマスを数えれば良い。

[提出 #15149181 - エイシング プログラミング コンテスト 2020](https://atcoder.jp/contests/aising2020/submissions/15149181)

### C - XYZ Triplets

$x^2 + 1以上の数 \leq n \Rightarrow x < \sqrt{n}$より、
$x,y,z < \sqrt{n} \leq \sqrt{N} \leq \sqrt{10^4} = 10^2$。
なので$x$、$y$、$z$の3重ループを$x,y,z \leq 10^2$
くらいの範囲で回してやれば$x^2+y^2+z^2+xy+yz+zx$
の値が問題に出てくる範囲の数字になる組み合わせは全列挙できる。
これは十分間に合うので、最初に固定長の3重ループで答えのテーブルを作って、入力に合わせてその値を読んでくれば良い。

[提出 #15155662 - エイシング プログラミング コンテスト 2020](https://atcoder.jp/contests/aising2020/submissions/15155662)

### D - Anything Goes to Zero

$\mathrm{popcnt}(n)\leq \log_2{n}$なので、$f(n)$の値はけっこう小さくなりそうな予感がする。
なので単純に何回操作が可能かシミュレートすればいいのだが、普通にやると入力が大きいのでオーバーフローする。
$N\leq 2\times 10^5$なので、最初の操作で値は普通の整数型に収まるようになる。
そのため2回目以降の操作は定義どおりに計算してもいいはずだが、1回目だけは特別な工夫が必要。

まず$\mathrm{popcnt}(X)$をループで1を数えて計算する。
1箇所ビットを反転させたら$\mathrm{popcnt}(X_i) = \mathrm{popcnt}(X) \pm 1$
になる。
$X$の上から$i$ビットめが1の場合、$X_i\\%\mathrm{popcnt}(X_i) = (X - 2^{N-1-i})\\%\mathrm{popcnt}(X_i)$で、
$X$の上から$i$ビットめが0の場合、$X_i\\%\mathrm{popcnt}(X_i) = (X + 2^{N-1-i})\\%\mathrm{popcnt}(X_i)$である。
$\mathrm{popcnt}(X)$、$X\\%\mathrm{popcnt}(X_i)=X\\%(\mathrm{popcnt}(X)\pm 1)$を$O(N)$で事前に計算しておけば、
powmodを使って$O(\log{N})$で1回目の操作を行った後の値を計算できる。

あとは愚直にシミュレートしてやれば良い。
popcntが標準ライブラリにあると非常に楽。

[提出 #15171056 - エイシング プログラミング コンテスト 2020](https://atcoder.jp/contests/aising2020/submissions/15171056)

### E - Camel Train

わかりそうでわからない

### F - Two Snuke

まったくわからない
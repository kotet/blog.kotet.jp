---
title: "M-SOLUTIONS プロコンオープン 2020"
date: 2020-07-25
tags:
- atcoder
- dlang
- tech
---

ABC相当のコンテスト。
今回から
[atcoder-tools](https://github.com/kyuridenamida/atcoder-tools)
を使い始めた。
もともと自作のツールより便利なところを自分好みにエイリアス貼ったりした結果めちゃくちゃ効率が上がったので次回からも使っていきたい。

### 結果

4完533位。
E、Fが難しかったようで、A、B、C、Dの速解き勝負で高順位を取れた。
17分4完はatcoder-toolsのおかげか。

[コンテスト成績証 - AtCoder](https://atcoder.jp/users/kotet/history/share/m-solutions2020)

### A - Kyu in AtCoder

級位が200ごとに変化しており、級位が定義されている範囲外の入力が与えられないので単純に$10-X/200$。
暗算が苦手で式をを出すのに時間がかかった。

[提出 #15413523 - M-SOLUTIONS プロコンオープン 2020](https://atcoder.jp/contests/m-solutions2020/submissions/15413523)

### B - Magic 2

緑のカードが条件を満たすまで緑のカードに操作を行い、その後青のカードが条件を満たすまで青のカードに操作を行う。
倍々にしていくので各操作は$O(\log{N})$で終わる。
なので実際にやってみて必要な操作回数を調べ、それがK以下か確かめれば良い。

[提出 #15417426 - M-SOLUTIONS プロコンオープン 2020](https://atcoder.jp/contests/m-solutions2020/submissions/15417426)

### C - Marks

$i$学期の評定が$i-1$学期の評定より真に高くなるのは、$i$学期で評定の式から消えた数より新しく入った数が真に大きいときのみ、
つまり$A_{i-K} < A_i$のときのみである。
それがわかっていれば積を取る必要すら無い。

[提出 #15420051 - M-SOLUTIONS プロコンオープン 2020](https://atcoder.jp/contests/m-solutions2020/submissions/15420051)

### D - Road to Millionaire

最適な動作があるとして、それは安いある時点で全財産をつぎ込んで株を買い、高いある時点で全株式を売り払うという動作になるはず。
なので、

$dp_{i,j} = i$日目に株を$j$個持っている時の所持金の最大値

というDPを行うことで解ける。
本番中は$j$を所持金にして連想配列にして解いてた。
買う、売る、何もしないの3パターンなので所持金のパターンも1日ごとに最大で3倍増えていく。
80日あるので最終日の所持金の最大パターン数を概算すると$10^{38}$くらいになる。
ただし所持金の最大値が$10^{15}$くらいなので、鳩の巣原理で実際のパターン数は最大でも$10^{15}$くらいに収まる。
本番中はパターン数の計算をせずに祈祷を行うことで通したが結構危なかったかもしれない。

[提出 #15426815 - M-SOLUTIONS プロコンオープン 2020](https://atcoder.jp/contests/m-solutions2020/submissions/15426815)

### E - M's Solution

計算量が全然落ちなくて解けなかった。

### F - Air Safety

斜めの座標系に変換すると解けそうな雰囲気を終了20分前に感じ取ったが、自分が20分で解くには考えることが多すぎた。
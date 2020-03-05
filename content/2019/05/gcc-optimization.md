---
title: "gccにおけるモジュラ逆数を用いた(x % m == 0)の最適化"
date: 2019-05-06
tags:
- assembly
- tech
- cpplang
mathjax: on
---

<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/x86asm.min.js"></script>

### gccの最適化

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">GCC is now transforming: ((x % CONSTANT) == 0)<br>to mod inverse and using rotate when it&#39;s even. <br>Not in clang yet though<a href="https://t.co/nfywTIrTe0">https://t.co/nfywTIrTe0</a></p>&mdash; Marc B. Reynolds (@marc_b_reynolds) <a href="https://twitter.com/marc_b_reynolds/status/1125180264479694848?ref_src=twsrc%5Etfw">May 5, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

ある数が定数で割り切れるかを`%`を使って判定するコードが

```c
#include "stdint.h"

uint32_t is_div_7(uint32_t k)
{
  return (k % 7)==0;
}
```

こんな感じに最適化されるようです。

```x86asm
is_div_7(unsigned int):
        imul    edi, edi, -1227133513
        xor     eax, eax
        cmp     edi, 613566756
        setbe   al
        ret
```

わかりやすくCに再翻訳するとこんな感じでしょうか。

```c
#include "stdint.h"

uint32_t is_div_7(uint32_t k)
{
  return (k * -1227133513) <= 613566756;
}
```

剰余演算(x86では除算と同じ処理です)がなくなり、乗算と比較だけになっているのがわかります。
除算は他の演算と比べてコストが大きいので、なくすことができると嬉しいです。
しかし`-1227133513`や`613566756`などという数字はどこから出てきたのでしょうか？

### モジュラ逆数

自然数$m$で割ったときの余りが同じ整数を同一視することを「法$m$で考える」といいます。
このとき、$m$と互いに素な整数$a$に対して

$$ a^{-1} \equiv x \mod m $$

となるような整数$x$、つまり$a$の[逆数が存在します](https://ja.wikipedia.org/wiki/%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%A9%E9%80%86%E6%95%B0)。
この$x$は[オイラー関数](https://ja.wikipedia.org/wiki/%E3%82%AA%E3%82%A4%E3%83%A9%E3%83%BC%E3%81%AE%CF%86%E9%96%A2%E6%95%B0)
$\varphi(n)$(=$n$と互いに素である$1$以上$n$以下の自然数の数)を用いて求めることができます。

$$ a^{-1} \equiv a^{\varphi(m) - 1} $$

通常この$\varphi(n)$を求めるのは素因数分解などのめんどくさい計算が必要になりますが、
素数$p$のべき乗の場合は単純な式になります。

$$ \varphi(p^k) = p^k - p^{k-1} $$

$p=2$の場合は以下のようにもっと単純になります。

$$\begin{align}
 \varphi(2^k)   &= 2^k - 2^{k-1} \\\\\\
                &= 2^{k-1}(2-1) \\\\\\
                &= 2^{k-1} 
\end{align}$$

べき乗は[簡単な工夫](https://ja.wikipedia.org/wiki/%E5%86%AA%E4%B9%97#%E5%8A%B9%E7%8E%87%E7%9A%84%E3%81%AA%E6%BC%94%E7%AE%97%E6%B3%95)で
$\mathcal{O}(\log{n})$で求めることができます。
というわけで法$2^k$のときの奇数$a$の逆数(逆数が存在するのは$a$が$2^{k}$と互いに素のとき、
つまり奇数のときです)はそれなりに速く求めることができて、それは以下のような式になります。

$$ a^{-1} \equiv a^{2^{k-1}-1} \mod 2^k $$

### オーバーフローは剰余算

ここで`uint32_t`の性質について考えてみます。
`uint32_t`は32ビット整数です。
32ビットで表せる範囲を超えた数値はオーバーフロー(アンダーフロー)を起こし、
32ビットで表せる範囲に戻ってきます。

つまり！`uint32_t`は！勝手に$2^{32}$を法とする[剰余類環](https://ja.wikipedia.org/wiki/%E5%89%B0%E4%BD%99%E9%A1%9E%E7%92%B0)になっています！

ということは`uint32_t`の範囲で任意の奇数の逆数を求めることができて、`uint32_t`の範囲で除算ができます。

```c
uint32_t inv = 3067833783; // 7の逆数
return 63 * inv; // 9
```

### 除算の性質

わかりやすく数字を小さくして考えてみましょう。
法$8 = 2^3$において$3$の逆元は$3$です。
0から7までの整数に3をかけてみます。

| x | x*3%8 |
|---|-------|
| 0 | 0     |
| 1 | 3     |
| 2 | 6     |
| 3 | 1     |
| 4 | 4     |
| 5 | 7     |
| 6 | 2     |
| 7 | 5     |

結果に重複はなく、0から7までの数字が並べ替えられていることがわかります。
ここで右側の列をキーにしてソートし直してみましょう。

| x*3%8 | x |
|-------|---|
| 0     | 0 |
| 1     | 3 |
| 2     | 6 |
| 3     | 1 |
| 4     | 4 |
| 5     | 7 |
| 6     | 2 |
| 7     | 5 |

3で割ったあまりが0のもの、1のもの、2のものと纏まっていることがわかるでしょうか。
法である8を3で割った数(切り上げ)を$c$とおくと、余りが$k$となる数の結果の値域は$[ck,c(k + 1))$になります。
つまり結果がどの範囲にあるか見れば余りがいくつになるかわかるということです。

### 完成

これらをすべて組み合わせると最初のコードになります。
任意の奇数で同じ手順での最適化が可能です。

```x86asm
is_div_7(unsigned int):
        imul    edi, edi, -1227133513 ; == 3067833783 == 7^(2^31 - 1) mod 2^32 == 7の逆数
        xor     eax, eax
        cmp     edi, 613566756 ; 2^32 / 7
        setbe   al ; (k * 7^(2^31 - 1) mod 2^32) <= 2^32 / 7
        ret
```

### 偶数は？

偶数も少し工夫すると簡単に最適化できます。
まずは実際に最適化されたコードを見てみましょう。

```c
uint32_t is_div_14(uint32_t k)
{
  return (k % 14)==0;
}
```

```x86asm
is_div_14(unsigned int):
        imul    edi, edi, -1227133513
        xor     eax, eax
        ror     edi
        cmp     edi, 306783378
        setbe   al
        ret
```

偶数$c$は奇数$n$と指数$m$を使って以下のように表せます。

$$ c = n * 2^m $$

まず奇数部分$n$の逆数を作って判定対象$k$を割ります。
あとは$k/n$が$2^m$で割り切れるかを判定すればいいです。

ある数が$2^m$で割り切れるということは、下位$m$ビットがゼロであるということです。
これは$2^m-1$との[AND](https://ja.wikipedia.org/wiki/%E3%83%93%E3%83%83%E3%83%88%E6%BC%94%E7%AE%97#AND)がゼロかどうかで判定することもできますが、
[右ローテート](https://ja.wikipedia.org/wiki/%E3%83%93%E3%83%83%E3%83%88%E6%BC%94%E7%AE%97#(%E3%82%AD%E3%83%A3%E3%83%AA%E3%83%BC%E3%81%AA%E3%81%97)%E3%83%AD%E3%83%BC%E3%83%86%E3%83%BC%E3%83%88)
を使うと$n$で割り切れるかどうかの判定を一度に行うことができます。

$k$が$2^m$で割り切れる=下位$m$ビットがゼロであるときに$k/n$を$m$回右ローテートすると、
これは[右シフト](https://ja.wikipedia.org/wiki/%E3%83%93%E3%83%83%E3%83%88%E6%BC%94%E7%AE%97#%E8%AB%96%E7%90%86%E3%82%B7%E3%83%95%E3%83%88)
と同じであり値は単に$2^m$で割られます。
このとき$n$で割った余りが0になる値域を$2^m$分の1にした範囲に値があれば、$k$は$n$と$2^m$の両方で割り切れるため$c$で割り切れます。

そうでないときに$k/n$を$m$回右ローテートすると、下位ビットの1がぐるっとまわって上位ビットに付加されます。
すると値は非常に大きくなるため$n$で割った余りが0になる値域を$2^m$分の1にした範囲から外れます。

以上のようにして偶数で割り切れるかどうかの判定を除算なしに行うことができました。

```x86asm
is_div_14(unsigned int):
        imul    edi, edi, -1227133513 ; == 3067833783 == 7^(2^31 - 1) mod 2^32 == 7の逆数
        xor     eax, eax
        ror     edi ; 1ビット右ローテート
        cmp     edi, 306783378 ; (2^32 / 7) / 2
        setbe   al
        ret
```

### 感想

符号なし32ビット整数を$2^{32}$で割った余りと捉えてオーバーフローを活用するという発想がなかったので勉強になりました。
そのうちなにかに使えるかもしれない……

### 参考

- [Optimizing is-multiple checks with modular arithmetic](http://duriansoftware.com/joe/Optimizing-is-multiple-checks-with-modular-arithmetic.html)
- [モジュラ逆数 - Wikipedia](https://ja.wikipedia.org/wiki/%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%A9%E9%80%86%E6%95%B0)
- [演算子強度低減 - Wikipedia](https://ja.wikipedia.org/wiki/%E6%BC%94%E7%AE%97%E5%AD%90%E5%BC%B7%E5%BA%A6%E4%BD%8E%E6%B8%9B)

---
title: "最頻値を指定したランダムな時間待つ"
date: 2026-09-12T07:10:05+09:00
tags:
- golang
- tech
---

最近元気があるので、[以前に書いた記事](/2023/06/inverse-gaussian)で力尽きてしまったところの続きを書こうと思う。
ランダムな時間待機する場合に、ランダム値の傾向、主に最頻値を制御する方法を紹介する。
情報系の大学で数学を勉強していれば簡単な話かもしれないが、基礎の話すぎるのかググっても意外と実用上の知識として書いた記事が少ないのでこの記事が「ランダム sleep 最頻値」とかで検索した人の助けになると嬉しい。

## 最頻値を制御できる確率分布

### 最大値と最小値を制御したい: 三角分布

前回の記事では逆ガウス分布を使って期待値と分散を制御した乱数を生成する方法を紹介した。
しかしランダムな時間待つ場合に欲しいのは最頻値、つまり最もよく出現する値だと思う。
最頻値を直接的に制御できる確率分布として、三角分布がある。
三角分布は最小値$a$、最大値$b$、最頻値$c$の3つのパラメータで形状が決まる分布で、最小値で確率ゼロ、最頻値で確率が最大となり、最大値で再び確率ゼロになる分布である。

確率密度関数が三角形になることから三角分布と呼ばれる。
かなり単純な形の分布だが、今回のような用途ならこれで十分な気もする。最小値と最大値が別々のパラメータで制御もしやすい。

Goのライブラリgonumにはさまざまな確率分布で乱数を生成する機能があるので、三角分布の乱数も簡単に生成できる。
gonumはプロット機能までついた多機能ライブラリなので、実際に生成してみて結果のヒストグラムを描画してみる。

```go
	tri := distuv.NewTriangle(0, 10, 2, nil)
	plotHistogram(tri, "triangle_histogram.png")
```

実装したい言語にライブラリが無い場合は、Wikipediaの記事に載っている累積分布関数を使って前回の方法で自分で生成するといいだろう。

[三角分布 - Wikipedia](https://ja.wikipedia.org/wiki/%E4%B8%89%E8%A7%92%E5%88%86%E5%B8%83)

<details>
<summary>以降使うプロット関数</summary>

```go
package main

import (
	"gonum.org/v1/gonum/stat/distuv"
	"gonum.org/v1/plot"
	"gonum.org/v1/plot/plotter"
	"gonum.org/v1/plot/vg"
)

const nSamples = 1_000_000
const nBins = 100

func plotHistogram(r distuv.Rander, path string) {
	plt := plot.New()
	plt.X.Min = 0
	values := make(plotter.Values, 0)
	for i := 0; i < nSamples; i++ {
		v := r.Rand()
		values = append(values, v)
	}
	hist, err := plotter.NewHist(values, nBins)
	if err != nil {
		panic(err)
	}
	plt.Add(hist)
	if err := plt.Save(8*vg.Inch, 6*vg.Inch, path); err != nil {
		panic(err)
	}
}
```

</details>

![三角分布のヒストグラム](/img/blog/2026/09/triangle_histogram.png)

指定した通り最小値0、最頻値2、最大値10の乱数が生成されていることがわかる。

### 無限大まで分布させたい: カイ二乗分布

カイ二乗分布はカイ二乗検定で使われる確率分布で、パラメータとして自由度$k$を持つ。
統計検定に便利な性質があって使われる分布なのだが、今回注目したいのは最頻値だ。
カイ二乗分布の最頻値は自由度$k$が2以上の場合に$k-2$であり、とても制御しやすい。
たとえば最頻値を2にしたい場合は、2を足して自由度$k$を4に設定すればよい。

```go
	chi := distuv.ChiSquared{K: 4}
	plotHistogram(chi, "chi_squared_histogram.png")
```

![カイ二乗分布のヒストグラム](/img/blog/2026/09/chi_squared_histogram.png)

最頻値より大きい値はなだらかに確率が減少していく形になる。

### 最頻値未満の値を出したくない: 指数分布

指数分布はパラメータとして$\lambda$を持ち、最頻値は常に0である。
値に最頻値にしたい値$m$を足してシフトさせることで、任意の最頻値を持ち、値の範囲が$m$から無限大までの分布にできる。
この場合の期待値は$\frac{1}{\lambda}+m$となるので、$\lambda$を調整することで最頻値と独立して期待値も制御できる。

```go
type ShiftedExponential struct {
	Rander distuv.Rander
	Shift  float64
}

func (s ShiftedExponential) Rand() float64 {
	return s.Rander.Rand() + s.Shift
}
```

```go
	exp := ShiftedExponential{
		Rander: distuv.Exponential{Rate: 1},
		Shift:  2,
	}
	plotHistogram(exp, "shifted_exponential_histogram.png")
```

![シフト指数分布のヒストグラム](/img/blog/2026/09/shifted_exponential_histogram.png)

## おわりに

この記事では、ランダムな時間待機の際に最頻値を制御する方法として、3つの確率分布を紹介した。
何かの役に立てば幸いである。
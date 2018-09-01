---
date: 2017-10-04
aliases:
- /2017/10/04/calculating-the-distance-between-points-in-wrap-around-toroidal-space.html
title: "「ラップアラウンド」（トロイダル）な空間における2点間の距離の計算【翻訳】"
tags:
- tech
- translation
excerpt: "2次元上の2点間の距離を求めたいとしましょう、ただし点は古いテレビゲームのような“ラップアラウンド”の世界にあります – スクリーンの上下左右から出ると、反対側から現れるのです。"
mathjax: on
image: 2017/10/04/wraparound.png
---

この記事は、
[Calculating the Distance Between Points in “Wrap Around” (Toroidal) Space](https://blog.demofox.org/2017/10/01/calculating-the-distance-between-points-in-wrap-around-toroidal-space/)
を自分用に翻訳したものを
[許可を得て](https://blog.demofox.org/2017/10/01/calculating-the-distance-between-points-in-wrap-around-toroidal-space/#comment-526)
公開するものである。

ソース中にコメントの形で原文を残している。
誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---

<!--# [Calculating the Distance Between Points in “Wrap Around” (Toroidal) Space](https://blog.demofox.org/2017/10/01/calculating-the-distance-between-points-in-wrap-around-toroidal-space/)-->

<!-- Let’s say you are trying to find the distance between two points in 2D, but that these points are in a universe that “wraps around” like old video games – leaving the screen on the right, left, top or bottom side makes you re-appear on the opposite edge. -->

2次元上の2点間の距離を求めたいとしましょう、ただし点は古いテレビゲームのような“ラップアラウンド”の世界にあります – スクリーンの上下左右から出ると、反対側から現れるのです。

<!-- ![](https://demofox2.files.wordpress.com/2017/09/wraparound.png?w=800) -->

![https://demofox2.files.wordpress.com/2017/09/wraparound.png?w=800](/assets/2017/10/04/wraparound.png)

<!-- This universe is actually shaped like a toroid, also known as a doughnut. If you imagine yourself being on the inside surface of a hollow doughnut, it would behave exactly this way. If you go “down” you end up where you previously considered “up”. If you go far enough “left” you end up where you previously considered “right”. -->

この世界は、ドーナツとしても知られるトロイドのような形をしています。
空洞のドーナツの面にいることを想像すると、ちょうど同じ振る舞いをするでしょう。
あなたが“下“に行くと、先ほど”上“だと考えていたところに着きます。
あなたが“上“に行くと、先ほど”下“だと考えていたところに着きます。

<!-- How would you calculate the distance between two points in a universe like this? -->

このような世界で、どのように2点間の距離を求めればいいのでしょうか？

<!-- Let’s imagine the situation below where we are trying to find the distance between the red point and the green point: -->

下の状況で赤い地点と緑の地点の距離を求めようとしているとしましょう:

<!-- ![](https://demofox2.files.wordpress.com/2017/09/wraparound2.png?w=800) -->

![https://demofox2.files.wordpress.com/2017/09/wraparound2.png?w=800](/assets/2017/10/04/wraparound2.png)

<!-- One way to do this would be to pick one of the points (I’m picking red in this case) and clone it 8 times to surround the cell like the below. You’d calculate the distance from the green point to each of the 9 red points, and whatever distance was smallest would be the answer. -->

1つの方法として、点を1つ選んで(今回は赤にします)、下のようにセルを囲むよう8回クローンする、というのがあります。
緑の点からの距離を9つの赤い点でそれぞれ計算し、最も小さいものが答えになります。

<!-- ![](https://demofox2.files.wordpress.com/2017/10/wraparound3.png?w=800) -->

![https://demofox2.files.wordpress.com/2017/10/wraparound3.png?w=800](/assets/2017/10/04/wraparound3.png)

<!-- Something not so desirable about this is that it takes 9 distance calculations to find the minimum distance. You can work with squared distances instead of regular distances to avoid a square root on each of these distance calculations, but that’s still a bit of calculation to do. -->

最短距離を計算するために9回の計算をするというのは望ましいものではありません。
平方根の計算を避けるために距離の二乗を用いて計算することができますが、効果は微々たるものです。

<!-- Going up in dimensions makes the problem even worse. In 3D, it requires 27 distance calculations to find the shortest point, and 81 distance calculations in 4D! -->

次元が上がるとより悪いことになります。
3次元では最短距離を求めるのに27回の距離計算が必要になり、4次元では距離計算は81回になります！

<!-- Luckily there’s a better way to approach this. -->

幸運にもよりよい方法があります。

<!-- Let’s say that our universe (image) is 1 unit by 1 unit big (aka we are working in texture UVs). If you look at the image with 9 copies of the red dot, you can see that they are just the 9 possible combinations of having -1, +0, +1 on each axis added to the red dot’s coordinates. All possible combinations of the x and y axis having -1, +0 or +1 added to them are valid locations of the red dot. -->

世界(画像)の大きさが1単位だと(言い換えると、テクスチャUVを扱っていると)しましょう。
画像の赤い点の9つのコピーを見ると、それらは各座標軸に -1、+0、+1 を足した9つの組み合わせであることがわかります。
 -1、+0、+1 をx、y座標に足す全ての可能な組み合わせが赤い点の正しい座標になります。

<!-- Looking at the distance formula we can see that if we minimize each axis individually, that we will also end up with the minimal distance overall. -->

距離の公式を見ると、各座標軸の値を別々に最小化すれば、それが全体で最小距離にもなることがわかります。

<!-- ![d = \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}](https://s0.wp.com/latex.php?latex=d+%3D+%5Csqrt%7B%28x_2-x_1%29%5E2%2B%28y_2-y_1%29%5E2%7D&bg=ffffff&fg=666666&s=0 "d = \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}") -->

\\( d = \sqrt{(x_2-x_1)^2+(y_2-y_1)^2} \\)

<!-- So, the better way is to minimize each axis individually. -->

よって、各座標を別々に最小化するのがより良い方法です。

<!-- On the x axis you’d find if the x axis distance between the red and green point is minimal when you subtract 1 from the red dot’s x axis position, leave it alone, or add 1. -->

x座標から1を引いた、そのままにした、足したときに赤と緑の点のx座標の距離が最小になるなら、それが求めるx座標です。

<!-- Whichever x axis value of the red dot gives you the minimal x axis 1D distance is the x axis location to use. -->

x座標の1次元距離が最小の赤い点のx座標が目的の位置になります。

<!-- You’d repeat for the y axis to get the y axis location to use (and would repeat for any further axes for higher dimensions). -->

y座標でも同じように目的の位置を探します(さらに高次元の他の座標軸でも同様にします)。

<!-- This gives you the closest point which you can then plug into the distance formula to get the distance between the points in this wrap around space. -->

これがラップアラウンド空間の点の距離を得るために距離公式に当てはめる点になります。

<!-- You can actually do better though. -->

実はさらに良くできます。

<!-- Still working on each axis individually, you can calculate the absoluate value of the 1D distance between the two points on that axis. If that distance is greater than 0.5, the real distance for that axis is 1-distance. -->

各座標軸を別々に処理するため、2点間の1次元距離の絶対値を計算できます。
距離が0.5より大きい場合、その座標の実際の距離は 1 - 距離 です。

<!-- The intuition here is that if you are in a 1d repeating space, if going from A to B is more than half the distance, it means that you went the wrong way, and that going the other way is shorter. The distance of that other way is one minus whatever distance you just calculated since the distance from one point to itself is 1! -->

直感的に、1次元の繰り返し空間にいる場合、AからBへの道のりが半分より長いなら間違った道を進んでいるということであり、もう一方の道の方が短いということになります。
もう一方の道の距離は、ある点からそこに戻ってくるまでの距離が1であるため、1から先ほど計算した距離を差し引いたものです！

<!-- Do that for each axis and use those 1d distances in the distance formula to get the actual distance. -->

以上を各軸に対して行い、実際の距離を得るために距離公式でそれらの1次元距離を使います。

<!-- This lets you minimize the distance without having to explicitly figure out which combination makes the point closest. -->

これによりどの組み合わせが最も近い点かを明示的に把握することなく距離を最小化できます。

<!-- More importantly, it lets you efficiently calculate the distance between the two points in toroidal space (doughnut space!) -->

さらに重要なことに、トロイダル空間(ドーナツ空間)における2点間の距離を効率的に計算することができます！

<!-- The computational complexity is a lot better. It’s now linear in the number of dimensions: ![O(N)](https://s0.wp.com/latex.php?latex=O%28N%29&bg=ffffff&fg=666666&s=0 "O(N)"), instead of ![O(3^N)](https://s0.wp.com/latex.php?latex=O%283%5EN%29&bg=ffffff&fg=666666&s=0 "O(3^N)"). -->

計算量は非常に改善されます。
次元の数に対して\\(O(3^N)\\)だったものが線形\\(O(N)\\)になります。

<!-- Here is some C++ to show you how it would work in 2D. -->

こちらが2次元で動作するC++の例です。

<!-- ```cpp
float ToroidalDistance (float x1, float y1, float x2, float y2)
{
    float dx = std::abs(x2 - x1);
    float dy = std::abs(y2 - y1);
 
    if (dx > 0.5f)
        dx = 1.0f - dx;
 
    if (dy > 0.5f)
        dy = 1.0f - dy;
 
    return std::sqrt(dx*dx + dy*dy);
}
``` -->

```cpp
float ToroidalDistance (float x1, float y1, float x2, float y2)
{
    float dx = std::abs(x2 - x1);
    float dy = std::abs(y2 - y1);
 
    if (dx > 0.5f)
        dx = 1.0f - dx;
 
    if (dy > 0.5f)
        dy = 1.0f - dy;
 
    return std::sqrt(dx*dx + dy*dy);
}
```

<!-- I hit this problem trying to make a tileable texture. I needed to place a few circles on a texture such that the circles weren’t too close to each other, even when the texture was tiled. -->

私はタイル状に並べられるテクスチャを作るときにこの問題を思いつきました。
私はタイル状に並べても円が他の円と近づきすぎないように円を配置する必要がありました。

<!-- The calculations above gave me the basic tool needed to be able to calculate distances between points. Subtracting circle radii from the distance between points let me get toroidal distance between circles and make sure I didn’t place them too closely to each other. -->

上記の計算から点の距離を計算するための基礎的なツールが得られました。
点のトロイダルな距離から円の半径を引いて、それぞれが近づきすぎないようにしました。

<!-- That let me make an image that kept the distance constraints even when it was tiled. -->

そうして、タイル状に並べても距離の制約を維持し続ける画像ができました。

<!-- Here’s an example image by itself:   -->

こちらが画像の例です:

<!-- ![](https://demofox2.files.wordpress.com/2017/10/single2.png?w=800) -->

![https://demofox2.files.wordpress.com/2017/10/single2.png?w=800](/assets/2017/10/04/single2.png)

<!-- Here is the image tiled:   -->

こちらは並べたものです:

<!-- ![](https://demofox2.files.wordpress.com/2017/10/tiled2.png?w=800) -->

![https://demofox2.files.wordpress.com/2017/10/tiled2.png?w=800](/assets/2017/10/04/tiled2.png)
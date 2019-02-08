---
title: "ライブラリ不使用、数百行でレイトレーサを書いて新世界の神になる"
date: 2019-02-08
tags:
- dlang
- tech
---

レイトレーシングという3Dレンダリング手法があります。

> レイ トレーシング（ray tracing, 光線追跡法）は、光線などを追跡することで、ある点において観測される像などをシミュレートする手法である。
>
> [レイトレーシング - Wikipedia](https://ja.wikipedia.org/wiki/%E3%83%AC%E3%82%A4%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B7%E3%83%B3%E3%82%B0)

あるていど物理法則をシミュレートしていて、
その結果それなりにリアルな画像が出てくるというのが仮想的な世界を作っている感じでテンション上がりますよね。
というわけでいつか作ってみたいと思っていました。

### tinyraytracer

256行のC++でレイトレーサを書くという学習用リポジトリがあります。
標準ライブラリの機能のみを使いppm形式の画像を出力するレイトレーサを書いています。

[ssloy/tinyraytracer: A brief computer graphics / rendering course](https://github.com/ssloy/tinyraytracer)

それをもとにDで新世界の神になりました。
こんな感じの画像が出てきます。

![](/img/blog/2019/02/raytracer.jpg)

[kotet/tinyraytracer-d: https://github.com/ssloy/tinyraytracer](https://github.com/kotet/tinyraytracer-d)

300行以上に行数が増えてしまっているように見えます。
しかし実は元のtinyraytracerには`geometry.h`というヘッダファイルがあり、
そこで`vec3f`等のデータ構造が80行以上かけて実装されているのでこちらも厳密には256行ではありません。
なのでセーフです。
セーフです。

この記事ではtinyraytracerのコードと
[Wiki](https://github.com/ssloy/tinyraytracer/wiki)
をパッと読んだだけではわからなかったところを補足する計算ノートです。

### 球との衝突判定

```cpp
bool ray_intersect(const Vec3f &orig, const Vec3f &dir, float &t0) const {
        Vec3f L = center - orig;
        float tca = L*dir;
        float d2 = L*L - tca*tca;
        if (d2 > radius*radius) return false;
        float thc = sqrtf(radius*radius - d2);
        t0       = tca - thc;
        float t1 = tca + thc;
        if (t0 < 0) t0 = t1;
        if (t0 < 0) return false;
        return true;
    }
```

`t0`にはレイの起点から衝突地点までの距離が入ります。

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" viewBox="-0.5 -0.5 351 120"><defs></defs><g><ellipse cx="302" cy="10" rx="8" ry="8" fill="#ffffff" stroke="#000000" pointer-events="none"></ellipse><path d="M 27.69 88.79 L 288.19 13.97" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 293.24 12.52 L 287.47 17.81 L 288.19 13.97 L 285.54 11.09 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><ellipse cx="20" cy="91" rx="8" ry="8" fill="#ffffff" stroke="#000000" pointer-events="none"></ellipse><g transform="translate(8.5,102.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="22" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 22px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">orig</div></div></foreignObject><text x="11" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">orig</text></switch></g><g transform="translate(311.5,3.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="36" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 38px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">center<br></div></div></foreignObject><text x="18" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">center&lt;br&gt;</text></switch></g><path d="M 302 91 L 302 18" fill="none" stroke="#001dbc" stroke-miterlimit="10" pointer-events="none"></path><g transform="translate(304.5,44.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="14" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 16px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;"><font color="#001dbc">d2</font><br></div></div></foreignObject><text x="7" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><path d="M 282 91 L 282 71" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 302 71 L 282 71" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 22 91 L 295.63 91" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 300.88 91 L 293.88 94.5 L 295.63 91 L 293.88 87.5 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 22 91 L 55.63 91" fill="none" stroke="#009900" stroke-miterlimit="10" pointer-events="none"></path><path d="M 60.88 91 L 53.88 94.5 L 55.63 91 L 53.88 87.5 Z" fill="#009900" stroke="#009900" stroke-miterlimit="10" pointer-events="none"></path><g transform="translate(52.5,92.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="14" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 16px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;"><font color="#009900">dir</font></div></div></foreignObject><text x="7" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><g transform="translate(147.5,34.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="8" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 8px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">L<br></div></div></foreignObject><text x="4" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><g transform="translate(182.5,94.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="18" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 18px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">tca<br></div></div></foreignObject><text x="9" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">tca&lt;br&gt;</text></switch></g></g></svg>

---

$\vec{L}$と$\vec{dir}$の角度を$\theta$と置く。

$$ tca = \vec{L} \cdot \vec{dir} = |\vec{L}|\cos{\theta} $$

$$
\begin{align}
d_2 &= \vec{L} \cdot \vec{L} - tca^2 \\\\\\
    &= |\vec{L}|^2 - |\vec{L}|^2\cos^2{\theta} \\\\\\
    &= |\vec{L}|^2(1 - \cos^2{\theta}) \\\\\\
    &= (|\vec{L}|\sin{\theta})^2
\end{align}
$$

---

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" viewBox="-0.5 -0.5 394 201" style="background-color: rgb(255, 255, 255);"><defs></defs><g><ellipse cx="302" cy="91" rx="91" ry="91" fill="none" stroke="#000000" pointer-events="none"></ellipse><path d="M 342 172 L 302 92" fill="none" stroke="#cccc00" stroke-miterlimit="10" pointer-events="none"></path><ellipse cx="302" cy="91" rx="8" ry="8" fill="#ffffff" stroke="#000000" pointer-events="none"></ellipse><ellipse cx="20" cy="172" rx="8" ry="8" fill="#ffffff" stroke="#000000" pointer-events="none"></ellipse><g transform="translate(8.5,183.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="22" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 22px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">orig</div></div></foreignObject><text x="11" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">orig</text></switch></g><g transform="translate(311.5,84.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="36" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 38px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">center<br></div></div></foreignObject><text x="18" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">center&lt;br&gt;</text></switch></g><path d="M 302 172 L 302 99" fill="none" stroke="#001dbc" stroke-miterlimit="10" pointer-events="none"></path><g transform="translate(304.5,125.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="14" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 16px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;"><font color="#001dbc">d2</font><br></div></div></foreignObject><text x="7" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><path d="M 22 172 L 295.63 172" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 300.88 172 L 293.88 175.5 L 295.63 172 L 293.88 168.5 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><g transform="translate(182.5,175.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="18" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 18px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">tca<br></div></div></foreignObject><text x="9" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">tca&lt;br&gt;</text></switch></g><g transform="translate(312.5,155.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="18" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 18px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;"><font color="#006600">thc</font></div></div></foreignObject><text x="9" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><path d="M 302 171.5 L 342 171.5" fill="none" stroke="#005700" stroke-miterlimit="10" pointer-events="none"></path><g transform="translate(323.5,119.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="36" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 36px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;"><font color="#999900">radius</font></div></div></foreignObject><text x="18" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><ellipse cx="262" cy="171" rx="8" ry="8" fill="#ffffff" stroke="#000000" pointer-events="none"></ellipse><ellipse cx="342" cy="171" rx="8" ry="8" fill="#ffffff" stroke="#000000" pointer-events="none"></ellipse><g transform="translate(257.5,183.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="8" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 10px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">tca - thc</div></div></foreignObject><text x="4" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">tca - thc</text></switch></g><g transform="translate(337.5,182.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="8" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 10px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">tca + thc</div></div></foreignObject><text x="4" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">tca + thc</text></switch></g></g></svg>

---

$$ thc = \sqrt{radius^2 - d_2^2} $$

---

### スクリーン座標からの変換

```cpp
#pragma omp parallel for
for (size_t j = 0; j<height; j++) {
    for (size_t i = 0; i<width; i++) {
        float x =  (2*(i + 0.5)/(float)width  - 1)*tan(fov/2.)*width/(float)height;
        float y = -(2*(j + 0.5)/(float)height - 1)*tan(fov/2.);
        Vec3f dir = Vec3f(x, y, -1).normalize();
        framebuffer[i+j*width] = cast_ray(Vec3f(0,0,0), dir, sphere);
    }
}
```

---

$$  \frac{1}{width} - 1 \lt \frac{2(i+0.5)}{width} - 1 \lt 1 - \frac{1}{width} $$
$$ (0 \leq i \lt width) $$

---

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" viewBox="-0.5 -0.5 362 322" style="background-color: rgb(255, 255, 255);"><defs></defs><g><g transform="translate(65.5,142.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="28" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 30px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;"><font color="#006600">fov/2</font></div></div></foreignObject><text x="14" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><path d="M 200 32 L 200 0" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><path d="M 40 160 L 240 10" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 40.05 160.19 L 240 310" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 0 160 L 360 160" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><ellipse cx="38" cy="160" rx="8" ry="8" fill="#ffffff" stroke="#000000" pointer-events="none"></ellipse><path d="M 32.86 175.08 C 28.32 171.12 25.8 165.33 26.01 159.31" fill="none" stroke="#006600" stroke-miterlimit="10" transform="rotate(180,46,160)" pointer-events="none"></path><g transform="translate(26.5,132.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="22" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 22px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">z=0</div></div></foreignObject><text x="11" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">z=0</text></switch></g><g transform="translate(208.5,163.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="22" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 22px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">z=1<br></div></div></foreignObject><text x="11" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">z=1&lt;br&gt;</text></switch></g><ellipse cx="200" cy="40" rx="8" ry="8" fill="#ffffff" stroke="#000000" pointer-events="none"></ellipse><path d="M 200 272 L 200 48" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><g transform="translate(216.5,33.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="54" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 56px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">tan(fov/2)</div></div></foreignObject><text x="27" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">tan(fov/2)</text></switch></g><ellipse cx="200" cy="280" rx="8" ry="8" fill="#ffffff" stroke="#000000" pointer-events="none"></ellipse><path d="M 200 320 L 200 288" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><g transform="translate(218.5,273.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="60" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 60px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">-tan(fov/2)</div></div></foreignObject><text x="30" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">-tan(fov/2)</text></switch></g></g></svg>

### 反射

```cpp
Vec3f reflect(const Vec3f &I, const Vec3f &N) {
    return I - N*2.f*(I*N);
}
```

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" viewBox="-0.5 -0.5 470 169" style="background-color: rgb(255, 255, 255);"><defs></defs><g><path d="M 120 167 L 120 47" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><path d="M 0 127 L 240 127" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><path d="M 120 47 L 120 13.37" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 120 8.12 L 123.5 15.12 L 120 13.37 L 116.5 15.12 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 10 17 L 35.5 42.5" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 39.21 46.21 L 31.78 43.73 L 35.5 42.5 L 36.73 38.78 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 50 57 L 120 127" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 104.95 111.83 C 108.75 107.49 114.23 105 120 105" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 190 57 L 120 127" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 120 127 L 120 77" fill="none" stroke="#006600" stroke-miterlimit="10" pointer-events="none"></path><path d="M 70 75 L 120 75" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><g transform="translate(125.5,80.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="28" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 28px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;"><font color="#006600">cosθ</font></div></div></foreignObject><text x="14" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><g transform="translate(37.5,10.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="4" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 4px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">I</div></div></foreignObject><text x="2" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">I</text></switch></g><g transform="translate(134.5,10.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="10" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 10px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">N</div></div></foreignObject><text x="5" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">N</text></switch></g><path d="M 320 7 L 320 80.63" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 320 85.88 L 316.5 78.88 L 320 80.63 L 323.5 78.88 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 320 7 L 355.5 42.5" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 359.21 46.21 L 351.78 43.73 L 355.5 42.5 L 356.73 38.78 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 320 87 L 355.5 51.5" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 359.21 47.79 L 356.73 55.22 L 355.5 51.5 L 351.78 50.27 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><g transform="translate(241.5,38.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="76" height="16" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 76px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;"><font size="1">N×2</font><span>×</span><font size="1">(I・N)</font></div></div></foreignObject><text x="38" y="14" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><g transform="translate(347.5,10.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="4" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 4px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">I</div></div></foreignObject><text x="2" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">I</text></switch></g><path d="M 191 56 L 226.5 20.5" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 230.21 16.79 L 227.73 24.22 L 226.5 20.5 L 222.78 19.27 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><g transform="translate(206.5,10.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="6" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 8px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">I'</div></div></foreignObject><text x="3" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">I'</text></switch></g><g transform="translate(356.5,70.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="6" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 8px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">I' = I - N×2×(I・N)</div></div></foreignObject><text x="3" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">I'</text></switch></g></g></svg>

---

$$ I \cdot N = -\cos{\theta} $$

---

### 屈折

```cpp
Vec3f refract(const Vec3f &I, const Vec3f &N, const float &refractive_index) { // Snell's law
    float cosi = - std::max(-1.f, std::min(1.f, I*N));
    float etai = 1, etat = refractive_index;
    Vec3f n = N;
    if (cosi < 0) { // if the ray is inside the object, swap the indices and invert the normal to get the correct result
        cosi = -cosi;
        std::swap(etai, etat); n = -N;
    }
    float eta = etai / etat;
    float k = 1 - eta*eta*(1 - cosi*cosi);
    return k < 0 ? Vec3f(0,0,0) : I*eta + n*(eta * cosi - sqrtf(k));
}
```

<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" viewBox="-0.5 -0.5 249 209" style="background-color: rgb(255, 255, 255);"><defs></defs><g><path d="M 120 167 L 120 47" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><path d="M 0 127 L 240 127" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><path d="M 120 47 L 120 13.37" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 120 8.12 L 123.5 15.12 L 120 13.37 L 116.5 15.12 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 10 17 L 35.5 42.5" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 39.21 46.21 L 31.78 43.73 L 35.5 42.5 L 36.73 38.78 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 50 57 L 120 127" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 104.95 111.83 C 108.75 107.49 114.23 105 120 105" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 160 207 L 120 127" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 120 127 L 120 77" fill="none" stroke="#006600" stroke-miterlimit="10" pointer-events="none"></path><path d="M 70 75 L 120 75" fill="none" stroke="#000000" stroke-miterlimit="10" stroke-dasharray="3 3" pointer-events="none"></path><g transform="translate(127.5,80.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="24" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 24px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;"><font color="#006600">cosi</font></div></div></foreignObject><text x="12" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><g transform="translate(37.5,10.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="4" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 4px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">I</div></div></foreignObject><text x="2" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">I</text></switch></g><g transform="translate(134.5,10.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="10" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 10px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">N</div></div></foreignObject><text x="5" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">N</text></switch></g><g transform="translate(108.5,88.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="2" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 4px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">i</div></div></foreignObject><text x="1" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">[Not supported by viewer]</text></switch></g><path d="M 106.86 121.92 C 110.51 118.75 115.17 117 120 117" fill="none" stroke="#000000" stroke-miterlimit="10" transform="rotate(180,120,137)" pointer-events="none"></path><g transform="translate(127.5,160.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="4" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 4px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">t</div></div></foreignObject><text x="2" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">t</text></switch></g><path d="M 200 117 L 233.63 117" fill="none" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><path d="M 238.88 117 L 231.88 120.5 L 233.63 117 L 231.88 113.5 Z" fill="#000000" stroke="#000000" stroke-miterlimit="10" pointer-events="none"></path><g transform="translate(215.5,98.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="8" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 8px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">e</div></div></foreignObject><text x="4" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">e</text></switch></g><g transform="translate(9.5,108.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="20" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 22px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">etai</div></div></foreignObject><text x="10" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">etai</text></switch></g><g transform="translate(8.5,130.5)"><switch><foreignObject style="overflow:visible;" pointer-events="all" width="22" height="13" requiredFeatures="http://www.w3.org/TR/SVG11/feature#Extensibility"><div xmlns="http://www.w3.org/1999/xhtml" style="display: inline-block; font-size: 12px; font-family: Helvetica; color: rgb(0, 0, 0); line-height: 1.2; vertical-align: top; width: 22px; white-space: nowrap; overflow-wrap: normal; text-align: center;"><div xmlns="http://www.w3.org/1999/xhtml" style="display:inline-block;text-align:inherit;text-decoration:inherit;">etat</div></div></foreignObject><text x="11" y="13" fill="#000000" text-anchor="middle" font-size="12px" font-family="Helvetica">etat</text></switch></g></g></svg>

---

参考: [t-pot『Ray Tracing : Reflection & Refraction』](https://t-pot.com/program/96_RayTraceReflect/index.html)

屈折光の向きを表す単位ベクトルを$\vec{T}$、水平方向の単位ベクトルを$\vec{e}$とおく。

$$ \vec{T} = -\vec{N} \cos{t} + \vec{e} \sin{t} $$
$$ cosi = -(\vec{I} \cdot \vec{N}) $$

$\vec{e}\sin{i} = \vec{N}\cos{i} + \vec{I} = cosi\vec{N} + \vec{I}$より

$$
\begin{align}
\vec{T} &= -\vec{N} \cos{t} + \frac{cosi\vec{N} + \vec{I}}{\sin{i}} \sin{t} \\\\\\
        &= -\vec{N} \cos{t} + \frac{\sin{t}}{\sin{i}} (cosi\vec{N} + \vec{I})
\end{align}
$$

スネルの法則 $\frac{\sin{t}}{\sin{i}} = \frac{etai}{etat} = eta$ より

$$
\begin{align}
\vec{T} &= -\vec{N} \cos{t} + eta (cosi\vec{N} + \vec{I}) \\\\\\
        &= -\vec{N} \sqrt{1 - \sin^2{t}} + eta (cosi\vec{N} + \vec{I}) \\\\\\
        &= -\vec{N} \sqrt{1 - eta^2 \sin^2{i}} + eta (cosi\vec{N} + \vec{I}) \\\\\\
        &= -\vec{N} \sqrt{1 - eta^2 (1-cosi^2)} + eta (cosi\vec{N} + \vec{I}) \\\\\\
        &= -\vec{N} \sqrt{k} + eta (cosi\vec{N} + \vec{I}) \\\\\\
        &= \vec{I} \times eta + \vec{N}(eta \times cosi - \sqrt{k}) \\\\\\
\end{align}
$$
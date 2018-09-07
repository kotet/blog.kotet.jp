---
date: 2018-08-23
aliases:
- /2018/08/23/a-web-design-crush-course.html
title: "非デザイナーによる非デザイナーのための短期集中Webデザイン講座【翻訳】"
tags:
- webdesign
- tech
- translation 
excerpt: "先に言っておくと、私はプロのデザイナーではありません。 ですが、私はかわいいものを作るのが好きで、いろいろと作ってきました。 多くのデベロッパーはデザインに悩まされているので、 私はサイトのビジュアルを改善するためのヒントを実演しつつ書きたいと思います。 ルールは破られるためにあるものですが、優れたウェブサイトを簡単に作りたいときには、 役に立ついくつかのルールがあります!"
---

この記事は、
[The Zen of Programming](https://zen-of-programming.com/) の
[A Web Design Crash Course: From one non-designer to another](https://zen-of-programming.com/design/)
を翻訳したものを
[許可を得て](https://twitter.com/ASpittel/status/1032079437435727872)
公開するものである。

ソース中にコメントの形で原文を残している。
何か気になるところがあれば
[Pull request](https://github.com/kotet/blog.kotet.jp)だ!

---

![ヘッダー](/assets/2018/08/web-design-crush-cource.png)

<!-- I will preface this by saying that I'm not professionally a designer. That being said, I like building pretty things and have had some success with that. A lot of developers seem overwhelmed by design, so I wanted to do a quick write\-up with visual examples with quick tips on how to improve the visuals of your site. Rules are made to be broken, but if you want to make a great website as easily as possible, these are some good rules of thumb! -->

先に言っておくと、私はプロのデザイナーではありません。
ですが、私はかわいいものを作るのが好きで、いろいろと作ってきました。
多くのデベロッパーはデザインに悩まされているので、
私はサイトのビジュアルを改善するためのヒントを実演しつつ書きたいと思います。
ルールは破られるためにあるものですが、優れたウェブサイトを簡単に作りたいときには、
役に立ついくつかのルールがあります!

<!-- ## Color -->

### 色

<!-- I really enjoy playing with color on my websites, but there needs to be a balance and a coordinated color scheme for the site to look cohesive and professional. It's essential that these colors don't clash, that they have a reasonable level of contrast, and that they are consistent. -->

私はウェブサイトの色をいじるのが好きですが、色のバランスがとれている必要があり、
サイトの見た目を人を引きつけてプロフェッショナルに見えるものにする調整されたカラースキームが必要です。
色どうしが衝突しないように、合理的なレベルのコントラストと、一貫性を持っていなければなりません。

<!-- ### Consistency -->

#### 一貫性

<!-- Here's my color scheme for [The Zen of Programming](https://zen-of-programming.com): -->

これが [The Zen of Programming](https://zen-of-programming.com) (訳注: 原文のサイト) のカラースキームです:

<!-- ![](/design/colors.png) -->

![カラースキーム](/assets/2018/08/colors.png)

<!-- I use the same hex codes for green, pink, and grey for my backgrounds, headers, text, and buttons. -->

背景、ヘッダー、テキスト、ボタンに使われているグリーン、
ピンク、グレーは同じヘックスコードのものを使っています。

<!-- You can use CSS variables to make sure that your colors are the same throughout your code. -->

コード全体で同じ色を使うために CSS variables を使えます。

<!-- ```css
body {
  --pink: #CF92B7;
  --green: #59876B;
  --grey: #4A4A4A;
}

h1 {
  color: var(--pink);
}
``` -->

```css
body {
  --pink: #CF92B7;
  --green: #59876B;
  --grey: #4A4A4A;
}

h1 {
  color: var(--pink);
}
```

<!-- If you are using SCSS or another CSS preprocessor, this is even easier! -->

SCSS やその他 CSS プリプロセッサーを使っていれば、もっと簡単になるでしょう!

<!-- As far as the number of colors involved in your theme, four is usually a good bet. Maybe make two of these colors neutrals (like black, white, or grey) and two bolder pops of color. Monochromatic color schemes that use shades of one color can definitely work as well! -->

サイトテーマに必要な色は4つくらいでしょう。
そのうち2色(黒、白、グレーなど)をニュートラルカラーに、残り2色を強調色にするのです。
モノクロマティックカラーを色の影として使うと非常に良いです!

<!-- When I work with rainbow color schemes, I treat the rainbow as one color and then use two neutrals for everything else. For example, on [alispit.tel](https://alispit.tel) I use a dark grey for some text, white for the background, and then the rainbow colors for letters and random shapes. -->

レインボーカラースキームを使うときは、私はレインボーを1つの色として扱い、
それ以外すべてに2つのニュートラルを使います。
たとえば、[alispit.tel](https://alispit.tel) ではダークグレーをテキストに、
白を背景に、レインボーカラーを文字と図形に使いました。

<!-- ![](/portfolio/current-portfolio.png) -->

![ポートフォリオ](/assets/2018/08/current-portfolio.png)

<!-- ### Clashing Colors -->

#### 色の衝突

<!-- It's important to make sure your colors look good together and don't clash. Usually, the colors opposite to each other on the color wheel clash. Of course, you can make excellent websites that utilize clashing colors, but it is more difficult and may be better left to designers. Some examples would be red and green or orange and purple. -->

色が共によく見えて衝突しないようにするのは重要です。
通常、カラーホイールの反対側にある色どうしは衝突します。
もちろん色の衝突を活かした素晴らしいウェブサイトを見ることはあるでしょうが、
それは難しく、デザイナーに任せたほうが良いでしょう。

<!-- Also, keep the tones of the colors in mind \-\- if you are using a cool toned pink, a cool toned green may be good to pair with it instead of a warm\-toned green. Warm\-toned colors have redder undertones, and cool toned colors are bluer. -->

更に、色の色調を考慮しましょう。
クールな色調のピンクを使ったなら、
温かい色調のグリーンよりクールな色調のグリーンのほうがよく合います。
温かい色調の色は赤い色合いをしており、クールな色調の色はより青っぽいです。

<!-- ### Contrast -->

#### コントラスト

<!-- Make sure there's a reasonable level of contrast between the colors on your website. If there isn't, it will be much more difficult to read your content. [Here's](https://marijohannessen.github.io/color-contrast-checker/) an awesome site that will check your contrast for you. Lighthouse testing will also check this for you! In general, put light colors on top of dark ones, and dark colors on top of light ones! -->

ウェブサイトの色の間には合理的なレベルのコントラストをもたせましょう。
そうでないと、コンテンツが読みにくくなってしまいます。
[こちら](https://marijohannessen.github.io/color-contrast-checker/)の素晴らしいサイトでは、
色どうしのコントラストを確認できます。
Lighthouse testingでもチェックができます!
一般的に、暗い色の上には明るい色を、明るい色の上には暗い色を置きます!

<!-- ![](/design/contrast.png) -->

![コントラスト](/assets/2018/08/contrast.png)


<!-- ### Color Meaning -->

#### 色の意味

<!-- If you are working on a website for a brand, different colors have different [implicit meanings](https://graf1x.com/color-psychology-emotion-meaning-poster/) to readers, and they can convey different moods so it can be helpful to keep those in mind. -->

もしブランドのためにウェブサイトを作っているなら、色はそれぞれ異なる
[暗黙的意味](https://graf1x.com/color-psychology-emotion-meaning-poster/)
を読者に与え、異なる雰囲気を伝えるので、覚えておくと良いでしょう。

<!-- ### Tips for choosing colors -->

#### 色選びのヒント

<!-- There are a lot of awesome websites that make it easier to pick good color palettes that coordinate well. -->

うまく管理されたカラーパレットを簡単に選べる素晴らしいサイトが多数あります。

<!-- I sometimes use the [Coolors](https://coolors.co/) generator when I'm building a new site. I also follow [this account](https://www.instagram.com/colours.cafe/) on Instagram, and I will save color palettes that I like when I see them. Finally, If I just want to see a bunch of colors and choose between them, I use the [color](https://materializecss.com/color.html) page on Materialize \-\- I like their colors! -->

私は新しいサイトを作るとき [Coolors](https://coolors.co/) ジェネレーターを使ったりします。
Instagramの[このアカウント](https://www.instagram.com/colours.cafe/)もフォローしており、
気に入ったものを見かけたらカラーパレットを保存しています。
最後に、ただ色をたくさん見てその中から選びたいなら、私は Materialize の
[color](https://materializecss.com/color.html) のページを見ます。
私はこのサイトにある色が好きです!

<!-- ## Text -->

### テキスト

<!-- On most sites, the text will be the most critical part. You need it to be easy to read and for the most important content to be emphasized. -->

多くのサイトにおいて、テキストは最も重要な部分です。
読みやすく、かつ重要なコンテンツが強調されなければいけません。

<!-- Here's an example of really hard to read text: -->

これはとても読みにくいテキストの例です:

<!-- ![Example of hard to read website content text](/design/text-before.png) -->

![読みにくいテキスト](/assets/2018/08/text-before.png)

<!-- Let's work on making it more readable! -->

これをもっと読みやすくしていきましょう!

<!-- ### Spacing -->

#### スペーシング

<!-- Add spacing to your text content. There are a few types of spacing that can make your content more readable. The first is adding padding on the sides of your page. -->

文字同士の間隔をテキストコンテンツに追加しましょう。
コンテンツを読みやすくするスペーシングにはいくつか種類があります。
最初はパディングをページの左右に追加することです。

<!-- #### On the sides of your content -->

##### コンテンツの左右

<!-- On a lot of websites \-\- the text won't span the width of the page, it will be inside of a container that takes up only part of the page. This makes the content more comfortable to read since your eyes need to move less, and the page will look better. The [W3C](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#visual-audio-contrast-visual-presentation) recommends fewer than 80 characters per line. -->

テキストがページの幅に応じて広がらないウェブサイトの多くで、
テキストはページの一部を囲むコンテナーの中にあります。
これは目の動きを減らすことでコンテンツを快適に読めるようにして、ページの見た目を良くします。
[W3C](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#visual-audio-contrast-visual-presentation)
は一行あたり80文字未満を推奨しています。

<!-- ```html
<style>
  .container {
    width: 80%;
    margin: 0 auto; /* centers the div on the page */
  }
</style>

<div class="container">
  <p>
    Lorem ipsum dolor amet master cleanse cloud bread brunch pug PBR&B actually. 
    Thundercats marfa art party man bun gluten-free sriracha. DIY tofu cred blue bottle etsy. 
    Retro listicle normcore glossier next level etsy lumbersexual polaroid pour-over 90's 
    slow-carb health goth banjo. Unicorn chicharrones 8-bit poke glossier.
  </p>
</div>
``` -->

```html
<style>
  .container {
    width: 80%;
    margin: 0 auto; /* ページ中の div を中央寄せ */
  }
</style>

<div class="container">
  <p>
    Lorem ipsum dolor amet master cleanse cloud bread brunch pug PBR&B actually. 
    Thundercats marfa art party man bun gluten-free sriracha. DIY tofu cred blue bottle etsy. 
    Retro listicle normcore glossier next level etsy lumbersexual polaroid pour-over 90's 
    slow-carb health goth banjo. Unicorn chicharrones 8-bit poke glossier.
  </p>
</div>
```

<!-- #### Line Height -->

##### 行の高さ

<!-- We can add line\-height to add more space between lines of text. The most recent Android operating system added a more substantial line\-height to notifications, which makes them easier to read at a glance. -->

Line-height を設定してテキストの行の間に空間を追加しましょう。
最新の Android オペレーティングシステムは通知にかなりの line-height を設けており、
これがひと目で読めるようにしています。

<!-- Also, it is best for accessibility purposes to add more line\-height \-\- the W3C recommendation is 1.5 to 2.0. Remember having to double space essays in high school? We're doing the same thing here, just online this time! -->

さらに、line-height を大きく取ることはアクセシビリティにも適しています。
W3Cの推奨値は1.5から2.0です。
高校でダブルスペース形式のエッセイを書いたのを覚えていますか?
あれと同じことを今度はオンラインでやりましょう!

<!-- ```css
p {
  font-size: 18px;
  line-height: 2.0;
}
``` -->

```css
p {
  font-size: 18px;
  line-height: 2.0;
}
```

<!-- This will transform the text on the left to the text on the right in the image below. -->

これは画像左側のようなテキストを右側のようなテキストに変形します。

<!-- ![Line height demo](/design/line-height.png) -->

![CSSの適用前と適用後](/assets/2018/08/line-height.png)

<!-- #### Paragraph Padding -->

##### パラグラフ間の余白

<!-- I would also make sure to add padding in between your paragraphs so that it is easy to differentiate between them. -->

パラグラフの区別が付きやすいように、パラグラフ間のパディングを見直しましょう。

<!-- ```css
p {
  padding-bottom: 27px;
}
``` -->

```css
p {
  padding-bottom: 27px;
}
```

<!-- ![Paragraph padding demo](/design/paragraph-padding.png) -->

![パディング適用前と適用後](/assets/2018/08/paragraph-padding.png)

<!-- #### Word Spacing -->

##### ワードスペーシング

<!-- If you are using all\-caps for a header, you may want to add more spacing in between words so that it is easier to differentiate between them. -->

すべて大文字のヘッダーを使う場合、単語間のスペースをより大きく取ると単語の区別が付きやすくなります。

<!-- Here is my blog's header with additional word spacing: -->

これはワードスペーシングを大きく取った私のブログのヘッダーです:

<!-- ![](/design/with-word-spacing.png) -->

![ヘッダー](/assets/2018/08/with-word-spacing.png)

<!-- And here it is without: -->

そしてこれが設定しなかった場合です:

<!-- ![](/design/without-word-spacing.png) -->

![スペーシング未設定のヘッダー](/assets/2018/08/without-word-spacing.png)

<!-- ```css
h1 {
  word-spacing: 9px;
}
``` -->

```css
h1 {
  word-spacing: 9px;
}
```

<!-- The first is a lot easier to read! -->

最初のほうが読みやすいです!

<!-- ### Alignment -->

#### アラインメント

<!-- It is easiest to read content if it is aligned to the left and un\-justified for English and other top\-left to right languages. Your content will be this way by default! Just make sure you don't have a `text-align: center;` on it! Feel free to center your headers or the container your text is in, but have long blocks of content left\-aligned. -->

英語やその他左上から右に読む言語の場合、
左寄せされて均等割付されていないコンテンツが一番読みやすいです。
デフォルトでコンテンツはそのようになっています!
`text-align: center;`しないでください!
ヘッダーやテキストの入ったコンテナーの中央寄せは自由にしていいですが、
コンテンツのロングブロックは左寄せしてください。

<!-- ### Readable fonts -->

#### 可読性の高いフォント

<!-- Some fonts are easier to read than others. For content on the web, it is generally easier to read fonts that are sans\-serif. Serifs are the little points that come off of the ends of letters in some fonts \-\- you can see a serif in the green circle in the diagram below! -->

他より読みやすいフォントというのがあります。
Web上のコンテンツの場合、一般に sans-serif が読みやすいフォントです。
セリフ (serif) というのはフォントによって失われていることもある文字の端の小さいやつのことです。
下図の緑の丸の中にセリフがあるでしょう!

<!-- ![Sans-serif vs serif font](/design/font-types.png) -->

![Sans-serif vs serif](/assets/2018/08/font-types.png)

<!-- My rule of thumb is one decorative (think cursive or un\-traditional) font or a serif font for headers and one sans\-serif font for content per website. -->

私はデコレーティブ (手書きっぽい、または非伝統的) フォントや serif フォントをヘッダーに、
sans-serif フォントはWebサイトのコンテンツに使うと決めています。

<!-- #### Some of my favorite fonts: -->

##### 私のお気に入りのフォント

<!-- **Serif and Decorative**

*   [Pacifico](https://fonts.google.com/specimen/Pacifico)
*   [Righteous](https://fonts.google.com/specimen/Righteous)
*   [Lobster](https://fonts.google.com/specimen/Lobster) -->

**Serif と デコレーティブ**

*   [Pacifico](https://fonts.google.com/specimen/Pacifico)
*   [Righteous](https://fonts.google.com/specimen/Righteous)
*   [Lobster](https://fonts.google.com/specimen/Lobster)

<!-- **Sans\-Serif**

*   [Roboto](https://fonts.google.com/specimen/Roboto)
*   [Lato](https://fonts.google.com/specimen/Lato)
*   [Montserrat](https://fonts.google.com/specimen/Montserrat)
*   [Fira Sans](https://fonts.google.com/specimen/Fira+Sans)
*   Arial \- this one comes on your computer -->

**Sans-Serif**

*   [Roboto](https://fonts.google.com/specimen/Roboto)
*   [Lato](https://fonts.google.com/specimen/Lato)
*   [Montserrat](https://fonts.google.com/specimen/Montserrat)
*   [Fira Sans](https://fonts.google.com/specimen/Fira+Sans)
*   Arial - これはコンピュータに入っています

<!-- ### Color -->

#### 色

<!-- Black text on a white background can cause eye strain because of too much contrast. I use dark greys for my content. Then, there is still a lot of contrast, but not as much as there would be with black text. -->

白い背景に黒のテキストはコントラストが過剰になるために目の疲れを引き起こします。
私はコンテンツにダークグレーを使っています。
これもコントラストは大きいですが、黒色のテキストほどではありません。

<!-- ```css
p {
  color: #4A4A4A;
}
``` -->

```css
p {
  color: #4A4A4A;
}
```

<!-- The same is true with backgrounds \-\- a pure black is often not the best choice \-\- a dark navy or grey will make your content easier to read. -->

背景にも同じことが言えます。
ピュアブラックはたいてい最良の選択肢ではありません。
ダークネイビーやグレーにするとコンテンツが読みやすくなります。

<!-- ### Sizing -->

#### サイジング

<!-- There are differing opinions on how large your content should be and what unit of measurement you should use (em vs. px for example); however, the consensus leans towards 16\-18 pixels and having that scale for people who zoom in or out on your site. -->

コンテンツの大きさをどれくらいにするべきか、単位は何を使うべきか (たとえば em 対 px など)
については様々な意見があります。
しかし、16-18ピクセルくらいにしてズームイン /
ズームアウトできるようにするという方にコンセンサスは傾いています。

<!-- Headers of varying types should be larger than your content. Also, use different font weights to differentiate text. -->

各種ヘッダーはコンテンツよりも大きくなければいけません。
さらに、テキストと区別できるように異なるフォントウェイトを使いましょう。

<!-- ![](/design/text-emphasis.png) -->

![強調されたテキストとそうでないテキスト](/assets/2018/08/text-emphasis.png)

<!-- ## Once we change these things... -->

### 全部を一度に……

<!-- Our content becomes a lot easier to read! -->

コンテンツは非常に読みやすくなりました!

<!-- ![](/design/more-readable.png) -->

![読みやすいテキスト](/assets/2018/08/more-readable.png)

<!-- ## Backgrounds -->

### 背景

<!-- Making background images look good, especially with text on top of them, is really difficult. I would avoid background images unless they are critical to the site. I'm going to give a couple alternatives and solutions for making background images work if you still decide to use one! -->

背景画像は見た目が良くなります。
テキストが上にある場合、問題は難しくなります。
私はそれがサイトにとって重要でない限り背景画像を使うのは避けます。
2つの代替案と、既に背景画像を使うと決めてしまったときのためのソリューションを紹介します!

<!-- On the below image, the text is challenging to read. -->

下の画像では、テキストは非常に読みづらくなっています。

<!-- ![](/design/before-background.png) -->

![読みにくいテキスト](/assets/2018/08/before-background.png)

<!-- ### Split the Page -->

#### ページを分割する

<!-- If you want to keep the image, you could split the page so that the picture displays on one half and the text on the other. -->

画像に手を加えたくないなら、ページを分割して半分は画像を、もう半分はテキストを表示するという方法があります。

<!-- ![](/design/split-screen.png) -->

![分割されたページ](/assets/2018/08/split-screen.png)

<!-- ```html
<style>
  .container {
    display: grid;
    grid-template-columns: 1fr 1fr;
  }
</style>

<div class="container">
  <div class="text">
    My Text
  </div>
  <img src="path/to/img">
</div>
``` -->

```html
<style>
  .container {
    display: grid;
    grid-template-columns: 1fr 1fr;
  }
</style>

<div class="container">
  <div class="text">
    My Text
  </div>
  <img src="path/to/img">
</div>
```

<!-- ### Use a less busy picture -->

#### 複雑な画像を使わない

<!-- If you want to keep the full page background image, if possible, use a simple picture without too much going on. In the one I'm using above, there are a lot of colors and large text that the user can still read. Using an image of a landscape or a pattern will be less distracting. -->

画面いっぱいの背景画像を維持したいなら、できればシンプルな画像を使いましょう。
上で使っている画像は、色が多く、テキストもユーザーが読めてしまうほど大きいです。
風景やパターンの画像を使うことで注意がそれにくくなります。

<!-- ### Add Text Shadow -->

#### テキストシャドウを追加する

<!-- You can also add a text shadow below your text to make it more readable. -->

テキストシャドウをテキストの下に追加して読みやすくもできます。

<!-- ```css
.text {
  text-shadow: #4A4A4A 1px 1px 8px;
}
``` -->

```css
.text {
  text-shadow: #4A4A4A 1px 1px 8px;
}
```

<!-- With the above changes in place and an increased font\-size, the font on a background image becomes a lot easier to read! -->

上記の変更とともにフォントサイズも大きくすれば、
テキストの位置をを変えずに背景画像の上の文字は読みやすくなります!

<!-- ![](/design/background-better.png) -->

![読みやすいテキスト](/assets/2018/08/background-better.png)

<!-- ### Background Colors -->

#### 背景色

<!-- I wouldn't use a super bright color for your background. Pretty much any color will be difficult to read on top of it, and it may strain people's eyes to read. -->

私は背景画像に明るい色は使いません。
過剰な色彩は上にある文字を読みにくくして、読む人の目に負荷をかけます。

<!-- ## Calls to Action -->

### 行動の喚起

<!-- When you build a website, there's usually something that you want the user to do. On e\-commerce sites, you want the user to buy something. On a portfolio you probably want the viewer to contact you. On a blog, you want the user to subscribe. When you're designing a site, keep that action in mind. You may want to use a bright color, larger text, or feature that "call to action" on multiple places on your site. You also may want to make sure that it is visible everywhere on the site. -->

ウェブサイトを作るときには、普通なにかユーザーにしてほしいことがあります。
e-コマースのサイトでは、何かを買ってほしいでしょう。
ポートフォリオでは、誰かにコンタクトを取りに来てほしいはずです。
ブログでは、ユーザーにサブスクライブしてほしいですね。
サイトのデザイニングの際には、それら期待する行動を考慮しましょう。
明るい色、大きなテキスト、その他注意を引く機能をサイトの複数の箇所に使いたくなるかもしれません。
サイトのあらゆる場所が目立つようにしたくなることもあるかもしれません。

<!-- For example, my subscribe form for my blog is always in the sidebar, and it has color on it to grab the reader's attention. On my portfolio, I have links to my social media accounts on the home, about, and contact pages. -->

例えば、私のブログのサブスクライブフォームは常にサイドバーに設置され、
その色は読み手の注意を惹きます。
私のポートフォリオでは、ソーシャルメディアのアカウントへのリンクを Home 、
About 、 Contact のページに設置しています。

<!-- Emphasizing the important content will look different on every site, but it's important to keep the action you want the user to take in mind with each design choice you make. -->

重要なコンテンツの強調法は各サイトで異なりますが、
重要なのはそのデザインチョイスがユーザーに期待する行動のことを考えているかどうかです。

<!-- ## More Reading -->

### 追加の参考情報

<!-- *   [Smashing Magazine](https://www.smashingmagazine.com/articles/) \- lots of design articles on here
*   [Designing with Sketch](https://dev.to/aspittel/designing-with-sketch-42jp) \- an article I wrote on how to use the design software Sketch, which is what I use to design everything. A lot of the steps will apply to other design software as well.
*   [Hello Web Design](https://hellowebbooks.com/learn-design/) \- This is an awesome book that discusses web design geared towards beginners.
*   [The Little Details of UI Design](https://speakerdeck.com/sschoger/the-little-details-of-ui-design) \- An excellent slide deck that goes through a LinkedIn redesign \-\- this one is a little more advanced. -->

*   [Smashing Magazine](https://www.smashingmagazine.com/articles/) -
    デザインに関する多くの記事があります
*   [Designing with Sketch](https://dev.to/aspittel/designing-with-sketch-42jp) -
    私の書いたこの記事では、私がデザインをするときいつも使っているデザインソフトウェア
    Sketch の使い方を紹介しています。
    他のデザインソフトウェアで同じことをするには多くの手間が必要になるでしょう。
*   [Hello Web Design](https://hellowebbooks.com/learn-design/) -
    初心者向けに考えられた形でウェブデザインについて論じている素晴らしい本です
*   [The Little Details of UI Design](https://speakerdeck.com/sschoger/the-little-details-of-ui-design) -
    LinkedIn のリデザインについての優れたスライドです。
    少し発展的な内容になります。

<!-- ## UI Frameworks -->

### UI フレームワーク

<!-- You may not want to start from scratch when you design a site, so using a UI Framework may be helpful. Some of these include [Bootstrap](https://v4-alpha.getbootstrap.com/), which I would make sure to customize since its heavily used; [Materialize](https://materializecss.com/), which follows Google's Material design philosophy; and [Grommet](http://grommet.io/), my favorite aesthetically \-\- it also emphasizes accessibility. -->

サイトのデザインをゼロから行おうと考えていないなら、UI フレームワークが役に立つでしょう。
よく使われるのは [Bootstrap](https://v4-alpha.getbootstrap.com/) です。
私はヘビーユーザーなのでカスタマイズして使います。
[Materialize](https://materializecss.com/) は Google
のマテリアルデザイン哲学に沿うようにできています。
[Grommet](http://grommet.io/) は審美的に気に入っています。
これはアクセシビリティにも焦点を当てています。

<!-- ## Design Checklist -->

### デザインチェックリスト

<!-- Since this is a pretty long post with a lot of tips, I wanted to distill the most important information into a checklist. It's written in GitHub markdown, so you can copy and paste it onto an issue or into a markdown file. Then you can either check the box or replace the space with an `x` for each action item. -->

この記事には多くのヒントがありとても長いので、最も重要な情報のみをチェックリストにまとめました。
これは GitHub markdown で書かれているので、 issue や markdown ファイルにコピペできます。
そして各アイテムについてボックスにチェックをするか空白を `x` で置き換えるのです。

<!-- ```md
## Color

- [ ] Uses consistent colors throughout
- [ ] Uses non-clashing colors
- [ ] The color choice makes sense for the business purpose of the site

## Text

- [ ] The text has padding on both sides.
- [ ] The line-height is 1.5-2.0
- [ ] There's padding between paragraphs
- [ ] If your headings are in all caps, there's increased word spacing
- [ ] Blocks of text are un-justified
- [ ] Blocks of text are left-aligned
- [ ] Sans-serif fonts are used for body text
- [ ] A maximum of two fonts are used - one decorative or serif and one sans-serif
- [ ] body text isn't pure black on white
- [ ] body text is 16-18px and is scalable

## Backgrounds

- [ ] Use a pattern or simple image
- [ ] A text shadow is used to make headings readable
- [ ] The background isn't too bright

## Calls to Action

- [ ] Important information is highlighted in order to attract user interaction
``` -->

```md
## 色

- [ ] 全体を通して一貫性を持って色を使う
- [ ] 衝突しない色を使う
- [ ] サイトの目的にあった色を選ぶ

## テキスト

- [ ] テキストの両側にパディングを設ける
- [ ] Line-height を1.5-2.0にする
- [ ] パラグラフ間にパディングを設ける
- [ ] ヘッダーがすべて大文字の場合、ワードスペーシングを大きくする
- [ ] テキストを均等割付しない
- [ ] テキストを左寄せする
- [ ] Sans-serif フォントを本文に使う
- [ ] 最大で2個のフォントを使う。デコレーティブ / Serif と　Sans-serif
- [ ] 本文を白地にピュアブラックにしない
- [ ] 本文を16-18px かつスケーラブルにする

## 背景

- [ ] パターン画像やシンプルな画像を使う
- [ ] テキストシャドウでヘッダーの可読性を上げる
- [ ] 背景が明るくなりすぎないようにする

## 行動喚起

- [ ] ユーザーのインタラクションを喚起するために重要な情報を強調する
```

<!-- ## Keep in Touch -->

### 交流

<!-- If you liked this article and want to read more, I have a [weekly newsletter](https://tinyletter.com/ali_writes_code) with my favorite links from the week and my latest articles. Also, [tweet](https://twitter.com/aspittel) me your favorite design tips! I have a ton more that I could have discussed in this article like responsiveness, whitespace, and alignment, so if you want to see more posts like this, let me know! -->

この記事を気に入って、もっと読みたいと思ったなら、私が気に入った記事と私の最新記事を送る
[ウィークリーニュースレター](https://tinyletter.com/ali_writes_code)があります。
さらに、あなたのデザインのヒントを[ツイートして](https://twitter.com/aspittel)送ってください!
レスポンシブネス、空白、アラインメント等、書きたかったことがまだまだたくさんあるので、
もしこの記事みたいなものをもっと読みたいと思ったなら教えてくださいね!

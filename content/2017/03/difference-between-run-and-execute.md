---
date: 2017-03-22
title: "Run と Execute の違いは何か"
tags:
- english
- translation
image: "2017/03/22/twitter.png"
excerpt: "要約: 2つに意味の違いはほぼない。ただし、executeはより専門用語的なニュアンスがあり、知識のない人にはrunを使う。 いきさつ: 今日も日課のDlang Tourの翻訳をしていた。 いつものようにRunを「実行」と訳し、Executeも「実行」と訳していたところ……"
---

### 要約

2つに意味の違いはほぼない。ただし、executeはより専門用語的なニュアンスがあり、知識のない人にはrunを使う。

### いきさつ

今日も日課の[Dlang Tour](http://tour.dlang.org/)の翻訳をしていた。
いつものようにRunを「実行」と訳し、Executeも「実行」と訳していたところこんな文章に遭遇してしまった。

 > Run & execute `unittest` blocks  
 > -- [Unittesting - Dlang Tour](http://tour.dlang.org/tour/en/gems/unittesting)

これはどうしたものか……普通に訳すなら

`unittest`ブロックを《ここにrunの訳語が入る》して《ここにexecuteの訳語が入る》する

と書くところだが、runもexecuteも「実行」にしていたので困ったことになる。
例文を探してみたところやはり両方共「実行」としているところが多い。
ちなみにGoogle翻訳にかけてみるとこうなる。

![スクショ](/assets/2017/03/22/g-trans.png)

さすがGoogle先生!

### HiNativeで聞いてみる

こういう時はHiNativeでネイティブの人に質問だ!
いやググれよと思われるかもしれないが、
こういう出尽くしてそうな質問も投げられる気軽さがHinativeのいいところだと思う。

[What is the difference between Run and Execute ? - HiNative](https://hinative.com/en-US/questions/2101570)

 > They can be used interchangeably. 
 > 
 > In order to run/execute the program, press the enter key.   
 >  -- iamaseacupcake

 > I don't think there's any meaningful difference. The terms are used interchangeably as far as I know (and I worked at a software company for a few years). 
 > 
 > Wiki confirms:  
 > https://en.wikipedia.org/wiki/Execution_(computing)  
 >  -- jlaw

ネイティブも特に使い分けているわけではなさそうである。

### ググる

以下のようなページが見つかった。

[Difference Between Run and Execute in Technical Documents - Technical Writing Tips](http://www.ihearttechnicalwriting.com/run-execute-technical-documents/)

 > Again, for home users, avoid using execute except to follow the user interface. Use run instead.

 > また、ホームユーザにむけた場合には、ユーザーインターフェースに従うとき以外はexecuteの使用を避けてください。かわりにrunを使いましょう。

 > The exception is when writing technical documents for software developers who seem to prefer to use execute instead of run.

 > runの代わりにexecuteを使うのを好むソフトウェアデベロッパにむけて技術文書を書く場合は例外です。

やはり大きな意味の違いはないが、executeは専門用語的なニュアンスがあり、プログラムの知識のない一般人に向けた文書の場合runを使うということのようだ。

### どう訳すか

さて、細かなニュアンスの違いははっきりしたが、最初の疑問への答えは出ていない。

 > Run & execute `unittest` blocks  
 > -- [Unittesting - Dlang Tour](http://tour.dlang.org/tour/en/gems/unittesting)

ここで、"run / execute"や"run (execute)"という表現を見たことを思い出す。
ひょっとするとここでの & は「〜して〜する」ではなく、単に / と同じような意味、つまり並立の関係を表す記号なのではないか?
あれ?並立ってこういう意味だっけ?まあいいや。

runとexecuteは両方とも「実行」と訳され、日本語には実行と同じ意味で使い分けが難しい言葉もない。
「走らせる」があるかもしれないが、自分の中で走るという表現はスラングであるという印象があり、
[formal style](https://github.com/stonemaster/dlang-tour/blob/master/CONTRIBUTING.md)
を使うことになっているここには出てこないかなと思う。
つまり日本語ではここで & で別の言葉をつなげる必要はなく、したがって

`unittest`ブロックの実行

と訳すことにした。
いやいや違うだろ、と思った人は[今すぐcontribute](https://github.com/dlang-tour/japanese/edit/master/gems/unittesting.md)[^1]だ!

[^1]: 現時点でunittestingのページは存在しないため、ここのリンクも記事執筆時点で機能していない。自分の訳などがマージされた時に現れるページである

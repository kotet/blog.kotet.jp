---
title: "君もDでx86_64向けCコンパイラを書こう"
date: 2018-12-11
tags:
- dlang
- assembly
- tech
- advent-calendar
---

これは、強い人が多すぎてもはやCコンパイラ書いた程度では面白味がない気がしてくる
[D言語 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/dlang)
11日目の記事です。

この記事の対象読者は過去の自分、
つまりコンパイラとかに興味があっていろいろ調べたりはするけどそこで満足してなかなか行動に移せないあなたです。
この記事を通して、
自分は読者であるあなたに**D言語で**Cコンパイラを書いてもらえるように全力で説得していきます。

あなたもD言語を書きましょう。
Cコンパイラを書きましょう。
D言語でCコンパイラを書きましょう。

あなたとD、[今すぐダウンロード](https://dlang.org/download.html)。

### d9cc : A Small C Compiler Written in D

ここ最近9ccのコミットログをたどってCコンパイラを書いていました。

[kotet/d9cc: A Small C Compiler Written in D](https://github.com/kotet/d9cc)

この記事を読んだのが書き始めた理由でした。

[1人でがんばる自作Cコンパイラ](https://www.utam0k.jp/blog/2018/10/12/r9cc/)

前々からコンパイラとか書いてみたいし、アセンブリも読めるようになりたいな、
とは思って定期的に勉強しようとしていましたが、
どうも途中でくじけてしまって毎回同じところをぐるぐるしていました。
そこで上の記事を見て、なるほどそういう勉強法がうまくいくんだなあと思い、
書き始めてみたら結構うまくいきました。

[N-queen](https://ja.wikipedia.org/wiki/%E3%82%A8%E3%82%A4%E3%83%88%E3%83%BB%E3%82%AF%E3%82%A4%E3%83%BC%E3%83%B3)
が動くくらいにはできています。
あと9ccにはないオリジナル機能として、
[抽象構文木](https://ja.wikipedia.org/wiki/%E6%8A%BD%E8%B1%A1%E6%A7%8B%E6%96%87%E6%9C%A8)
を
[Graphviz](https://ja.wikipedia.org/wiki/Graphviz)
のdotファイル形式で出力するオプションがあります。

![](/img/blog/2018/12/ast1.svg)
![](/img/blog/2018/12/ast2.svg)

上：`int main(int argc, char **argv) {int a = (1+2+3)*7; return a;}`のASTを可視化したもの（`-dump-ast1`オプションを渡すと生成される）  
下：上のASTを意味解析したもの（`-dump-ast2`オプションを渡すと生成される）

9ccには浮動小数点数も存在しないのでこれもオリジナル機能として実装してみようかと思ったりもしましたが、
思ってるうちにやる気が減衰してきて実現できていません。

### なぜCコンパイラを書くのか

しかしなぜいまさら[x86_64](https://ja.wikipedia.org/wiki/X64)向けCコンパイラなどというありふれたものを作るのでしょうか？
実はある種の分野の勉強をするのにCコンパイラは最適な題材なのです。

プログラミングの学習を始めたばかりの時、コンパイラは一種魔法のように見えました。
テキストデータであるプログラムの「構造を解析して」、「意味を与え」、「機械語に翻訳」する？！
そんなことが本当に可能なのでしょうか？

かなり前に「コンピュータは論理の世界と現実の世界をどのようにつないでいるのですか？」
といったような質問をYahoo!知恵袋で見たことがあります。
その人にとってコンピュータはまさに魔法であり、異世界と通じあい問いと答えを交換するゲートだったのです。
それと同じことが自分にも、コンパイラにおいて起きていました。

しかし、Cコンパイラを一度書くとコンパイラは魔法ではなくなります。
理解できる技術として身につけることができるのです。

#### 幅広い知識が自然に身につく

Cコンパイラを書くことで様々な知識を身につけることができて、
コンピュータの学習曲線の大きなジャンプを乗り越えることができます。
以下、自分が理解できて特に嬉しかったことを書いていきます。

##### アセンブリ

以前コンパイラを書こうと思った時は、
まず[アセンブリ](https://ja.wikipedia.org/wiki/%E3%82%A2%E3%82%BB%E3%83%B3%E3%83%96%E3%83%AA%E8%A8%80%E8%AA%9E)
を読めるようになろうと思ってアセンブリ手書きから学習をはじめました。
しかしいきなりアセンブリを学ぼうとすると前提知識が大量に必要になり、
Hello Worldの文面を書き換える程度の改造しかできませんでした。

まずアセンブリの基本的な考え方を知らないので、
命令単体のリファレンスを読んでもそれが結局何をしたいのか理解できず、
したがってコードの意図が全くわからないのです。
他の言語と同じノリでいきなりHello Worldから始めてしまったのも敗因かもしれません。

9ccは非常に単純なアセンブリから出発しており、しかも期待される実行結果がテストとして書かれています。
プログラムに書いてあることがそのコードを生成するのに必要なすべてなので、
学習範囲をその中に書いてあることだけに絞ることができます。
また、コンパイラのコードは本質的にアセンブリを書いていく手順を表しているので、
アセンブリのこの行になぜこの命令があるのか、ということを理解する助けになります。

コンパイル対象のC言語が難しくなっていくにつれてアセンブリも長く複雑になっていきますが、
1コミットあたりの変更は少ないのでその場その場で学ばなければいけないことは非常に少なくなります。
実際1コミットあたりで学んだ命令は平均して1個未満という感じだったと思います。

##### パーサー

1つづつコミットを読んでいくといきなり「
[再帰下降構文解析](https://ja.wikipedia.org/wiki/%E5%86%8D%E5%B8%B0%E4%B8%8B%E9%99%8D%E6%A7%8B%E6%96%87%E8%A7%A3%E6%9E%90)
器を作る」というコミットが現れます。
そこそこ行数が多くて苦労しましたが、その時点でのコンパイル対象はカッコもないただの四則演算だったので、
それを処理するパーサーも十分小さく、無事に理解できました。

基本がわかればあとは簡単です。
パーサジェネレータなどという自動化ツールが存在するくらいには同じことの繰り返しなので、
難しそうな構文もパターンにあてはめればスムースに理解できます。

##### 意味解析

パースを行うと構文木ができあがります。
これを書き換えたりすることでさまざまな処理を行います。
意味解析、という言葉は具体的に何をすればいいのかわかりにくいです。
コンパイラについて述べた文章でも意味解析については抽象的な説明が行われることが多く、
なんだか魔法のような印象を受けます。

しかし具体的なコードを読めば何をしているか理解できます。
具体的な内容を理解した上で感想を言うと、
どうも直接関連しないさまざまな処理をおおざっぱにまとめて「意味解析」
と呼んでいることで混乱を呼ぶのではないか、という気がします。

##### 各種ツール

開発に関連したツールにも習熟しました。
gccのオプションも知らないものがたくさんあったし、
そもそもC言語の仕様をここまで詳細に調べたこともありませんでした。
gitの使い方もかなり上手になりました。
何度もコミットを移動するので、効率的な方法を多数身につけました。

gdbの使い方を理解したのはかなり大きいかもしれません。
これまではセグフォが起きると原因になりそうなところを総当りでprintfデバッグして、
結局わからなくて諦めていた記憶があります。

#### 色んな応用の世界が広がる

一度Cコンパイラの具体的実装を理解すると、それを応用してさまざまなものが作れるとわかります。
まず他の言語やISAに対するコンパイラを書くことができます。
今到達している範囲で定数畳み込みはまだ出てきていませんが、
今までのコードからどんなものを書けばいいか大体推測できます。
さらに、式変形を自動で行うタイプのプログラムもだいたい作れそうな気がしてきます。
実際論理式の展開くらいなら１日あればフルスクラッチから書けるようになります。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">移動中にほぼ何も見ずにパーサが書けるようになっている……！ <a href="https://t.co/K1r0lI1WKf">pic.twitter.com/K1r0lI1WKf</a></p>&mdash; Kotet (@kotetttt) <a href="https://twitter.com/kotetttt/status/1064327578469642241?ref_src=twsrc%5Etfw">2018年11月19日</a></blockquote>

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">成長を感じる <a href="https://t.co/Unb8xQ0zWi">pic.twitter.com/Unb8xQ0zWi</a></p>&mdash; Kotet (@kotetttt) <a href="https://twitter.com/kotetttt/status/1064525855047602176?ref_src=twsrc%5Etfw">2018年11月19日</a></blockquote>

あと[malloc動画](https://www.youtube.com/watch?v=0-vWT-t0UHg)
の言ってることが理解できるようになりました。

Cコンパイラを作ったことによって、その知識を応用できるようになり、
作れるものの範囲が一気に広がりました。

### 9ccと「低レイヤを知りたい人のための Cコンパイラ作成入門」の相違点

d9ccを書いている途中で「低レイヤを知りたい人のための Cコンパイラ作成入門」の一部が
[公開されました](https://www.sigbus.info/compilerbook/)が、
9ccはこの本と作成過程が異なるようです。
本ではスタックマシンを作っていましたが、9ccでは最初からレジスタマシンを書き始めています。
スタックにまかせている部分を自分で書くことになるわけですが、そんなに難しいとも思わなかったので、
人によっては自分のように9ccのコミットログをたどる学習法のほうがしっくりくるかもしれません。

### なぜD言語なのか

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">いきなりD言語が飛び出してきてびっくりした<br>低レイヤを知りたい人のための Cコンパイラ作成入門 <a href="https://t.co/NEdfJaCcOp">https://t.co/NEdfJaCcOp</a> <a href="https://t.co/ZKQnIjvAQ1">pic.twitter.com/ZKQnIjvAQ1</a></p>&mdash; Kotet (@kotetttt) <a href="https://twitter.com/kotetttt/status/1058195569632407552?ref_src=twsrc%5Etfw">2018年11月2日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Cコンパイラを書くメリットは上のとおりですが、ではなぜD言語でなければいけないのでしょうか？
一般的には他の言語で書いてもいいし、C言語で書けばセルフホストができます。
しかし自分にはD言語を使う理由があります。

#### コンパイラが書ける

Cコンパイラくらい[brainf*ckですら作れる](http://shinh.skr.jp/elvm/8cc.c.eir.bf)
のでこれはそんなに重要ではないですが、
D言語で書かれたコンパイラがたくさんあります。
まずD言語のコンパイラDMDそのものがD言語で書かれています。

9ccを元にD言語でコンパイラを書いた人が自分以外にいたりもします。

[alphaKAI/d9cc: A tiny C compiler in Dlang](https://github.com/alphaKAI/d9cc)

これはコミットログを順にたどっている自分とは違い、9ccの最新バージョンを直接Dに移植したもののようです。
自分のd9ccは9ccのコードの意味を少しづつ理解しながら手探りで書いたのでだいぶコードが混乱していますが、
こちらのd9ccはビルドツールとしてDUBを使っていたりして、少しすっきりしています。

ともかく、~~言語の知名度の割に~~9ccの移植が複数存在するほどD言語はこの分野に向いているわけです。

#### C言語に近い

D言語は「[C言語風の構文を持つ静的型付け言語](http://www.kmonos.net/alang/d/)」であり、
基本的には高機能なCとして書くことができます。
コピペにならないようにC以外の言語を使いたかったのですが、
一方でC言語から離れすぎると書き直すのが大変になるので、
C言語と似ていながらC++のように完全な互換性があるわけでもないD言語は妥当な選択肢のひとつでした。

#### 書き慣れている

そしてこれが最も大きな理由かもしれません。
自分はD言語を書き慣れていました。
先程話したように自分はコンパイラを作ろうとして何度も挫折してきました。
できればセルフホストとかしてみたいですが、
まず一度スタンダードなものを完成させられないようでは、応用もできません。

なので今回こそは成功させようと、「Cコンパイラを作る」以外のあらゆる点で背伸びをせず、
「まず一度完成させること」を大事にしました。
言語選択においてもそれを考慮した結果、言語特有の問題で詰んだりしないような、
書き慣れているD言語が選ばれました。

D言語は非常に書きやすく、やりたいことを実現するのがとても簡単な言語です。
あなたも「現実的なプログラマのための、 現実的な言語」でコンパイラを書きましょう。

### Cコンパイラを書け

自分はCコンパイラを書いて得た知識で作ってみたいものがいろいろできたので今後はそれを書きます。
言語やISAを変えて別のコンパイラを作ってみるのもいいかもしれません。

Cコンパイラは書くだけで大量の知識が手に入る最強の教材です。
そしてD言語は書くだけで救われる最強の言語です。
したがって全人類はD言語でCコンパイラを書くべきです。

コンパイラの構造などに関してコメントが書かれている9ccに対して、
d9ccはアセンブリなどの周辺知識に関して多くのコメントを残しており、
しかも日本語なので（何かのバグでちょっと壊れてるけど）、
9ccと一緒に読むと9cc単体よりも理解がしやすいと思います。

以下はd9ccのコミットログを整形したものです。
途中調べたサイトなどのリンクが残してあるので、
この記事を読んでコンパイラが作りたくなったら参考にするといいかもしれません。

### 日記（コミットログ）

- commit 63f4f3332a68e65990de7f416608da5580cc7f46  
    Date:   Sun Oct 14 16:53:15 2018 +0900

    Initial commit
    
    コンパイラを作りたいと思っていろいろ頑張ってみていたが、
    少し進んで挫折することを繰り返していた。
    そんななか
    [1人でがんばる自作Cコンパイラ](https://www.utam0k.jp/blog/2018/10/12/r9cc/)
    を読んで「その手があったか！」と思い、自分もやってみることにした。
    
    正直にいうと写経という選択肢が全く頭になかったわけではないが、
    あまり写経経験がなかったことや、せっかくなら真似ではなく、
    理屈を理解してオリジナルで作ってみたかったことなどから除外していた。
    
    しかし行き詰まっているときに上の記事が出たことで、
    ちょっとやってみようという気になった。
    結局自分は先行事例を追いかけることしかできないのかもしれない。

- commit 9835503a5c1d38822b1a94be2c482920b69b07a7  
Date:   Sun Oct 14 17:24:48 2018 +0900

    Compile a single number to a program that exits with the given number.
    
    [- 株式会社エスロジカル - 技術ドキュメント UNIX の C言語：gccのstaticオプション](https://www.slogical.co.jp/tech/unixc_gccstatic.html)  
    [GAS_Intel記法の利用 CapmNetwork](http://capm-network.com/?tag=GAS_Intel%E8%A8%98%E6%B3%95%E3%81%AE%E5%88%A9%E7%94%A8)  
    [Tips　IA32（x86）命令一覧　Mから始まる命令　MOV命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/MOV.html)

    4 files changed, 50 insertions(+)

- commit f8723100d891408df913da5e2b21da93eafaa806    
Date:   Sun Oct 14 17:56:10 2018 +0900

    Add "+" and "-"
    
    [フォーマット指定子一覧](https://www.k-cube.co.jp/wakaba/server/format.html)  
    [strtol](http://www9.plala.or.jp/sgwr-t/lib/strtol.html)

    2 files changed, 39 insertions(+), 2 deletions(-)

- commit 9c58812ae0f4916dae235fcceb01f7672ee8eacf  
Date:   Mon Oct 15 10:25:58 2018 +0900

    Add a tokenizer to allow whitespace between tokens
    
    [D: How to exit from main? - Stack Overflow](https://stackoverflow.com/questions/33054713/d-how-to-exit-from-main)

    2 files changed, 118 insertions(+), 17 deletions(-)

- commit cb583ec6b7d76d85889fa5174f3b437214404c29  
Date:   Mon Oct 15 15:39:36 2018 +0900

    Implement a recursive descendent parser
    
    [再帰下降構文解析 - Wikipedia](https://ja.wikipedia.org/wiki/%E5%86%8D%E5%B8%B0%E4%B8%8B%E9%99%8D%E6%A7%8B%E6%96%87%E8%A7%A3%E6%9E%90)  
    [Java 再帰下降構文解析 超入門](https://qiita.com/7shi/items/64261a67081d49f941e3)  
    [実践的低レベルプログラミング](https://tanakamura.github.io/pllp/docs/)
    
    出てきた値を順番にレジスタに割り当てていき、順番に足し合わせていく。
    8個以上の数値を入力するとレジスタが枯渇する。

    2 files changed, 100 insertions(+), 30 deletions(-)

- commit a3826a9dbd695ff931bc48ce9bccaf072921f884  
Date:   Tue Oct 16 11:20:49 2018 +0900

    Add intermediate representation
    
    中間表現を間に挟むことによってレジスタの使い回しをする

    2 files changed, 165 insertions(+), 27 deletions(-)

- commit e2e19bc7e46261a83e8459a327d5633662fa8e2f  
Date:   Tue Oct 16 11:59:13 2018 +0900

    Split into multiple .d files
    
    [gdbでデバッグするためのgccのデバッグ情報のオプション - C言語入門](http://kaworu.jpn.org/c/gdb%E3%81%A7%E3%83%87%E3%83%90%E3%83%83%E3%82%B0%E3%81%99%E3%82%8B%E3%81%9F%E3%82%81%E3%81%AEgcc%E3%81%AE%E3%83%87%E3%83%90%E3%83%83%E3%82%B0%E6%83%85%E5%A0%B1%E3%81%AE%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3)

    9 files changed, 407 insertions(+), 360 deletions(-)

- commit 9e107a391cd12909bfe37c934ebc16f1bd5a75e2  
Date:   Tue Oct 16 14:28:05 2018 +0900

    Add '*' operator
    
    [Tips　IA32（x86）命令一覧　Mから始まる命令　MUL命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/MUL.html)

    6 files changed, 54 insertions(+), 10 deletions(-)

- commit d579df90eb48ea99e4e084e2a4e3757434e32408  
Date:   Tue Oct 16 14:46:49 2018 +0900

    Add '/' operator
    
    [Tips　IA32（x86）命令一覧　Dから始まる命令　DIV命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/DIV.html)  
    [符号拡張 - Wikipedia](https://ja.wikipedia.org/wiki/%E7%AC%A6%E5%8F%B7%E6%8B%A1%E5%BC%B5)  
    [Assembly Programming on x86-64 Linux (07)](https://www.mztn.org/lxasm64/amd07_mov.html#cwd)

    4 files changed, 14 insertions(+), 1 deletion(-)

- commit b9b60502014477e2a3f99750ed9281cda585be9a  
Date:   Wed Oct 17 12:32:39 2018 +0900

    Add compound statement and return statement

    7 files changed, 148 insertions(+), 62 deletions(-)

- commit 45595f223b1daaa29e6596a1ca46fb66dcd63bdb  
Date:   Wed Oct 17 20:01:33 2018 +0900

    Add variable

    7 files changed, 175 insertions(+), 30 deletions(-)

- commit d39e012e8bff1a60fef6aa39c72ae0e5c889cb00  
Date:   Thu Oct 18 10:01:30 2018 +0900

    Add ADD_IMM IR insn that takes an immediate number
    
    少し先のコミットで専用命令にまとめられてたのでそちらを先取り。

    3 files changed, 9 insertions(+), 11 deletions(-)

- commit f4db422d21a3f1b95360fd33d89abe856ac40153  
Date:   Thu Oct 18 10:45:15 2018 +0900

    Add '()'

    3 files changed, 15 insertions(+), 2 deletions(-)

- commit 022e964611668b375fbd83c15e4da1bee9cd7fe2  
Date:   Thu Oct 18 18:52:06 2018 +0900

    Add 'if'
    
    [Tips　IA32（x86）命令一覧　Cから始まる命令　CMP命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/CMP.html)  
    [x86-レジスタ CapmNetwork](http://capm-network.com/?tag=x86-%E3%83%AC%E3%82%B8%E3%82%B9%E3%82%BF)  
    [x86アセンブリ言語での関数コール](https://vanya.jp.net/os/x86call/)
    
    変数まわりの動きがよくわかっていなかったのだが、
    [x86アセンブリ言語での関数コール](https://vanya.jp.net/os/x86call/)
    を読んで理解することができた。
    紙に書いてみるのも難しかったのでインタラクティブなサンプルは非常にありがたい。

    7 files changed, 195 insertions(+), 62 deletions(-)

- commit 99e801f31896e45b8648c5c252644b381a81f2b5  
Date:   Fri Oct 19 12:51:50 2018 +0900

    Add 'else'

    5 files changed, 29 insertions(+), 3 deletions(-)

- commit 92a0d2141eb36267b830491f95c8a0f146e1a2c1  
Date:   Fri Oct 19 19:20:01 2018 +0900

    Add function call
    
    [C/C++ の呼び出し規約](https://jp.xlsoft.com/documents/intel/compiler/17/cpp_17_win_lin/GUID-011A435D-F8D0-46D7-B973-9B704CA5B54E.html)  
    [Introduction to X86-64 Assembly for Compiler Writers](https://www3.nd.edu/~dthain/courses/cse40243/fall2017/intel-intro.html)  
    [x64 Assembly Language Programming](http://herumi.in.coocan.jp/prog/x64.html#GCC64)  
    [assembly - What registers are preserved through a linux x86-64 function call - Stack Overflow](https://stackoverflow.com/questions/18024672/what-registers-are-preserved-through-a-linux-x86-64-function-call)  
    [呼出規約 - Wikipedia](https://ja.wikipedia.org/wiki/%E5%91%BC%E5%87%BA%E8%A6%8F%E7%B4%84#vectorcall_2)  

    7 files changed, 89 insertions(+), 4 deletions(-)

- commit 96d040ca134ca5a2d9b2768547e5b3f138293a1a
Date:   Sun Oct 21 16:14:23 2018 +0900

    Add zero-arity function definition
    
    [アリティ - Wikipedia](https://ja.wikipedia.org/wiki/%E3%82%A2%E3%83%AA%E3%83%86%E3%82%A3)
    
    Typoで関数呼び出し時の`push`と`pop`が対応してないバグに気づくまでかなり時間がかかった。
    そろそろgdbが使えるようにならないとデバッグが辛いと悟った。
    とりあえず`display /x $<レジスタ名>`して`stepi`しまくれば良いと思う。

    7 files changed, 166 insertions(+), 81 deletions(-)

- commit 2442f90ead1720cba8f3f41f18e1512434304fe2   
Date:   Sun Oct 21 17:27:14 2018 +0900

    Remove IRType.AlLOCA
    
    addには負数が渡せる。
    でもなんでsubを使わずあえてaddを選んだんだろう？

    3 files changed, 39 insertions(+), 44 deletions(-)

- commit ac5c139deba710f116d3820b84613ae273de96d3  
Date:   Sun Oct 21 19:48:08 2018 +0900

    Remove unused variable
    
    やっぱり即値subを使うようだ。

    4 files changed, 51 insertions(+), 5 deletions(-)

- commit 534749b8836370e41517c4ed89633b616e07a872  
Date:   Sun Oct 21 19:54:24 2018 +0900

    Rename codegen.d -> gen_x86.d, ir.d -> gen_ir.d

    4 files changed, 6 insertions(+), 6 deletions(-)

- commit 2391660ec4b6c0d2f8ac3cc33f0a303d16e34887  
Date:   Sun Oct 21 20:00:36 2018 +0900

    Create LICENSE
    
    GitHubで自動生成

   1 file changed, 21 insertions(+)

- commit 804b9a2775f3690ff610093ff206aa500956d626  
Date:   Sun Oct 21 20:10:54 2018 +0900

    Add .travis.yml

    1 file changed, 6 insertions(+)

- commit 1e7b36fc355422bbd80eb9bf6eafd44d223c2d38  
Date:   Mon Oct 22 19:53:07 2018 +0900

    Add "&&" and "||"
    
    [C言語：TRUEとFALSEの値: 愛ゆえにプログラムは美しい](http://endeavour.cocolog-nifty.com/developer_room/2012/05/ctruefalse-8e91.html)  
    [もう一度基礎からC言語 第20回 いろいろな演算子～演算子の優先順位 演算子の優先順位と結合規則](https://www.grapecity.com/developer/support/powernews/column/clang/020/page05.htm)  
    
    ただの論理演算なのにジャンプ命令がいっぱい吐かれて何事かと思った。
    短絡評価をする場合は当然制御構造が必要になる。
    今は完全に無駄でしかないが、右辺が複雑になってくると効いてくるはず。

    4 files changed, 160 insertions(+), 32 deletions(-)

- commit 38805e39bc6b396625fe454fb84950f70fe85aa9  
Date:   Tue Oct 23 13:03:39 2018 +0900

    Create README.md

    1 file changed, 7 insertions(+)

- commit 2d8b704e6e76f36edcac1e4c69639c0d0c33c5db  
Date:   Tue Oct 23 15:58:25 2018 +0900

    Add '<' and '>'
    
    [Tips　IA32（x86）命令一覧　Sから始まる命令　SETcc命令](http://softwaretechnique.jp/OS_Development/Tips/IA32_Instructions/SETcc.html)  
    [Sign extension - Wikipedia](https://en.wikipedia.org/wiki/Sign_extension)  
    [X86アセンブラ/x86アーキテクチャ - Wikibooks](https://ja.wikibooks.org/wiki/X86%E3%82%A2%E3%82%BB%E3%83%B3%E3%83%96%E3%83%A9/x86%E3%82%A2%E3%83%BC%E3%82%AD%E3%83%86%E3%82%AF%E3%83%81%E3%83%A3#EFLAGS%E3%83%AC%E3%82%B8%E3%82%B9%E3%82%BF)  
    [Bit and Byte Instructions (x86 Assembly Language Reference Manual)](https://docs.oracle.com/cd/E19120-01/open.solaris/817-5477/eoizi/index.html)
    
    ここで8ビットのレジスタを扱うことになるとは思わなかった。
    なんでこんな仕様になっているんだろうか。
    なにか都合のいいときがあるのだろうか、それとも単に歴史的経緯的なアレだろうか。

    6 files changed, 100 insertions(+), 14 deletions(-)

- commit 7d30caf9e43238425a10149466f71db50856cda2  
Date:   Tue Oct 23 18:53:52 2018 +0900

    Add "for"
    
    for文は使用頻度の割に複雑すぎると思う。
    そろそろ吐かれるコードを読むのが困難になってきた。
    少し前の時点でフィボナッチ数を計算できるようになってたみたいで、for文そっちのけで喜んでた。
    既に作ってる時点で想定してなかったようなコードがコンパイルできる段階に来ていたようだ。
    いよいよコンパイラとしての力が強くなってきた感じでテンションが上がる。

    4 files changed, 72 insertions(+), 43 deletions(-)

- commit c8179dce9ad2c4744e4295a5bd1fe1a26bd6f36a  
Date:   Wed Oct 24 08:19:26 2018 +0900

    Add compound statement

    3 files changed, 22 insertions(+), 13 deletions(-)

- commit 40c5a15eb5ee5f70e178c660b0f0b9ce6d8cfa43  
Date:   Wed Oct 24 10:16:51 2018 +0900

    Make variable definition explicit
    
    型が出現してついに完全なCのコード、
    つまり普通のCコンパイラがコンパイルしているコードがコンパイルできるようになった。

    4 files changed, 81 insertions(+), 57 deletions(-)

- commit d20a36d5639b476cfdcd04ead473808cd76cf0a2  
Date:   Wed Oct 24 15:18:34 2018 +0900

    Add variable initializer
    
    さまざまな文が書けるようになり、出力されるアセンブリも長くなってきた。
    少しでも読みやすくなるように余分な改行を入れてみたりしたがそれでもつらい。
    そもそも縦に長過ぎて大量にスクロールしなければならないのもつらい。
    出力されたアセンブリを読むことによるデバッグがどんどん難しくなっていく。
    まあだからこそコンパイラが必要とされるわけだが。

    4 files changed, 24 insertions(+), 5 deletions(-)

- commit 1b0b2608d4d6d2aef940c73f963af6a6c85179d0  
Date:   Wed Oct 24 16:24:19 2018 +0900

    Allow declarator in the "for" initializer

    5 files changed, 68 insertions(+), 32 deletions(-)

- commit 05688d31edec387cac90a1adb9f5604e37821f36  
Date:   Wed Oct 24 17:39:30 2018 +0900

    Simplify

    2 files changed, 12 insertions(+), 16 deletions(-)

- commit f15c1f5e105000f9c40467cf1a8566228ba6c618  
Date:   Fri Oct 26 16:55:20 2018 +0900

    Add sema.d
    
    変数のアドレスやスタック領域の大きさを計算する処理をgen_ir.dから分離。
    変なふうにバグらせて最初から書き直したりした。

    5 files changed, 171 insertions(+), 87 deletions(-)

- commit 65c706190d62bbd9dea3c65ce234150cc09f1d61  
Date:   Sat Oct 27 22:30:45 2018 +0900

    Add pointer

    6 files changed, 141 insertions(+), 63 deletions(-)

- commit 0e5fdb12c8015c7676a9cf94690df64dcdce87e0  
Date:   Sun Oct 28 15:12:03 2018 +0900

    Add <pointer> + <number> and <pointer> - <number>

    4 files changed, 79 insertions(+), 8 deletions(-)

- commit 4cfc89551e1e76e7e719c41e9d7fbbf1c03c37f1  
Date:   Thu Nov 1 19:43:55 2018 +0900

    Decay "array of T" to "pointer to T"
    
    [gdbを使ってコアダンプの原因を解析 - それが僕には楽しかったんです。](http://rabbitfoot141.hatenablog.com/entry/2016/11/14/153101)  
    [コアダンプ - ArchWiki](https://wiki.archlinux.jp/index.php/%E3%82%B3%E3%82%A2%E3%83%80%E3%83%B3%E3%83%97)  
    [Programming in D for C Programmers - D Programming Language](https://dlang.org/articles/ctod.html)  
    
    ついに配列らしきものが登場する。
    だんだんポインタ操作がややこしくなってきて、セグフォに何度も遭遇するようになった。
    クラスは常に参照なので、クラスを使えばポインタはとりあえずコード中から消える。
    しかしそれでもやはりセグフォは出るのである。
    一度構造体をすべてクラスに置き換えてみたが、ポインタを書かなくていいこと以外にメリットがなかったので戻した。
    
    ここでコアダンプの読み方を習得した。
    そのおかげで、苦節3日（途中カゼで寝込んだりした）、ようやくこのコミットができる。
    gdbを使いこなせればコアダンプだって普通のエラーと変わらないのだ。
    
    定数畳み込みの具体的実装が自然と頭に湧いてきて感動した。
    今コンパイラ内部で生成されているASTを使えばとても簡単にできてしまう。
    ただ、もうしばらくは9ccのコミットログに沿っていこうと思う。
    
    コンパイラ作成を通して、久しぶりにプログラミングに関する知識が爆発的に増えている。
    これは他人に薦めたくなる。
    みんなCコンパイラを作ろう。

    8 files changed, 170 insertions(+), 65 deletions(-)

- commit 251f8457607abe4ad8d48cba14bb32b7dc8e73a0  
Date:   Fri Nov 2 14:47:00 2018 +0900

    Simplify Enums
    
    [低レイヤを知りたい人のための Cコンパイラ作成入門](https://www.sigbus.info/compilerbook/)
    
    Cコンパイラ本が一部公開された。
    `NUM=256`の意図がようやくわかった。
    しかしasciiの範囲内のトークンにも勝手に名前をつけているので今更真似しても意味がない。

     4 files changed, 47 insertions(+), 27 deletions(-)

- commit 3c53d50cf96a276c21ceb64c07bb624222c2b5d5  
Date:   Fri Nov 2 15:00:16 2018 +0900

    Add "&" (address-of) operator

    4 files changed, 27 insertions(+), 14 deletions(-)

- commit 2a0482fc08d9081a322a3e7165649430c89db7a8  
Date:   Fri Nov 2 15:17:56 2018 +0900

    Do not use struct assignment

    1 file changed, 43 insertions(+), 47 deletions(-)

- commit eed148b8d64f6860d75875c8e1b97073f885f101  
Date:   Fri Nov 2 15:35:53 2018 +0900

    Add "sizeof"

    4 files changed, 24 insertions(+), 2 deletions(-)

- commit 989d001306becde7f29b05f82b77f8e93cfbe896  
Date:   Fri Nov 2 15:41:48 2018 +0900

    Move lvalue check to sema.c

    2 files changed, 4 insertions(+), 2 deletions(-)

- commit e2502b73a8169542d530fa821adf751c70693f6a  
Date:   Fri Nov 2 17:25:46 2018 +0900

    Add "[]" operator

    2 files changed, 56 insertions(+), 24 deletions(-)

- commit d1345402ccd186ca993f35e0a18d7b877add357b  
Date:   Fri Nov 2 18:18:25 2018 +0900

    Simplify
    
    どうもフォーマッターにバグがありそう。
    コメントの漢字が文字化けしている。
    英語で書けばいい問題だが、ただのコピペにしないためにも9ccとは違う言語を使いたい。
    dfmtは以前にも機能追加をしたことがあるので、これもそのうち修正しに行きたい。

    1 file changed, 33 insertions(+), 79 deletions(-)

- commit 1ba782b1b82b7b39290adebf6495522297111c34  
Date:   Sat Nov 3 08:43:51 2018 +0900

    Parallelize test
    
    テストの数が多くなってきたので開発環境の豊富なコアを活用できるようにした。
    めっちゃ速くなってうれしい。
    ただ9ccのコミットログを見る限り数日のうちに不要になりそう。
    しかしだからこそ雑に作っても大丈夫なのである（言い訳）

    1 file changed, 58 insertions(+), 69 deletions(-)

- commit 7fb09d5c50e71f9b8d29f23df09287d5e5fe4972  
Date:   Sat Nov 3 15:10:34 2018 +0900

    Add char type

    7 files changed, 99 insertions(+), 23 deletions(-)

- commit 2fb453cd84f89e89c2e12820bc81d9a8f460b0d3  
Date:   Sun Nov 4 11:36:48 2018 +0900

    Add string literal
    
    [セクションとか.textとか](http://www.ertl.jp/~takayuki/readings/info/no02.html)
    
    hello worldが動いた。
    hello worldが動いた！

    8 files changed, 181 insertions(+), 47 deletions(-)

- commit a75e99629cd991d1ba5f9a1fce5ac4550ef70fd7  
Date:   Sun Nov 4 18:33:34 2018 +0900

    Fix array operator

    2 files changed, 2 insertions(+), 2 deletions(-)

- commit d3836db113bcc92ccb9953a195978ee04585017e  
Date:   Sun Nov 4 18:44:13 2018 +0900

    Add examples/nqueen.c

    1 file changed, 47 insertions(+)

- commit 3b6a32180b473400f8cbdf3e62c2e41c18e0ddf1  
Date:   Tue Nov 6 15:13:01 2018 +0900

    Better handling of string literals
    
    [出力書式のまとめ 変換指定子 - printf出力書式まとめ - 碧色工房](https://www.mm2d.net/main/prog/c/printf_format-01.html)  
    [アセンブラ指令 - 2018年度 システムプログラミング](http://www.swlab.cs.okayama-u.ac.jp/~nom/lect/p3/what-is-directive.html)

    4 files changed, 76 insertions(+), 46 deletions(-)

- commit 312a283cabd8bf422b7236b3a9e132e4034baad6  
Date:   Tue Nov 6 18:00:00 2018 +0900

    Implement block scope

    2 files changed, 66 insertions(+), 33 deletions(-)

- commit 3d0ca942d75ef729be6e5d4a8ff37d3d0d26ccf1  
Date:   Tue Nov 6 18:18:05 2018 +0900

    Simplify

    1 file changed, 28 insertions(+), 40 deletions(-)

- commit 7da653795b536fc919f127e95374c149d4fd8d24  
Date:   Thu Nov 8 13:22:37 2018 +0900

    Add global variable

    7 files changed, 152 insertions(+), 94 deletions(-)

- commit c919586148594089ed167af4667aa2674bb36d35  
Date:   Thu Nov 8 13:26:09 2018 +0900

    Add string escape sequences

    1 file changed, 61 insertions(+), 12 deletions(-)

- commit c438948d2972a1a06a636887cfb813bfe9d53222  
Date:   Fri Nov 9 16:31:30 2018 +0900

    Add "==" and "!="

    6 files changed, 66 insertions(+), 11 deletions(-)

- commit 7547cf07f3f8820e10834acea56de3c2cb0d0633  
Date:   Sun Nov 11 19:34:56 2018 +0900

    Make consume() and expect() ad-hoc polymorphic

    1 file changed, 27 insertions(+), 17 deletions(-)

- commit 7920b0987cab8c6aabe41064815de8032703de07  
Date:   Sun Nov 11 22:22:30 2018 +0900

    Add do ~ while loop
    
    わりと簡単にできた。
    IF中間表現とje命令が現れた。
    if文のときに出てこなかったのにここで出てくるとは……

    6 files changed, 41 insertions(+), 1 deletion(-)

- commit 7a3f22e6c89569545a69459f7025104fd81fa5ce  
Date:   Thu Nov 15 13:19:54 2018 +0900

    Add "extern"
    
    D言語くん Advent Calendar 5日目の記事がだいたい書き終わったので再開。
    どうも自分に複数のプロジェクトを同時進行でするパワーはないらしい。

    5 files changed, 24 insertions(+), 8 deletions(-)

- commit 7f933f641f964fea80849f1af98db699364daea9  
Date:   Thu Nov 15 16:52:38 2018 +0900

    Add expression statement
    
    9ccでグローバル変数になっていた通し番号用変数を引数として渡すようにしていたのだが、
    あまりに煩雑になってきたので元に戻した。
    こういうことをやるならしっかり考えてからでないといけない。

    4 files changed, 93 insertions(+), 48 deletions(-)

- commit c860ad98d08fa2a3a99a8d1b146f6f915de241ff  
Date:   Thu Nov 15 19:28:04 2018 +0900

    Fix escape()

    1 file changed, 4 insertions(+), 2 deletions(-)

- commit 0e4ed87fe3f561a5dbf84de345f0b629a7a74872  
Date:   Thu Nov 15 20:25:07 2018 +0900

    Rewrite tests in shell in C
    
    9ccのコードにはけっこうしょうもない抜けがあったりする。
    プロでもこんなミスをしょっちゅうするのかと思うと気が楽になる。
    d9ccは何も考えずに書き写しているものではないので、
    こちらのほうには抜けは継承されていない。
    しかし、当然ながら、d9ccのほうで生まれた新しい抜けも結構あった。

    6 files changed, 120 insertions(+), 154 deletions(-)

- commit 06d7c1e429fd85e7405ac593661dd680425a3364  
Date:   Sat Nov 17 17:10:10 2018 +0900

    Add while loop
    
    なんかうまいことできそうな気がして9ccのほうを見ずにやってみていた。
    新しいノードを追加しようとしたが、
    9ccのほうを見てみたら単にforループに変換して済ませていてヘコんだ。
    
    でもエラー行の表示はオリジナルだよ！自分すごい！！

    6 files changed, 49 insertions(+), 12 deletions(-)

- commit 85cbf2a88d9cddf43128c3b286b73c2373c2b812  
Date:   Sat Nov 17 17:25:21 2018 +0900

    Allow empty statement
    
    これは見ないで同じコードが書けたぞ！どうだ！やったぜ！

    2 files changed, 6 insertions(+), 1 deletion(-)

- commit d27b79c926132f1e30e8cbd0305a1ee9c9379dec  
Date:   Sat Nov 17 20:17:14 2018 +0900

    Add char literal
    
    このコンパイラはDで書いているので、セルフホストというわかりやすいマイルストーンがない。
    なので、どこで終わりにするかを自分で決めなければならない。
    
    とりあえず手近なマイルストーンとしては、
    しばらくあとにソースをファイルから読み込むように変更するコミットがあるが、
    その後もさまざまな機能追加が続くし、ちょっと手近過ぎる気もする。
    その後になにかキリのいい場所がないかコミットメッセージを読んでみるも、
    9ccのほうもやめどきに到達していないからコミットが続いているのであって、
    やはりやめどきは見つからない。
    
    そこで、D言語 Advent Calendar の締切がくるまでは続けることにした。
    これもまたAC駆動開発……

    2 files changed, 64 insertions(+), 28 deletions(-)

- commit 27bbaf9cd1aaee06f282b5eeb6d3786f6cc63ebe  
Date:   Sat Nov 17 20:54:59 2018 +0900

    Simplify

    1 file changed, 17 insertions(+), 3 deletions(-)

- commit 92bfc100e569aaba57aed4af7166e43ee2bbce39  
Date:   Sat Nov 17 21:24:11 2018 +0900

    Add single-line and block comments

    2 files changed, 57 insertions(+), 24 deletions(-)

- commit d7421265a81324ae85183ab647d4d4bb822cceff  
Date:   Sat Nov 17 21:31:22 2018 +0900

    Rename a variable

    4 files changed, 7 insertions(+), 7 deletions(-)

- commit a0c65cc38bf1b52498384d0fad622ca3c6623a37  
Date:   Sat Nov 17 21:53:36 2018 +0900

    Remove IRType.SUB_IMM and add IRType.BPREL
    
    [X86アセンブラ/データ転送命令 - Wikibooks](https://ja.wikibooks.org/wiki/X86%E3%82%A2%E3%82%BB%E3%83%B3%E3%83%96%E3%83%A9/%E3%83%87%E3%83%BC%E3%82%BF%E8%BB%A2%E9%80%81%E5%91%BD%E4%BB%A4#%E3%82%A2%E3%83%89%E3%83%AC%E3%82%B9%E8%A8%88%E7%AE%97%E5%91%BD%E4%BB%A4)  
    [lealについて - suu-g's diary](http://suu-g.hateblo.jp/entry/20080505/1210012224)
    
    srcオペランドでめっちゃ計算できる。
    アセンブリを手書きする時は便利そう。
    速度面でも1命令で済ませたほうが良かったりするんだろうか。
    これがCISCというやつか……

    2 files changed, 7 insertions(+), 9 deletions(-)

- commit 5dab8368858cdea8d657bf8289d6cacd8cdac7b8  
Date:   Sun Nov 18 00:08:39 2018 +0900

    Align stack data members
    
    [アライメントを考慮したサイズの取得](https://tepp91.github.io/contents/cpp/adjust-alignment.html)  
    [Blog Alpha Networking: ビット(bit)演算操作の覚え書き](https://alpha-netzilla.blogspot.com/2013/01/bit.html)  
    [x86-64 モードのプログラミングではスタックのアライメントに気を付けよう \- uchan note](http://uchan.hateblo.jp/entry/2018/02/16/232029)

    3 files changed, 29 insertions(+), 2 deletions(-)

- commit 255a4d30b11dc45b70fd8d9c34ef360193336995  
Date:   Thu Nov 22 13:13:32 2018 +0900

    Add _Alignof

    4 files changed, 25 insertions(+), 4 deletions(-)

- commit 8a867d08f1af0cd4acab7fe8f6aca4609725c93b  
Date:   Thu Nov 22 13:23:07 2018 +0900

    Split gen_ir.d into gen_ir.d and irdump.d

    5 files changed, 110 insertions(+), 103 deletions(-)

- commit 5201f1c8870d09cd8a96e91b2b4bbbda5e26b97d  
Date:   Thu Nov 22 13:38:19 2018 +0900

    Simplify

    1 file changed, 30 insertions(+), 48 deletions(-)

- commit da0846a4dd600b19a385077a2f96c10b092a1463  
Date:   Thu Nov 22 13:48:24 2018 +0900

    Simplify

    1 file changed, 9 insertions(+), 9 deletions(-)

- commit 7b6675a71ea8dc8a2141b165eb59737e283ba0fc  
Date:   Thu Nov 22 14:00:22 2018 +0900

    Take filename instead of code string as a command line argument
    
    ファイル名を受け取って文字列として変数に入れるだけの処理。
    さすがにD言語だとコード量が少なくて済む。

    2 files changed, 9 insertions(+), 6 deletions(-)

- commit 7680199f5b51b292d22dc64b8dd7269341ee4b6d  
Date:   Thu Nov 22 15:39:01 2018 +0900

    Fix: Use isWhite() instead of isSpace()

    1 file changed, 3 insertions(+), 3 deletions(-)

- commit c48fa192e8f86fc493fe8cdabdeb43eed839347e  
Date:   Sat Nov 24 14:18:31 2018 +0900

    Add -dump-ast options
    
    ASTをgraphvizのdot形式で出力するオリジナル機能。
    いまさらデバッグ目的で使うことはないが、
    やっぱり何が起こっているか見てわかるとおもしろい。

    3 files changed, 451 insertions(+), 10 deletions(-)

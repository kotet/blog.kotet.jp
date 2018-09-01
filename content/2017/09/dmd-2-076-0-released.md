---
date: 2017-09-03
aliases:
- /2017/09/03/dmd-2-076-0-released.html
title: "DMD 2.076.0 Released【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "コアDチームがプログラミング言語Dのリファレンスコンパイラ、DMDのバージョン2.076.0を公開し、 ダウンロードできるようになりました。 このリリースの大きな特徴は2つあり、ジェネレーティブプログラミングとジェネリックプログラミングのためのstatic foreach機能と、 Cプロジェクトを徐々にDに切り替えていくことを簡単かつ有用にする、非常に強化されたC言語統合です。"
---

この記事は、

[DMD 2.076.0 Released – The D Blog](https://dlang.org/blog/2017/09/01/dmd-2-076-0-released/)

を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---

コアDチームがプログラミング言語Dのリファレンスコンパイラ、DMDのバージョン2.076.0を公開し、
[ダウンロードできるようになりました](https://dlang.org/changelog/2.076.0.html)。
このリリースの大きな特徴は2つあり、ジェネレーティブプログラミングとジェネリックプログラミングのための`static foreach`機能と、
Cプロジェクトを徐々にDに切り替えていくことを簡単かつ有用にする、非常に強化されたC言語統合です。

### static foreach

ジェネリックプログラミングとジェネレーティブプログラミングのサポートの一環として、Dでは`version`や`static if`文のような構文による条件コンパイルができます。
これらは異なるコードパスをコンパイル時に選択したり、文字列mixinやテンプレートmixinと組み合わせてコードブロックを生成するために使用されます。
これらの機能による可能性は発見され続けていますが、コンパイル時ループ構築の欠如は常に不便をもたらしていました。

こちらのサンプルで、`val0`から`valN`と名付けられる定数群は設定ファイルで指定された数値`N+1`を元に生成されなければなりません。
実際の設定ファイルではパース用の関数が必要ですが、この例では`val.cfg`ファイルは`10`などの単一の数値のみを含み、他に何も書かれていないと仮定します。
さらに、`val.cfg`はコマンドライン`dmd -J. valgen.d`を使ってコンパイルされるソースファイル`valgen.d`と同じディレクトリにあるものとします。

```d
module valgen;
import std.conv : to;

enum valMax = to!uint(import("val.cfg"));

string genVals() 
{
    string ret;
    foreach(i; 0 .. valMax) 
    {
        ret ~= "enum val" ~ to!string(i) ~ "=" ~ to!string(i) ~ ";";
    }
    return ret;
}

string genWrites() 
{
    string ret;
    foreach(i; 0 .. valMax) 
    {
        ret ~= "writeln(val" ~ to!string(i) ~ ");";
    }
    return ret;
}

mixin(genVals);

void main() 
{
    import std.stdio : writeln;
    mixin(genWrites);
}
```

記号定数`valMax`は、コンパイル時にファイルを読み、文字列リテラルとして扱われる
[`import`式](https://dlang.org/spec/expression.html#import_expressions)によって初期化されます。
ファイル内の単一の数字のみを扱うので、文字列を直接`std.conv.to`関数テンプレートに渡して`uint`に変換することができます。
`valMax`が`enum`のため、`to`の呼び出しはコンパイル時に発生する必要があります。
最後に、コンパイル時関数評価(CTFE)の[条件を満たす](https://dlang.org/spec/function.html#interpretation)ため、
コンパイラはその呼び出しをインタプリタに渡します。

`genVals`関数は定数`val0`から`valN`までの宣言を生成するために存在し、`N`は`valMax`の値で決まります。
26行目の文字列mixinが`genVals`のコンパイル時呼び出しの発生を強制するため、この関数はコンパイル時インタプリタによっても評価されます。
関数内のループが各定数の宣言を含む単一の文字列を構築し、複数の定数宣言としてmixinするために返します。

同じく、`genWrites`関数には`genVals`で生成した各定数で`writeln`を呼び出すという単一の目的があります。
また、コードは単一の文字列として構築され、`main`関数内の文字列mixinは、
返値がmixinしコンパイルできるように`genWrites`のコンパイル時の実行を強制します。

このような単純な例でさえも宣言や関数呼び出しの生成のための関数が2つもできてしまうというのは可読性に問題があります。
コード生成は非常に複雑になり、コンパイル時にのみ実行される関数の作成は複雑さを増大させます。
Dのコンパイル時構築を使う誰にとっても反復が必要となるのは珍しいことではなく、
コンパイル時ループを提供するためだけに存在する関数もまた珍しいことではなくなりました。
このようなボイラープレート(訳注： 言語仕様上省く事ができない定型的なコード[^1])をなくしたいという欲求は、
`static if`の仲間のようなものである`static foreach`のアイデアの優先順位を高くしました。

[^1]: [https://terasolunaorg.github.io/guideline/5.0.1.RELEASE/ja/Appendix/Lombok.html](https://terasolunaorg.github.io/guideline/5.0.1.RELEASE/ja/Appendix/Lombok.html)

[DConf 2017](http://dconf.org/2017/index.html)で、Timon Gehrはハッカソンに真剣に取り組み、
コンパイラに`static foreach`のサポートを追加する[プルリクエスト](https://github.com/dlang/dmd/pull/6760)を実装しました。
彼は[DIP 1010](https://github.com/dlang/DIPs/blob/master/DIPs/DIP1010.md)を実現するためにそれを踏襲し、
DIP 1010は言語の作者から熱心な賛成を受けました。
DMD 2.076で、[ついにすべての準備が整った](https://dlang.org/changelog/2.076.0.html#staticforeach)というわけです。

この新機能によって、上記の例は以下のように書き換えられます:

```d
module valgen2;
import std.conv : to;

enum valMax = to!uint(import("val.cfg"));

static foreach(i; 0 .. valMax) 
{
    mixin("enum val" ~ to!string(i) ~ "=" ~ to!string(i) ~ ";");
}

void main() 
{
    import std.stdio : writeln;
    static foreach(i; 0 .. valMax) 
    {
        mixin("writeln(val" ~ to!string(i) ~ ");");
    }
}
```

このような単純な例でもわかりやすく可読性の向上があります。
このコンパイラのリリースをきっかけにコンパイル時に重いDライブラリ(そのほとんどではないでしょうか?)に大きなアップデートがあっても驚かないでください。
 
### Cとの統合と相互運用性の改善

DMDの`-betterC`コマンドラインスイッチは、かなり前から存在はしていましたが、
実際には役に立たなかったし、より緊急の事項への対処のため放置されてきました。
DMD 2.076で、それが動き始めました。
 
一つのプログラムのうちでDとCの両方を組み合わせる、特に作業中のプロジェクトにおいてCのコードとDのコードを徐々に置き換えるのを簡単にする、
というのがこの機能の背景にある考えです。
Dは初めからCのABIと互換性があり、CのヘッダをDのモジュールに変換するいくらかの作業によって、あらゆる仲介なしに直接CのAPIを呼べるようにできます。
逆にDをCのプログラムに組み込むことも可能でしたが、それはスムースなプロセスではありませんでした。

おそらく最大の問題はDRuntimeでした。
Dの一定の言語機能はDRuntimeの存在に依存しており、
したがってCの中で使われることを意図したDコードはランタイムを持ってきてそれが初期化されていることを確認する必要があります。
ランタイムとランタイムへのすべての参照はCとリンクする前に切り捨てる必要があり、
それはコードを書く時とコンパイルするときの両方で少なくない努力を要します。

`-betterC`はDのライブラリをCの世界に持ち込み、
Cのプロジェクトを一部または全部Dに置き換えることによってモダナイズするのに必要な努力を劇的に減らすことを目的としたものです。
DMD 2.076ではその目的に向かっての重要な進捗がありました。
`-betterC`がコマンドラインで指定されたとき、Dのモジュール内のすべてのアセットはDのアセットハンドラではなくCのアセットハンドラを使うようになります。
さらに重要なのは、Dの標準ライブラリであるDRuntimeとPhobos、そのどちらも通常通り自動的にリンクされることがないということです。
つまり、もはや`-betterC`を使うとき手動でビルドプロセスを設定したりバイナリを修正する必要はないということです。
Dのモジュールから生成されたオブジェクトファイルやライブラリは特別な努力なしに直接Cとリンクできるようになりました。
これはVisual StudioのDプラグインである[VisualD](http://rainers.github.io/visuald/visuald/StartPage.html)を使う場合特に簡単です。
以前からVisualDはCとDのモジュールの同じプロジェクト内でのミックスをサポートしています。
アップデートされた`-betterC`スイッチはこの機能をより便利なものにします。

### 新しいリリーススケジュール

これはコンパイラや言語の機能ではありませんが、注目に値するものです。
今回は新しいリリーススケジュールに準拠した最初のリリースです。
これからはベータリリースは2017–10–15、2017–12–15、2018–2–15などのように、毎月15日にアナウンスされます。
これによってリリーススケジュールにいくらか信頼性と予測可能性がもたらされ、拡張、変更、新機能のマイルストーンの計画が簡単になります。

### 今すぐ入手しましょう!

いつものように、このリリースの変更点、修正点、および拡張点は、[チェンジログ](https://dlang.org/changelog/2.076.0.html)に記載されています。
このリリースは常に[http://downloads.dlang.org/releases/2.x/2.076.0](http://downloads.dlang.org/releases/2.x/2.076.0)からダウンロードでき、
最新のリリースとベータ、ナイトリーはD言語のウェブサイトの[ダウンロードページ](https://dlang.org/download.html)にあります。

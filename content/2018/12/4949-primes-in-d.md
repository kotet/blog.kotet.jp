---
title: "シクシク素数列 D言語編"
date: 2018-12-15
tags:
- dlang
- tech
- advent_calendar
---

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">シクシク素数列 Advent Calendar 2018 <a href="https://twitter.com/hashtag/Qiita?src=hash&amp;ref_src=twsrc%5Etfw">#Qiita</a> <a href="https://t.co/sgiUB4S5dE">https://t.co/sgiUB4S5dE</a><br><br>言語がかぶらないように同一ルールで実装するだけのAdC。まだ空き枠があるのでぜひ。今ならPHP、Perl、D言語、Haskellなどで参加できますよ！</p>&mdash; 堀田ヒロアキ (@h6akh) <a href="https://twitter.com/h6akh/status/1071085808407339009?ref_src=twsrc%5Etfw">December 7, 2018</a></blockquote>

D言語と聞いて駆けつけてきました。この記事は
[シクシク素数列 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/4949prime-series)
15日目の記事です。
これはD言語くんです。

![](/img/blog/2018/12/dman.png)

### シクシク素数列

以下がルールになります。

> - 数値に4か9を含む素数をシクシク素数と呼ぶことにします
>   - 19とか41とか149とか。
> - 標準入力として正の整数 N を与えたら N 番目までのシクシク素数を半角カンマ区切りで標準出力してください
>   - 例 N = 9 の場合、 `19,29,41,43,47,59,79,89,97`
> - N は最大で 100 とします

### 無限レンジを使って書く

というわけでD言語を使ってシクシク素数を生成していきましょう。
D言語ではレンジ（Range）というアイデアがよく使われており、
特定の機能を持っている型を統一的な方法で扱えるようにしています。

[D言語で今始めるRange - Qiita](https://qiita.com/umarider/items/e0936c6afdcdf4522cc7)

まず自然数の無限レンジを生成して、その中から4と9が含まれるものを選び、
その上で素数判定をすることでシクシク素数の無限レンジが作れます。
その結果を`N`個取り出して文字列化し、コンマでつなげて出力すれば完了です。

この一連の処理は関数のチェインをすることにより1行で書けますが、
普通に書くとカッコが増えて非常に読みづらくなってしまいます。
そこで登場するのがUFCS、Unified Function Call Syntaxです。
D言語では関数の第一引数を外に出し、
第一引数のメンバ関数やプロパティを呼び出しているかのような見た目にできます。

例えば、`f(a, b)`のような関数呼び出しは`a.f(b)`というように書けるのです。
これを使うことで`f(g(h(a, b)),c)`のような読みづらいコードが以下のように変形できます。

```d
f(g(h(a, b)),c)
// fにUFCSを適用
g(h(a, b)).f(c)
// gにUFCSを適用
h(a, b).g().f(c)
// hにUFCSを適用
a.h(b).g().f(c)
// 第二引数がないならカッコも省略できる。ただしここまでやるかは状況による
a.h(b).g.f(c)
```

カッコの対応関係を頭のなかで解析しなくてもいいという利点がありますが、それだけではありません。
`a`に`h`を適用した結果にさらに`g`を適用して、
さらにその結果に`f`を適用する……と日本語で言ったときと同じ順番で関数が出現するので、
処理の流れを理解しやすくなります。
また、間に処理を挟んだり、逆に間の処理を除いたりするのも簡単になります。

```d
f(g(h(a, b)), c) // このコードからgをなくしてみる
f(h(a, b), c) // 開きカッコと閉じカッコが離れているので対応を気をつけて削除する

a.h(b).g.f(c) // UFCSの形
a.h(b).f(c) // 削除する場所は1箇所だけになる

a.h(b).G(d, e).f(c) // 途中に3引数の関数Gを入れてみる
f(G(h(a, b), d, e), c) // 通常の形。ちょっと読む時身構えたくなる
```

というわけで以下がシクシク素数列を生成するコードです。

```d
#!/usr/bin/rdmd

// 自然数を返す無限レンジ。
// map等の関数を使うためにはinputrangeである必要があり、
// inputrangeの条件を満たすためには
// front,popFront,emptyという3つの関数を実装する必要がある(ダックタイピング)
struct NaturalNumber
{
    long n = 1;

    // 先頭の要素を返す
    @property long front()
    {
        return n;
    }

    // 先頭の要素を取り除く
    void popFront()
    {
        n++;
    }

    // 空であるか返す。無限レンジなので常にfalse
    bool empty()
    {
        return false;
    }
}

bool isPrime(long n)
{
    // iには2からn-1までの整数が入る
    foreach (i; 2 .. n)
    {
        if (n % i == 0)
        {
            return false;
        }
    }
    return true;
}

bool is4949Prime(long n)
{
    long tmp = n;
    do
    {
        if (tmp % 10 == 4 || tmp % 10 == 9)
        {
            return isPrime(n);
        }
        tmp /= 10;
    }
    while (0 < tmp);
    return false;
}

void main()
{
    // 局所的 & 選択的インポート
    import std.conv : to, text;
    import std.array : join;
    import std.range : take;
    import std.stdio : readln, writeln;
    import std.string : chomp;
    import std.algorithm : filter, map;

    long n = readln().chomp().to!long();
    assert(1 <= n);

    // 下のコードは
    // writeln(join(map!(text)(take(filter!(is4949Prime)(NaturalNumber();), n)), ','));
    // と等価。
    NaturalNumber()
        .filter!is4949Prime
        .take(n)
        .map!text
        .join(',')
        .writeln();
}
```

ファイル行頭にshebangがついているので以下のように実行できます。
`rdmd`は必要に応じてファイルをコンパイルしてから実行してくれるコマンドです。
そもそもコンパイル時間が短いのであまり気になりませんが、
コードに変化がなければ前回のコンパイル結果を使ってくれるのでちょっと速くなります。

```console
$ echo 100 | ./skskprime1.d 
19,29,41,43,47,59,79,89,97,109,139,149,179,191,193,197,199,229,239,241,269,293,347,349,359,379,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,509,541,547,569,593,599,619,641,643,647,659,691,709,719,739,743,769,797,809,829,839,859,907,911,919,929,937,941,947,953,967,971,977,983,991,997,1009,1019,1039,1049,1069,1091,1093,1097,1109,1129,1193,1229,1249,1259,1279,1289,1291,1297,1319
$ echo 9 | ./skskprime1.d 
19,29,41,43,47,59,79,89,97
```

### すべてをコンパイル時に済ませる

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">何でもコンパイル時に計算してくれる D 言語クン <a href="https://t.co/vhNcym1AvM">pic.twitter.com/vhNcym1AvM</a></p>&mdash; No Coke, No Code. (@Iselix) <a href="https://twitter.com/Iselix/status/976355849953206272?ref_src=twsrc%5Etfw">2018年3月21日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

ルールでNは1以上100以下の整数になると決まっています。
長さ100程度のシクシク素数列なら、
実行時に計算しなくても定数として実行ファイルに埋め込んでしまって良さそうです。

さらに、出力結果は必ずN=100の結果の文字列("19,29,...,1319")の部分文字列になります。
ということは、N=100の結果のどの部分を出力すればいいかをルックアップテーブルに持っておけば、
コンマでつなぐ等の処理も実行時に行わなくて済むわけです。

部分文字列を生成する`[0 .. n]`のようなコードはスライス演算です。
D言語における動的配列はスライスとも呼ばれ、
これは始点のポインタと要素数がセットになったデータ構造のようなものです。
ここで配列`str`のコピーは発生しておらず、
`str1`、`str2`は単に`str`の一部分に対する参照です。

[D Slices - D Programming Language](https://dlang.org/articles/d-array-article.html)  
[D言語のスライス機能 - プログラミング言語 D (日本語訳)](http://www.kmonos.net/alang/d/d-array-article.html)

```d
string str = "abcdefg"; // 実はこれもスライス
string str1 = str[0 .. 3]; // strの最初の3要素のスライス
string str2 = str[3 .. 7]; // strの4文字目からの4要素のスライス 

assert(str1 == "abc");
assert(str2 == "defg");
```

コンパイル時に文字列を1つ生成すれば、実行時の処理を入力読み込みとスライスの計算だけにできます。
この文字列定数をどのように生成しましょう。
先程の実行結果をコード中に手動で埋め込みますか？

D言語には強力なCTFE（コンパイル時関数実行）機能があります。
コードをほとんど変更せずに結果をコンパイル時定数にしてみましょう。

```d
// NaturalNumber, isPrime, is4949Primeはさっきと同じため省略。
// 今回この3つとcreateLookupTableは実行時に使われず、コンパイル時に実行される

size_t[] createLookupTable(string str)
{
    size_t[] result;
    foreach (i, c; str)
    {
        if (c == ',')
        {
            // ~は配列に対する追加演算子。
            // str[0..x]はstrの最初からstr[x-1]までを表すので、
            // コンマのインデックスを使うとそのコンマの手前までが表示できる
            result ~= i;
        }
    }
    // コンマは 100 - 1 == 99 個あるので、
    // ここまででresultには N == 99 までの結果のインデックスが入っている。
    // N == 100 の時は文字列全体を表示する
    result ~= str.length;
    return result;
}

void main()
{
    import std.stdio : readln, writeln;
    import std.string : chomp;
    import std.conv : to, text;
    import std.algorithm : filter, map;
    import std.range : take, array;
    import std.array : join;

    long n = readln.chomp.to!long;
    assert(1 <= n);
    assert(n <= 100);

    // enumはコンパイル時定数。数値リテラル100と同じような扱いを受ける
    enum N = 100;
    
    // この変数は値が実行ファイルに埋め込まれる。
    // したがってその値の計算はコンパイル時に行われる
    static immutable string str = NaturalNumber()
        .filter!is4949Prime
        .take(N)
        .map!text
        .join(',');
    static immutable size_t[] lookuptable = createLookupTable(str);

    // コンパイル時のassert
    static assert(lookuptable.length == N);

    // 実行時には配列を見るだけ
    writeln(str[0 .. lookuptable[n - 1]]);
}
```

上のコードをコンパイルして実行すると最初のそれと同じ結果になります。
念の為本当にコンパイル時計算が行われているのか確認しておきましょう。

`dmd -vcg-ast`コマンドでコンパイラに処理されたあとのASTをコード風に変換したものを見ることができます。
上のコードは処理の結果、以下のように変換されます。

```d
// 前略
void main()
{
	import std.stdio : readln, writeln;
	import std.string : chomp;
	import std.conv : to, text;
	import std.algorithm : filter, map;
	import std.range : take, array;
	import std.array : join;
	long n = to(chomp(readln('\x0a')));
	assert(1L <= n);
	assert(n <= 100L);
	enum int N = 100;
	static immutable immutable(string) str = ['1', '9', ',', '2', '9', ',', '4', '1', ',', '4', '3', ',', '4', '7', ',', '5', '9', ',', '7', '9', ',', '8', '9', ',', '9', '7', ',', '1', '0', '9', ',', '1', '3', '9', ',', '1', '4', '9', ',', '1', '7', '9', ',', '1', '9', '1', ',', '1', '9', '3', ',', '1', '9', '7', ',', '1', '9', '9', ',', '2', '2', '9', ',', '2', '3', '9', ',', '2', '4', '1', ',', '2', '6', '9', ',', '2', '9', '3', ',', '3', '4', '7', ',', '3', '4', '9', ',', '3', '5', '9', ',', '3', '7', '9', ',', '3', '8', '9', ',', '3', '9', '7', ',', '4', '0', '1', ',', '4', '0', '9', ',', '4', '1', '9', ',', '4', '2', '1', ',', '4', '3', '1', ',', '4', '3', '3', ',', '4', '3', '9', ',', '4', '4', '3', ',', '4', '4', '9', ',', '4', '5', '7', ',', '4', '6', '1', ',', '4', '6', '3', ',', '4', '6', '7', ',', '4', '7', '9', ',', '4', '8', '7', ',', '4', '9', '1', ',', '4', '9', '9', ',', '5', '0', '9', ',', '5', '4', '1', ',', '5', '4', '7', ',', '5', '6', '9', ',', '5', '9', '3', ',', '5', '9', '9', ',', '6', '1', '9', ',', '6', '4', '1', ',', '6', '4', '3', ',', '6', '4', '7', ',', '6', '5', '9', ',', '6', '9', '1', ',', '7', '0', '9', ',', '7', '1', '9', ',', '7', '3', '9', ',', '7', '4', '3', ',', '7', '6', '9', ',', '7', '9', '7', ',', '8', '0', '9', ',', '8', '2', '9', ',', '8', '3', '9', ',', '8', '5', '9', ',', '9', '0', '7', ',', '9', '1', '1', ',', '9', '1', '9', ',', '9', '2', '9', ',', '9', '3', '7', ',', '9', '4', '1', ',', '9', '4', '7', ',', '9', '5', '3', ',', '9', '6', '7', ',', '9', '7', '1', ',', '9', '7', '7', ',', '9', '8', '3', ',', '9', '9', '1', ',', '9', '9', '7', ',', '1', '0', '0', '9', ',', '1', '0', '1', '9', ',', '1', '0', '3', '9', ',', '1', '0', '4', '9', ',', '1', '0', '6', '9', ',', '1', '0', '9', '1', ',', '1', '0', '9', '3', ',', '1', '0', '9', '7', ',', '1', '1', '0', '9', ',', '1', '1', '2', '9', ',', '1', '1', '9', '3', ',', '1', '2', '2', '9', ',', '1', '2', '4', '9', ',', '1', '2', '5', '9', ',', '1', '2', '7', '9', ',', '1', '2', '8', '9', ',', '1', '2', '9', '1', ',', '1', '2', '9', '7', ',', '1', '3', '1', '9'];
	static immutable immutable(ulong[]) lookuptable = [2LU, 5LU, 8LU, 11LU, 14LU, 17LU, 20LU, 23LU, 26LU, 30LU, 34LU, 38LU, 42LU, 46LU, 50LU, 54LU, 58LU, 62LU, 66LU, 70LU, 74LU, 78LU, 82LU, 86LU, 90LU, 94LU, 98LU, 102LU, 106LU, 110LU, 114LU, 118LU, 122LU, 126LU, 130LU, 134LU, 138LU, 142LU, 146LU, 150LU, 154LU, 158LU, 162LU, 166LU, 170LU, 174LU, 178LU, 182LU, 186LU, 190LU, 194LU, 198LU, 202LU, 206LU, 210LU, 214LU, 218LU, 222LU, 226LU, 230LU, 234LU, 238LU, 242LU, 246LU, 250LU, 254LU, 258LU, 262LU, 266LU, 270LU, 274LU, 278LU, 282LU, 286LU, 290LU, 294LU, 298LU, 302LU, 306LU, 310LU, 314LU, 319LU, 324LU, 329LU, 334LU, 339LU, 344LU, 349LU, 354LU, 359LU, 364LU, 369LU, 374LU, 379LU, 384LU, 389LU, 394LU, 399LU, 404LU, 409LU];
	writeln(str[0..lookuptable[cast(ulong)(n - 1L)]]);
	return 0;
}
// 後略
```

少し修正を加えればこのmain関数単体でコンパイルが可能です。
`str`と`lookuptable`がただの定数になっていることがわかります。

すばらしいですね。

- [Online D Editor](https://run.dlang.io/)
- [Downloads - D Programming Language](https://dlang.org/download.html)
- [D言語環境構築 2018年版 - Qiita](https://qiita.com/outlandkarasu@github/items/84cc41c37d6c82f75f62)

---
title: "入門MOVプログラミング 本当にMOVはチューリング完全なのか"
date: 2019-04-18
tags:
- assembly
- tech
---

<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/x86asm.min.js"></script>

### TL;DR

チューリング完全じゃないかもしれない

作ったもの：[kotet/mov-programming: MOV is Turing-Complete](https://github.com/kotet/mov-programming)

### はじめに

かなり前にx86の`mov`命令はチューリング完全であるという記事を読みました。
その当時はアセンブリ（と英語）が読めなかったため、仕組みはわからないけどすごいなあと読み流していました。

ふとその話を思い出したので、今回は元となった論文[^1]を読んで実際に簡単な計算をしてみようと思います。

[^1]: [Stephen Dolan. MOV is Turing-complete. Computer Laboratory, University of Cambridge, 2013.](http://stedolan.net/research/mov.pdf)

### 同値比較

`mov`命令は指定した場所へデータをコピーする命令です。
コピーするデータやコピー先は様々な方法で指定できます。

x86_64の`mov`命令はかなり自由度が高く、組み合わせることで計算が行えてしまいます。

まず`mov`で同値比較を行います。
Cで同じようなことをすると以下のようになります。

```c
int equal(char a, char b)
{
    char buf[256];
    buf[a] = 0;
    buf[b] = 1;
    return buf[a];
}
```

`a`と`b`が同じ値なら`buf[a] = 0;`で入れた`0`は`buf[b] = 1;`で上書きされます。
最終的にこれは`a`と`b`が同じなら`1`を、異なるなら`0`を返します。

これをアセンブリで書きます。
`mov`命令は書き込み先にメモリを指定できます。
ごく単純に書くと以下のようになります。
レジスタ`a`が指すメモリ領域に結果が入っています。

```x86asm
mov [a] 0
mov [b] 1
```

しかし`a`や`b`に入っている値(`0`~`255`)は操作が許可されていないアドレスのことが多いので、
このままでは実際に動かせるプログラムにはなりません。

しかしx86の`mov`命令はある程度の計算ができます。
アドレスを指定するとき、`ベースレジスタ + インデックスレジスタ * 定数 + 定数`といった形でアドレスを計算して指定することができます。

これをCから呼び出せるちゃんとしたアセンブリにするとこんな感じになります。
最初と最後にCと接続して使うためのコードがあるのを除けば`mov`だけで書かれています。

```x86asm
.intel_syntax noprefix
.global equal
equal:
    push rbp
    mov rbp, rsp
    sub rsp, 256

    mov BYTE PTR [rbp + rdi - 256], 0
    mov BYTE PTR [rbp + rsi - 256], 1

    mov al, BYTE PTR [rbp + rdi - 256]
    movzb rax, al

    mov rsp, rbp
    pop rbp
    ret
```

第一引数の値は`rdi`に、第二引数の値は`rsi`に入っています。

```c
#include <stdio.h>
int equal(char a, char b);

int main(void)
{
    printf("equal(2,3) = %d\n", equal(2,3));
    printf("equal(3,3) = %d\n", equal(3,3));
}
```

```console
$ gcc -static -o movprog main.c equal.s
$ ./movprog
equal(2,3) = 0
equal(3,3) = 1
```

これは入力に`0`か`1`しか渡さないようにすれば[xnor](https://ja.wikipedia.org/wiki/%E5%90%8C%E5%80%A4)です。

### 三項演算子

この後出てくる論理積や条件分岐では[三項演算子](https://ja.wikipedia.org/wiki/%E6%9D%A1%E4%BB%B6%E6%BC%94%E7%AE%97%E5%AD%90)的処理を行っています。
Cで書いてみます。

```c
// (b) ? x : y;
int ternary(int b, char x, char y)
{
    char buf[2];
    buf[0] = y;
    buf[1] = x;
    return buf[b];
}
```

`0`または`1`である`b`の値をインデックスにして`x`と`y`の値を選びます。
アセンブリで単純化して書くと以下のようになります。

```x86asm
mov [buf + 0], y
mov [buf + 1], x
mov rax, [buf + b]
```

これを使って`0`、`1`や定数を超えて自由に数値を入れることができるようになります。

### 論理積

上のテクニックを使うと論理積も`mov`だけで実現できます。
Cで書くとこのようになります。

```c
int and(char a, char b)
{
    char buf[2];
    buf[0] = 0;
    buf[1] = b;
    return buf[a];
}
```

アセンブリにすると以下のようになります。

```x86asm
.intel_syntax noprefix
.global and
and:
    push rbp
    mov rbp,rsp
    sub rsp, 2

    mov BYTE PTR [rbp - 2], 0
    mov BYTE PTR [rbp - 1], dil
    mov al, BYTE PTR [rbp + rsi - 2]
    movzb rax, al

    mov rsp, rbp
    pop rbp
    ret
```

こちらもちゃんと論理積として動いていることがわかります。

```c
int and(char a, char b);

int main(void)
{
    printf("and(0,0) = %d\n", and(0,0));
    printf("and(0,1) = %d\n", and(0,1));
    printf("and(1,0) = %d\n", and(1,0));
    printf("and(1,1) = %d\n", and(1,0));
}
```

```console
$ gcc -static -o movprog main.c and.s
$ ./movprog
and(0,0) = 0
and(0,1) = 0
and(1,0) = 0
and(1,1) = 1
```

これと同じ発想で論理和も作ることができます。

### 論理回路

上でxnorとand(or)が作れたので、それを組み合わせて好きな論理回路が作れます。

たとえば半加算器を書いてみました。

```x86asm
.intel_syntax noprefix
.global halfadder
halfadder:
    push rbp
    mov rbp,rsp
    sub rsp, 256

    mov BYTE PTR [rbp + rdi - 256], 0
    mov BYTE PTR [rbp + rsi - 256], 1
    mov al, BYTE PTR [rbp + rdi - 256]
    movzb rax, al

    mov BYTE PTR [rbp + rax - 256], 0
    mov BYTE PTR [rbp - 256], 1
    mov al, BYTE PTR [rbp + rax - 256]
    movzb rax, al

    mov BYTE PTR [rbp - 2], 0
    mov BYTE PTR [rbp - 1], dil
    mov dil, BYTE PTR [rbp + rsi - 2]
    mov BYTE PTR [rdx], dil

    mov rsp, rbp
    pop rbp
    ret
```

```c
#include <stdio.h>

int halfadder(char a, char b, char *dst);

int main(void)
{
    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
        {
            char c;
            char s = halfadder(i, j, &c);
            printf("halfadder(%d,%d) = %d %d\n", i, j, c, s);
        }
}
```

```console
$ gcc -static -o movprog main.c halfadder.s
$ ./movprog
halfadder(0,0) = 0 0
halfadder(0,1) = 0 1
halfadder(1,0) = 0 1
halfadder(1,1) = 1 0
```

全加算器は途中でややこしくなって諦めました。
数十行に渡って並んだ`mov`命令のデバッグとかできるわけないだろ！

### 条件分岐

分岐命令が使えないので、書かれた`mov`命令は上から順にすべて実行されます。
しかし操作するアドレスをダミーに入れ替えることで命令の無力化はできます。

三項演算子を使うと参照するアドレスを論理演算の結果で切り替えることができます。

```
... 前略 ...

<ベースレジスタ> = <論理演算の結果> ? <普通のアドレス> : <どこか遠いところ>

    ... if文の中身 ...

<ベースレジスタ> = <普通のアドレス>

... 後略 ...
```

論理演算の結果が偽のときは実行結果に影響しないどこか遠いところで`mov`命令を動かします。
遠いところなので実質何も起きていないのと同じです。

実行時間が条件分岐で変化しないのでセキュリティ的に良いかもしれませんね！

### ループ（無理）

こうしてできたコードを終了まで繰り返す方法があればだいたいなんでも書けるようになります。
しかし前の条件分岐で見たように`mov`命令は上から下に実行される以外の能力がありません。
[プログラムカウンタ](https://toshiba.semicon-storage.com/jp/design-support/e-learning/micro_intro/chap4/1274772.html)を
`mov`命令で書き換えられればループになりますが、残念ながらそういうことはできません。
チューリングマシンを実現するために一体どんな方法でループを実現しているのでしょうか……？

実は元論文ではコードの最後に無条件ジャンプを1つだけ使い、プログラムの最初に戻っています。
**ズルじゃん！movだけじゃないじゃん！**

### おわり

というわけで元論文では最後に`jmp`命令をひとつだけ使ってチューリングマシンを作っていました。
どうやら環状リンクリストを作ってテープとして使うようです。
全部`mov`だけで解決しているものだと思っていたのでガッカリしました。

しかし`mov`だけで自由に論理回路が組めるのは事実です。
手書きするにはなかなかつらいものがありますが、縛りプレイ、頭の体操としてやってみると楽しいです。
ぜひやってみてください。
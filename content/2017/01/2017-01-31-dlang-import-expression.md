---
date: 2017-01-31
title: "コンパイル時にファイルから文字列を読み込む"
tags:
- dlang
- tech
---

長い文字列を埋め込むために
[いろいろ迷走した]({% include relative %}{% post_url 2016/12/2016-12-06-170d11cc6b82592a8404 %})
が、コンパイル時にファイルから文字列を読み込む方法があることに気づいたので詳しく調べる。

[Import Expression](https://dlang.org/spec/expression.html#ImportExpression)
というのがある。
モジュールのimportとは違うものである。  
`import( <コンパイル時に決まる文字列定数> )`と書くと、文字列をファイル名と解釈しその中身を文字列として取り込む。
Cのincludeで変数に文字列を入れられるのと同じである。


```console
$ tree
.
├── resources
│   └── test.txt
└── test.d

1 directory, 2 files
```

```d
//$ cat test.d
import std.stdio;

void main()
{
    writeln(import("test.txt")); // resources/test.txtの中身を出力
}
```

```console
$ cat resources/test.txt 
this is test
```

セキュリティ上の理由により`-J`スイッチでインポートするファイルの場所を指定してやる必要がある。これは複数指定できるらしい。

```console
$ dmd test.d -Jresources
$ ./test
this is test

```

dubでも同じことが出来る。
デフォルトでは`views`フォルダを指定した状態になっているが、
[stringImportPaths](http://code.dlang.org/package-format?lang=json#build-settings)
でフォルダを変更することもできる。

```console
$ tree
.
├── dub.json
├── source
│   └── app.d
└── views
    └── test.txt

2 directories, 3 files
```

```d
//$ cat source/app.d 
import std.stdio;

void main()
{
    writeln(import("test.txt"));
}
```

```console
$ cat views/test.txt 
this is test
```

```console
$ dub run
Performing "debug" build using dmd for x86_64.
test ~master: building configuration "application"...
Linking...
Running ./test
this is test

```

とても便利。
たとえば[D言語くんのAAを使う時](https://github.com/kotet/progress/commit/3fc0faa3effcf1efe722b77414cfe22827d9ea5a)とかに使える。

続き: [importでコンパイル時にファイルを埋め込む]({% include relative %}{% post_url 2017/06/2017-06-28-import-any-binary %})
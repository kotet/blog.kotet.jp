---
date: 2017-06-28
title: "importでコンパイル時にファイルを埋め込む"
tags:
- dlang
- tech
---

[以前]({% include relative %}{% post_url 2017/01/2017-01-31-dlang-import-expression %})に
`import`を使って大きな文字列を別のファイルから読み込んだが、
同じ手を使って画像や動的リンクライブラリなどのテキストでないデータも読み込んで埋め込むことができるようだ。

[Embed a dynamic library in an executable](https://p0nce.github.io/d-idioms/#Embed-a-dynamic-library-in-an-executable)

リソースの埋め込みはWindowsならリソースコンパイラ、Linuxならobjcopyというのを使うもののようだが、
この方法はどちらでも使えて気軽でいいと思う。

```console
$ tree
.
├── dub.json
├── resources
│   └── dman.png
└── source
    └── app.d

2 directories, 3 files
```

#### `dub.json`

```json
{
	"name": "dman",
	"authors": [
		"kotet"
	],
	"description": "Dman",
	"copyright": "Copyright © 2017, kotet",
	"license": "MIT",
	"stringImportPaths": [
		"resources"
	]
}
```

#### `source/app.d`

```d
static immutable ubyte[] dman = cast(immutable ubyte[]) import("dman.png");

void main()
{
	import std.file : write;
	import std.uuid : randomUUID;
	write("dman-" ~ randomUUID().toString() ~ ".png", dman);
}
```

```console
$ ls
dub.json  resources  source
$ dub build
Performing "debug" build using dmd for x86_64.
dman ~master: target for configuration "application" is up to date.
To force a rebuild of up-to-date targets, run again with --force.
$ ./dman 
$ ./dman 
$ ./dman 
$ ls
dman                                           dman-88c57901-9ce1-4347-a9b7-774fc1faf7e8.png  source
dman-212640dc-fde8-4abd-bf85-ea4a6ef2cbdd.png  dub.json
dman-3049dffd-db30-4901-b9d9-b2d132f4c0a5.png  resources
```

どこでも実行するたびにD言語くんのpng画像を生み出せるアプリケーションができた。
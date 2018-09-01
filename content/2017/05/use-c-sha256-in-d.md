---
date: 2017-05-03
aliases:
- /2017/05/03/use-c-sha256-in-d.html
title: "dubで自力でOpenSSLを呼び出す"
tags:
- dlang
- tech
---

[前回](/2017/04/29/use-c-math-in-d.html)の続き。
明示的にリンクする必要のあるライブラリであるOpenSSLを使って`std.digest.sha`を使わずにSHA256を計算する。
自分みたいな初心者のための基礎的な記事を量産することを目標にしているので、細かい手順をできるだけ詳細に具体的に書いていきたい。

### 1 - `dub init`

前回と同じ。

```console
$ tree
.
├── dub.json
└── source
    └── app.d

1 directory, 2 files
```

### 2 - 宣言を探す

OpenSSLはインストール済みとする。
`/usr/include/openssl/sha.h`を読んでみる。

```console
$ cat /usr/include/openssl/sha.h | grep SHA256
# define SHA256_CBLOCK   (SHA_LBLOCK*4)/* SHA-256 treats input data as a
# define SHA256_DIGEST_LENGTH    32
typedef struct SHA256state_st {
} SHA256_CTX;
# ifndef OPENSSL_NO_SHA256
int private_SHA224_Init(SHA256_CTX *c);
int private_SHA256_Init(SHA256_CTX *c);
int SHA224_Init(SHA256_CTX *c);
int SHA224_Update(SHA256_CTX *c, const void *data, size_t len);
int SHA224_Final(unsigned char *md, SHA256_CTX *c);
int SHA256_Init(SHA256_CTX *c);
int SHA256_Update(SHA256_CTX *c, const void *data, size_t len);
int SHA256_Final(unsigned char *md, SHA256_CTX *c);
unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md);
void SHA256_Transform(SHA256_CTX *c, const unsigned char *data);
```

```console
$ cat /usr/include/openssl/sha.h | grep SHA256_DIGEST_LENGTH
# define SHA256_DIGEST_LENGTH    32
```

今回は

```c
unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md);
```

と

```c
# define SHA256_DIGEST_LENGTH    32
```

を使えるようにする。

### 3 - 宣言

#### `source/sha.d` (New File)

```d
/// C : # define SHA256_DIGEST_LENGTH    32
enum SHA256_DIGEST_LENGTH = 32;

/// C : unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md);
extern (C) ubyte* SHA256(const ubyte* d, size_t n, ubyte* md);
```

`unsigned char`は`ubyte`と対応している。

### 4 - 使う

#### `source/app.d`

```d
import std.stdio : writeln;
import std.digest.digest : toHexString;
import sha;

void main()
{
	string text = "The quick brown fox jumps over the lazy dog";
	ubyte[SHA256_DIGEST_LENGTH] hash;

	SHA256(cast(const ubyte*) &text[0], text.length, cast(ubyte*) &hash[0]);
	
	assert(hash.toHexString() == "D7A8FBB307D7809469CA9ABCB0082E4F8D5651E46D3CDB762D02D0BF37C9E592");
	hash.toHexString.writeln();
}
```

入力文字列とその結果はこちらのサイトから引用した。
このサイトの引用元はリンクが切れてしまっているようだ。

[SHA-256 ハッシュ計算 - BiBoLoG](http://d.hatena.ne.jp/Guernsey/20100622/1277185273)

### 5 - リンクするライブラリの指定

#### `dub.json`

```json
{
	"name": "shatest",
	"authors": [
		"kotet"
	],
	"description": "A minimal D application.",
	"copyright": "Copyright © 2017, kotet",
	"license": "proprietary",
	"libs": [
		"openssl"
	]
}
```

`libs`に外部ライブラリの名前を渡すとリンカオプションになる。

### 6 - 完成

```console
$ dub build
Performing "debug" build using dmd for x86_64.
shatest ~master: building configuration "application"...
Linking...
$ ./shatest
D7A8FBB307D7809469CA9ABCB0082E4F8D5651E46D3CDB762D02D0BF37C9E592
```

### 追記

[次回:構造体を使う](/2017/05/04/use-c-struct-in-d.html)
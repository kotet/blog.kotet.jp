---
date: 2017-05-04
aliases:
- /2017/05/04/use-c-struct-in-d.html
title: "dubで自力でCの構造体を使う"
tags:
- dlang
- tech
- cpplang
---

[前回](/2017/05/03/use-c-sha256-in-d.html)の続き。
前回と同じようにOpenSSLを使って`std.digest.sha`を使わずにSHA256を計算する。
今回は前回と違い、データは逐次入力される。
そのような使い方の場合、`SHA256_CTX`と言う構造体に操作をしていく。
よってD言語側でも`SHA256_CTX`を使えるようにする必要がある。
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

### 2 - 宣言

`$ gcc -E /usr/include/openssl/sha.h | less`として必要な関数や構造体の宣言を探す。
そしてそれをDの宣言に書き下していく。

#### `source/sha.d` (New File)

```d
extern (C)
{
    /**
    C :
    typedef struct SHA256state_st {
        unsigned int h[8];
        unsigned int Nl, Nh;
        unsigned int data[16];
        unsigned int num, md_len;
    } SHA256_CTX;
    */

    struct SHA256_CTX
    {
        uint[8] h;
        uint Nl;
        uint Nh;
        uint[16] data;
        uint num;
        uint md_len;
    }

    /// C : int SHA256_Init(SHA256_CTX *c);
    int SHA256_Init(SHA256_CTX* c);
    /// C : int SHA256_Update(SHA256_CTX *c, const void *data, size_t len);
    int SHA256_Update(SHA256_CTX* c, const void* data, size_t len);
    /// C : int SHA256_Final(unsigned char *md, SHA256_CTX *c);
    int SHA256_Final(ubyte* md, SHA256_CTX* c);
}
/// C : # define SHA256_DIGEST_LENGTH    32
enum SHA256_DIGEST_LENGTH = 32;
```

書き直すところが少なくてほとんどコピペからの修正で済む。
うれしい。

Cのコードで構造体は`struct SHA256state_st`として定義され、それに`SHA256_CTX`と別名をつけるようになっている。
しかし
[こちら](https://www.gamedev.net/resources/_/technical/game-programming/binding-d-to-c-r3122)
の記事にあるように、以下のコードは同じ意味になる。

> ```txt
// In C
typedef struct foo_s
{
	int x;
	struct foo_s *next;
} foo_t;

// In D
struct foo_t
{
	int x;
	foo_t *next;
}
```

なので`SHA256state_st`はどこかになくなっている。

### 3 - 使う

#### `source/app.d`

```d
import std.stdio;
import std.digest.digest : toHexString;
import sha;

void main()
{
	string[] strs = ["The ", "quick ", "brown ", "fox ", "jumps ", "over ",
		"the ", "lazy ", "dog"];
	ubyte[SHA256_DIGEST_LENGTH] hash;
	SHA256_CTX ctx;

	SHA256_Init(&ctx);
	foreach (str; strs)
	{
		SHA256_Update(&ctx, cast(ubyte*)&str[0], str.length);
	}
	SHA256_Final(cast(ubyte*)&hash, &ctx);

	assert(hash.toHexString() == "D7A8FBB307D7809469CA9ABCB0082E4F8D5651E46D3CDB762D02D0BF37C9E592");
	hash.toHexString.writeln();
}
```

### 4 - リンクするライブラリの指定

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

### 5 - 完成

```console
$ dub run
Performing "debug" build using dmd for x86_64.
shatest ~master: building configuration "application"...
Linking...
Running ./shatest
D7A8FBB307D7809469CA9ABCB0082E4F8D5651E46D3CDB762D02D0BF37C9E592
```

---
title: "19:ipfs filesコマンドでディレクトリを構築する"
date: 2018-09-26
tags:
- ipfs体験記
- ipfs
- tech
excerpt: "ipfs filesコマンドの使い方を理解したので書く。 これはIPFS上のディレクトリ構造の編集を支援するためのコマンドである。"
---

`ipfs files`コマンドの使い方を理解したので書く。
これはIPFS上のディレクトリ構造の編集を支援するためのコマンドである。

### ipfs files

IPFS上のコンテンツはイミュータブルである。
異なるものは異なるアドレスになる。
ディレクトリの追加は`ipfs add -r`で可能だが、これでは不十分なときがある。
たとえばIPFS上の大きなデータが入ったディレクトリを作りたい時。
`ipfs add -r`を使う場合、いったん全データをローカルに落とすことになる。
大規模なデータセットの共有を目的のひとつとしているIPFSでこれは困る。

そんなときに使うのが`ipfs files`コマンドである。
このコマンドには独自の仮想的なディレクトリが存在し、
そのディレクトリ構造をコマンドを使って書き換えることができる。
内部的には構造が書き換えられるたびに新しいディレクトリのメタデータが生成され、ハッシュが更新される。
あくまで小さなメタデータを扱っているだけなので更新を繰り返してもディスクが一杯になったりしないし、
大きな更新も発生しないのだ。

### 使ってみる

#### 追加

とりあえずルートにファイルを追加してみる。
ファイルの追加は`ipfs files write`や`ipfs files cp`でできる。
`ipfs files write`は直接データを扱い、それをディレクトリに追加する。
`ipfs files cp`はIPFS上にあるデータをディレクトリに追加する。

`ipfs files write`はかなりプリミティブな「書き込み」をするようだ。

`ipfs files cp`はメタデータを操作しているだけなので、大きなデータを操作しても時間はかからない。

```bash
$ echo test > test.txt
$ # -e または --create をつけるとファイルが存在しない場合作成してくれる
$ ipfs files write -e /test.txt test.txt
$ ipfs files ls /
test.txt
$ ipfs files read /test.txt
test
$ # 標準入力からの書き込み
$ echo hello | ipfs files write /test.txt
$ ipfs files read /test.txt
hello
$ echo test | ipfs files write /test.txt
$ ipfs files read /test.txt
test

$ # オフセット指定
$ echo test | ipfs files write -o 3 /test.txt
$ ipfs files read /test.txt
testest
$ ipfs add test.txt 
added QmeomffUNfmQy76CQGy9NdmqEnnHU9soCexBnGU3ezPHVH test.txt
 5 B / 5 B [===================================================================================================================] 100.00%
$ # 既存のハッシュを追加
$ ipfs files cp /ipfs/QmeomffUNfmQy76CQGy9NdmqEnnHU9soCexBnGU3ezPHVH /test2.txt
$ ipfs files ls /
test.txt
test2.txt
$ # 英語版Wikipediaのバックアップ。250GBくらいあり、ローカルには保存されていない
$ ipfs files cp /ipfs/QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco /wikipedia
$ ipfs files ls -l
test.txt	Qmbb6dymZ5iDSraj6QPu5wrZ2BNjr7AX29McbH1PkNs9uY	8
test2.txt	QmeomffUNfmQy76CQGy9NdmqEnnHU9soCexBnGU3ezPHVH	5
wikipedia	QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco	0
$ ipfs files ls -l /wikipedia/
-	QmPQVLHXAcDLvdf6ni24YWgGwitVTwtpiFaKkMfzZKquUB	0
I	QmNYBYYjwtCYXdA2KC68rX8RqXBu9ajBM6Gi8CBrXjvk1j	0
M	QmaeP3RagknCH4gozhE6VfCzTZRU7U2tgEEfs8QMoexEeG	0
index.html	QmdgiZFqdzUGa7vAFycnA5Xv2mbcdHSsPQHsMyhpuzm9xb	154
wiki	QmehSxmTPRCr85Xjgzjut6uWQihoTfqg9VVihJ892bmZCp	0
```

#### ディレクトリ作成、移動、削除

コマンド名は基本的にUnixのファイルシステムを模した形になっている。
先程から使っていた`cp`や`ls`はもちろん、`mkdir`、`mv`、`rm`もある。

ただし、ワイルドカードなどには対応していないようだ。
移動元のパスを省略したときの挙動もあまり便利でないので、
ちゃんとファイル名も含めたフルパスを使おう。

```bash
$ ipfs files mkdir /tests
$ ipfs files mv /test.txt /tests/test.txt
$ ipfs files mv /test2.txt /tests/test2.txt
$ ipfs files ls /
tests
wikipedia
$ ipfs files ls /tests/
test.txt
test2.txt
$ ipfs files rm /tests/test2.txt
$ ipfs files ls /tests/
test.txt
$ ipfs files rm -r /tests/
$ ipfs files ls /
wikipedia
```

#### ipfs files flush

ここまで行ってきた操作のたびに新しいディレクトリオブジェクトが作成され、
おそらく各バージョンがすべてローカルのIPFSリポジトリに保存されている。
サイズはそんなに大きくないのでまあ問題ないのだが、
気になる場合は各コマンドを`--f=false`を付けて実行することで編集をオンメモリに行える。
その場合編集の最後に`ipfs files flush`を実行してやらないと、
作ったディレクトリオブジェクトは消えてしまう。
ほぼ確実にディレクトリオブジェクトを持っているのは宇宙で自分ただ一人である。
なので仮にそのオブジェクトを指すアドレスを持っていたとしても、
一度ディレクトリオブジェクトが消えた時点でアクセスは永久にできなくなる。

#### ipfs files chcid

ちょっとこのコマンドはよく分からなかった。
たぶんアドレス生成に使うハッシュ関数などの変更に使う。
オプション全部にexperimentalがついているので使わないほうがいいのだろう。

#### ipfs files stat

ここまでの操作で作ったディレクトリを公開するにはアドレスとなるハッシュ値が必要である。
`ipfs files stat`でハッシュ値を含めた情報を参照する。

```bash
$ ipfs files stat /
QmckgmRuhpZFrpiPVULs5aUTdG8V8Cb4ZdMS83iEjUxSu7
Size: 0
CumulativeSize: 658038834858
ChildBlocks: 1
Type: directory
```
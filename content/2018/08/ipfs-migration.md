---
date: 2018-08-02
aliases:
- /2018/08/02/ipfs-migration.html
title: "16:fs-repo-migrationsをつかった最新版への移行"
tags:
- ipfs体験記
- ipfs
- tech
---

IPFSを動かし続けているとバージョンアップに伴いリポジトリの移行が必要になる。
今回はそれを初めてやることになったので記録する。

### いきさつ

ノートPCは色んな所に持ち運ぶ。
P2Pソフトを動かしてほしくない場所もあるので、
最近はIPFSデーモンは基本的に停止して必要なときだけ起動するようにしている。
しかしIPFSが必要なときというのも今のところない
(仮にどこかでIPFSが使われていたとしてもほぼ必ずフォールバックが用意されている)
ので、ずっと切ったままになっていた。

今日、ふと思いついてIPFSデーモンを起動してみることにした。
しかしうまく起動しない。
適当にコマンドを入力してみたところ以下のようなメッセージが出た。

```console
$ ipfs repo stat
Error: ipfs repo needs migration
```

どうやら動かしていない間にローカルリポジトリのバージョンが古くなっていたようだ。

### fs-repo-migrations

もちろんローカルリポジトリが古くなるたびにリポジトリをカラにして作り直す必要はない。
そのためのツール、fs-repo-migrations というものが用意されている。

[ipfs/fs-repo-migrations: Migrations for the filesystem repository of ipfs clients](https://github.com/ipfs/fs-repo-migrations)

READMEに書いてあるように、リポジトリのバージョンと go-ipfs
のバージョンの対応は以下のようになっている。

| リポジトリのバージョン | go-ipfs のバージョン |
|------------------------:|----------------------|
| 1 | 0.0.0 - 0.2.3 |
| 2 | 0.3.0 - 0.3.11 |
| 3 | 0.4.0 - 0.4.2 |
| 4 | 0.4.3 - 0.4.5 |
| 5 | 0.4.6 - 0.4.10 |
| 6 | 0.4.11 - 0.4.15 |
| 7 | 0.4.16 - 最新版 |

今自分のPCに入っている go-ipfs のバージョンは `0.4.16` なので、
ちょうど前回のアップデートでバージョンが合わなくなったようだ。

### 移行

というわけで移行作業をやってみる。

#### fs-repo-migrations のインストール

go がインストール済みなので導入は速い。
go のない人は [dist.ipfs.io](https://dist.ipfs.io/#fs-repo-migrations)
とかでバイナリをダウンロードしてくる。
今回はIPFSデーモンが動かないので仕方がないが、
IPFSからダウンロードする
([/ipns/dist.ipfs.io](https://ipfs.io/ipns/dist.ipfs.io/#fs-repo-migrations))
とIPFSに対する貢献になるかもしれない。

```console
$ go get -u github.com/ipfs/fs-repo-migrations
```

リポジトリのバージョンがまた新しくなったら再度 `go get -u` すれば良いと思う。

#### バックアップ

書く必要もない気がするが念のため。
何かあったときのためにリポジトリのコピーを作っておく。

```console
$ cp -r ~/.ipfs{,.backup}
```

自分のリポジトリは10ギガバイトくらいあるのでけっこう時間がかかった。

#### 移行

準備ができたので fs-repo-migrations を動かしてみる。
オプションは以下のとおり。

```console
$ fs-repo-migrations -h
Usage of fs-repo-migrations:
  -to int
    	specify version to upgrade to (default 7)
  -v	print highest repo version and exit
  -y	answer yes to all prompts
```

古いバージョンへダウングレードしたりもできるっぽい。

実行してみると移行対象のディレクトリの確認を求められた。
確認すると移行作業が始まる。
今回は一瞬で終わった。
バージョンが遠いと時間がかかったりするのだろうか?

```console
$ fs-repo-migrations
Found fs-repo version 6 at /home/kotet/.ipfs
Do you want to upgrade this to version 7? [y/n] y
===> Running migration 6 to 7...
applying 6-to-7 repo migration
migrating IPNS record for key: self
updated version file
===> Migration 6 to 7 succeeded!
```

### 確認

ちゃんと移行できただろうか。

```console
$ ipfs repo stat
Calculating datastore size. This might take 5m0s at most and will happen only once
NumObjects: 708065
RepoSize:   8216006954
StorageMax: 53687091200
RepoPath:   /home/kotet/.ipfs
Version:    fs-repo@7
```

大丈夫そう。

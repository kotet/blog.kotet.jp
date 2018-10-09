---
title: "Arch Linuxでjavacをインストールする"
date: 2018-10-09
tags:
- java
- linux
- tech
excerpt: "少し詰まったのでメモ。 講義でJavaを書くので、自分のラップトップにも開発環境を構築しようと思った。 しかしArch Linuxにおいては、 ただパッケージをインストールするだけではjavac、javap等のツールが使用できない。"
---

少し詰まったのでメモ。
講義でJavaを書くので、自分のラップトップにも開発環境を構築しようと思った。
しかしArch Linuxにおいては、
ただパッケージをインストールするだけでは`javac`、`javap`等のツールが使用できない。

### archlinux-java

ArchWikiを見てみると記事がある。

[Java - ArchWiki](https://wiki.archlinux.jp/index.php/Java)

この記事中にあるパッケージでJDKのインストールができるのだが、
インストールしただけでは`PATH`が通っていないようで使えない。
Arch LinuxのJavaには`archlinux-java`という専用の管理用コマンドが存在しており、
インストールしたあとにそれで有効化するという仕組みになっているようだ。

`archlinux-java`は`java-runtime-common`パッケージの中にある。
通常のパッケージマネージャーでインストールされたパッケージは、
`archlinux-java`をサポートしていれば`archlinux-java status`で一覧できるようになる。

```bash
$ yaourt -S jdk10-openjdk
$ archlinux-java status
Available Java environments:
  java-10-openjdk
  java-8-openjdk/jre (default)
```

名前を確認したら、`archlinux-java set <環境名>`で環境が利用可能になる。
リンクの作成などをするため管理者権限が必要なので注意。

```bash
$ sudo archlinux-java set java-10-openjdk
$ which javac
/usr/bin/javac
$ file /usr/bin/javac
/usr/bin/javac: symbolic link to /usr/lib/jvm/default/bin/javac
```
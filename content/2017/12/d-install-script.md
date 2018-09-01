---
date: 2017-12-07
aliases:
- /2017/12/07/d-install-script.html
title: "インストールスクリプトの使い方"
tags:
- dlang
- tech
excerpt: "今日は12月7日だが、空いていたのでD言語 Advent Calendar 2017 2日目に参加する。D言語のダウンロードページにあるインストールスクリプトが、バージョン指定など思いの外多機能で便利だということに今更気がついた。 ただ--helpを日本語化しただけではあるが、使い方と、実際に使った結果をまとめておく。"
---

今日は12月7日だが、空いていたので[D言語 Advent Calendar 2017](https://qiita.com/advent-calendar/2017/dlang) 2日目に参加する。

[D言語のダウンロードページ](https://dlang.org/download.html)にあるインストールスクリプトが、バージョン指定など思いの外多機能で便利だということに今更気がついた。
ただ`--help`を日本語化しただけではあるが、使い方と、実際に使った結果をまとめておく。

### はじめに

ダウンロードページにも書かれているコマンドを実行する。

```console
~$ curl -fsS https://dlang.org/install.sh | bash -s dmd
Downloading https://dlang.org/install.sh
######################################################################## 100.0%
Downloading https://dlang.org/d-keyring.gpg
######################################################################## 100.0%
The latest version of this script was installed as ~/dlang/install.sh.
It can be used it to install further D compilers.
Run `~/dlang/install.sh --help` for usage information.

Downloading and unpacking http://downloads.dlang.org/releases/2.x/2.077.1/dmd.2.077.1.linux.tar.xz
######################################################################## 100.0%
Downloading and unpacking http://code.dlang.org/files/dub-1.6.0-linux-x86_64.tar.gz
######################################################################## 100.0%

Run `source ~/dlang/dmd-2.077.1/activate` in your shell to use dmd-2.077.1.
This will setup PATH, LIBRARY_PATH, LD_LIBRARY_PATH, DMD, DC, and PS1.
Run `deactivate` later on to restore your environment.
```

すると、dmd、dubの最新版と、インストールスクリプト`install.sh`が`~/dlang`にダウンロードされる。

```console
~$ ls -l ~/dlang
合計 44
-rw-rw-r--  1 kotet kotet  9488 12月  7 15:33 d-keyring.gpg
drwx------ 11 kotet kotet  4096 12月  7 15:34 dmd-2.077.1
lrwxrwxrwx  1 kotet kotet     9 12月  7 15:34 dub -> dub-1.6.0
drwx------  2 kotet kotet  4096 12月  7 15:34 dub-1.6.0
-rwxrwxr-x  1 kotet kotet 17443 12月  7 15:33 install.sh
```

さきほど言われたとおり`source ~/dlang/dmd-2.077.1/activate`を実行すると、そのターミナルに限りDのコンパイラとdubが使えるようになる。
ターミナルを終了するか`deactivate`を実行すると元に戻る。

```console
~$ source ~/dlang/dmd-2.077.1/activate
(dmd-2.077.1)~$ which dmd
/home/kotet/dlang/dmd-2.077.1/linux/bin64/dmd
(dmd-2.077.1)~$ which dub
/home/kotet/dlang/dub/dub
(dmd-2.077.1)~$ deactivate
~$ which dmd
~$ which dub
```

### ヘルプ

ここから`~/dlang/install.sh`を使う。
`--help`で使い方がわかる。

```console
~$ ~/dlang/install.sh --help
Usage

  install.sh [<command>] [<args>]

Commands

  install       Install a D compiler (default command)
  uninstall     Remove an installed D compiler
  list          List all installed D compilers
  update        Update this dlang script

Options

  -h --help     Show this help
  -p --path     Install location (default ~/dlang)
  -v --verbose  Verbose output

Run "install.sh <command> --help to get help for a specific command.
If no argument are provided, the latest DMD compiler will be installed.

```

### インストール

`install`コマンドで任意のバージョンのdmd/gdc/ldcをインストールできる。
さまざまなバージョン指定方法がある。

```console
~$ ~/dlang/install.sh install -h
Usage

  install.sh install <compiler>

Description

  Download and install a D compiler.
  By default the latest release of the DMD compiler is selected.

Options

  -a --activate     Only print the path to the activate script

Examples

  install.sh
  install.sh dmd
  install.sh install dmd
  install.sh install dmd-2.071.1
  install.sh install ldc-1.1.0-beta2

Compiler

  dmd|gdc|ldc           latest version of a compiler
  dmd|gdc|ldc-<version> specific version of a compiler (e.g. dmd-2.071.1, ldc-1.1.0-beta2)
  dmd|ldc-beta          latest beta version of a compiler
  dmd-nightly           latest dmd nightly
  dmd-2016-08-08        specific dmd nightly
```

`--path`で場所を指定しない場合`~/dlang`下に`~/dlang/dmd-2.077.1`のようにインストールされる。

適当に`dmd-2.074.1`をインストールしてみる。

```console
~$ ~/dlang/install.sh install dmd-2.074.1
Downloading and unpacking http://downloads.dlang.org/releases/2.x/2.074.1/dmd.2.074.1.linux.tar.xz
######################################################################## 100.0%
dub-1.6.0 already installed

Run `source ~/dlang/dmd-2.074.1/activate` in your shell to use dmd-2.074.1.
This will setup PATH, LIBRARY_PATH, LD_LIBRARY_PATH, DMD, DC, and PS1.
Run `deactivate` later on to restore your environment.
~$ source ~/dlang/dmd-2.074.1/activate
(dmd-2.074.1)~$ which dmd
/home/kotet/dlang/dmd-2.074.1/linux/bin64/dmd
(dmd-2.074.1)~$ dmd --version
DMD64 D Compiler v2.074.1
Copyright (c) 1999-2017 by Digital Mars written by Walter Bright
```

### リスト

`list`コマンドでインストール済みのコンパイラを一覧できる。

```console
~$ ~/dlang/install.sh list
dmd-2.077.1
dmd-2.074.1
```

### アンインストール

`uninstall`でアンインストールできる。
`~/dlang/<コンパイラ名>`を削除しているだけなので手動で`rm`してもいいと思う。

```console
~$ ~/dlang/install.sh uninstall dmd-2.074.1
Removing ~/dlang/dmd-2.074.1
```

### アップデート

`update`でスクリプト自身の更新ができる。

```console
~$ ~/dlang/install.sh update
Downloading https://dlang.org/install.sh
######################################################################## 100.0%
The latest version of this script was installed as ~/dlang/install.sh.
It can be used it to install further D compilers.
Run `~/dlang/install.sh --help` for usage information.
```

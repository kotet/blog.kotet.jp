---
title: "ディレクトリを日付で管理するためのBash関数を作った"
date: 2018-10-04
tags:
- tech
excerpt: "大学の演習ではいろいろなことをする。 そのたびに新しいファイルが作られる。 それらすべてをホームディレクトリ直下に置くとカオスなことになる。 自分はあるていどディレクトリを分けて整理しようとしているが、それでもなかなか雑然としていて、 たぶん過去の特定のファイルを探し出すことは難しい。"
---

大学の演習ではいろいろなことをする。
そのたびに新しいファイルが作られる。
それらすべてをホームディレクトリ直下に置くとカオスなことになる。
自分はあるていどディレクトリを分けて整理しようとしているが、それでもなかなか雑然としていて、
たぶん過去の特定のファイルを探し出すことは難しい。

そのため、命名規則に一貫性のあるディレクトリ作成を支援するBash関数を書いた。
横の人に聞いてみたところ需要があるようなのでここで公開する。
使ってみて改善点などあれば教えてほしい。

### mkws

`mkws` （"make workspace"の略のつもり）
は日付で管理されたディレクトリ構造を`~/workspace`以下に構築するBash関数である。

引数なしで実行すると `~/workspace/<年>/<月>-<日>/space.<ランダムなプレフィックス>`
という規則でディレクトリを作成する。
プレフィックスのおかげで名前がかぶることを心配しなくて良くなり便利。
そして、作ったディレクトリに移動する。

```bash
$ mkws 
mkdir: created directory '/home/kotet/workspace'
mkdir: created directory '/home/kotet/workspace/2018'
mkdir: created directory '/home/kotet/workspace/2018/10-04'
mkdir: created directory '/home/kotet/workspace/2018/10-04/space.bbjg'

  /home/kotet/workspace/2018/10-04/space.bbjg

```

引数を与えると
`~/workspace/<年>/<月>-<日>/<引数>.<ランダムなプレフィックス>`
というディレクトリが作られる。

```bash
$ mkws test
mkdir: created directory '/home/kotet/workspace/2018/10-04/test.tbxr'

  /home/kotet/workspace/2018/10-04/test.tbxr

$ mkws kotet
mkdir: created directory '/home/kotet/workspace/2018/10-04/kotet.stwe'

  /home/kotet/workspace/2018/10-04/kotet.stwe

```

### インストール方法

#### ワンライナー

一応コマンド一発でインストールできるようにしておく。
以下のコマンドをコピペして実行すると`mkws`コマンドが使えるようになる。

```bash
curl https://gist.githubusercontent.com/kotet/965657d6966a888ad3bf90de73142820/raw/mkws.sh >> ~/.bashrc && source ~/.bashrc
```

#### 手動で追記

Gistで公開されているものを`~/.bashrc` に追記すればインストールは完了である。
この記事の初版を書いたあと、改変がしやすいように多少整理した。
命名規則が気にいらなかったりする場合は自分で書き換えてほしい。

[https://gist.github.com/kotet/965657d6966a888ad3bf90de73142820](https://gist.github.com/kotet/965657d6966a888ad3bf90de73142820)
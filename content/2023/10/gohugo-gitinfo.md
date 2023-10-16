---
date: 2023-10-15
title: "20:HugoのGitInfo機能をGitHub Actionsで使う"
tags:
    - hugo
    - github
    - tech
image: /img/blog/2023/10/rootless-vine.png
---

<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.12.0/languages/yaml.min.js"></script>

このブログの記事の作成日の欄のとなりに最終更新日が表示されている。

![](/img/blog/2023/10/screenshot-lastchanged.png)

前から最終更新日を表示したいと思っていたが、うまく行かなくて断念するのを繰り返していた。
最近になってようやく原因に気づいたので、ここに書いておく。

### HugoのGitInfo機能

まず、最終更新日の表示にはHugoのGitInfo機能を使う。
GitInfo機能はGitの履歴情報をHugoのテンプレートから参照できるようにする機能である。
そのなかの`GitInfo.AuthorDate.Format`を使う。

```html
Last modified: <time>{{ .GitInfo.AuthorDate.Format "2006-01-02" }}</time>
```

このようにすると、gitのコミット履歴を見て、ページのもととなったファイルの最終更新日を表示してくれる。
自分はサイトのビルドをGitHub Actionsで行っている。
ローカルでビルドしているときは上記のテンプレートが問題なく動作するのだが、GitHub Actionsでビルドするとすべてのページの最終更新日が同じになってしまっていた。

### GitHub ActionsにおけるGitの履歴情報

Github Actionsでビルドを行うとき、`actions/checkout`を使ってリポジトリをチェックアウトする。
このとき、デフォルトではシャロークローンが行われる。
つまり、以下の画像のように最新のコミットとそれに関連するファイルの情報のみが取得され、それ以前のコミットなどの情報は一切取得されない。

![https://github.blog/jp/wp-content/uploads/sites/2/2021/01/Image4.png?w=800&resize=800%2C414](/img/blog/2023/10/shallow-clone.png)

画像引用元: [パーシャルクローンとシャロークローンを活用しよう - GitHubブログ](https://github.blog/jp/2021-01-13-get-up-to-speed-with-partial-clone-and-shallow-clone/)

この状態では、`git log`等のコマンドは正しく動作しない。
同様に、HugoのGitInfo機能も正しく動作しない。

### 解決策

`actions/checkout`を使うとき、`fetch-depth`オプションを指定する。
デフォルトでは1になっていて、このときはgitコマンドでいうところの`--depth=1`が指定されている。
これを`0`にすると、フルクローンが行われる。
filterオプションに`blob:none`を指定することで、過去のコミットについてはファイルを取得せず、履歴情報のみを取得する。

```yaml
- uses: actions/checkout@v4
  with:
      fetch-depth: 0
      filter: blob:none
```

これで、hugoはgitの履歴情報にアクセスできるようになった。

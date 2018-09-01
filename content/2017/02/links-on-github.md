---
date: 2017-02-28
aliases:
- /2017/02/28/links-on-github.html
title: "コミットメッセージ上で他のリポジトリの特定のコミットを参照する等"
tags:
- github
- tech
image: "2017/02/28/twitter.png"
---

GitHubには、Issue番号などを自動的にリンクにする機能がある。
他のリポジトリの特定のコミットを参照したかったのだが、なかなか方法が見つからなかった。
しばらく調べていたらGitHubのヘルプにたどり着いた。

[Autolinked references and URLs - User Documentation](https://help.github.com/articles/autolinked-references-and-urls/)

試してみたところコミットメッセージ上に書いたPR、issue、commitへの参照が問題なくリンクになった。
以下、
[こちらのテスト用リポジトリ](https://github.com/kotet/test-)
などのスクショを交えてやりたい事ごとにまとめる。

## リポジトリ内のPull request / Issueを参照

![スクショ](/assets/2017/02/28/link-pr.png)

これはよく使われている。
ただ`#<番号>`と書くだけである。

## リポジトリ内のCommitを参照

![スクショ](/assets/2017/02/28/link-commit.png)

ハッシュを書くだけでリンクになる。
全部書かなくても特定できる長さ(最大級のプロジェクトでも8桁程度)なら大丈夫。
灰色でリンクっぽくないが、クリックするとちゃんと指定したコミットへ飛ぶ。

## 他のリポジトリのPull request / Issueを参照

![スクショ](/assets/2017/02/28/link-pr-other.png)

`<ユーザー名>/<リポジトリ名>#<番号>`と書く。
これはリンクっぽい色をしている。

## 他のリポジトリのCommitを参照

![スクショ](/assets/2017/02/28/link-commit-other.png)

`<ユーザー名>/<リポジトリ名>@<ハッシュ>`と書く。
これが自分が知りたかったこと。
やはり色がリンクっぽくない。

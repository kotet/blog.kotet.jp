---
date: 2017-04-11
title: "Gitlabのissueのタスクの進捗をまとめるシェルスクリプト"
tags:
- tech 
---

いろいろあって必要になって作った。
ひょっとすると他に必要な人がいるかもしれないので残しておく。

特定のprojectのissueのdescriptionにあるチェックボックスの数を数えてHTMLにする。
`$REPORT_GENERATOR_TOKEN`と`$PROJECT_ID`をセットして実行する。

<script src="https://gist.github.com/kotet/5f864e693ed3388133b64d26915b8ccc.js"></script>

 - 追記
    完了率が100%のときにうまく動かない不具合があったため修正。
    上のコードは修正後のもの。
    まあ自分用に書いたものなので別に直してもここを更新しなくてもいいのだが……
 - 追記
    何回も更新することになったのでgistにあげた。
---
date: 2017-10-02
aliases:
- /2017/10/02/mobile-markdown-editor.html
title: "iPhoneとデスクトップでmarkdownを書くために用意したツール集"
tags:
- translation
- tech
---

[前回](/2017/09/go-your-own-way-part-two-the-heap)書いた翻訳記事は、かなりの分量がiPhone上で書かれている。
iPhoneとデスクトップ両方を使ってmarkdownの翻訳記事を書くためにさまざまなツールを使ったので、
ここにまとめておこうと思う。

### 前準備

iPhoneで翻訳をするためには、原文の閲覧と翻訳の入力を頻繁に切り替える必要がある。
閲覧と入力が別アプリだと、毎回切り替えのためにホームボタンを押すことになる。
さすがにダルいし、iPhoneの寿命も縮むので別の方法を考える必要がある。
その結果、markdown中に原文を載せる形態をとることにした。

markdownはHTMLと同じ方法でコメントアウトができる。
変換後のHTMLを見るとコメントがmarkdownのまま残っているので、埋め込みHTML扱いなのだろう。
これを実現するために原文のmarkdownを用意する必要があるが、これはto-markdownというコンバータを使った。

[to-markdown - an HTML to Markdown converter written in javascript](http://domchristie.github.io/to-markdown/)

ChromeのDevToolsを使い記事本文のHTMLを抜き出し、変換する。
D blogは比較的HTMLが綺麗なので、
コードブロック以外は変換結果をパラグラフごとにコピペしてコメントアウトするだけでよかった。
まあ日本のサイトとかでない限りうまくいくだろうと思う。

### エディタ

#### iPhone

はじめgistを使って共有しようかと思ったが、意外にもiPhone側の編集環境が見つからない。
見つかってもやたら多機能で値段が高いか、日本語入力に対応していないかだった。
さすがにmarkdownを書くためだけに1000円以上かけたくはなかった。
ちなみにgistのWebの編集ページは日本語入力に対応していない方だった。
かなりの長期間gistにこだわっては諦めるのを繰り返していた。

gistを諦めたらそこそこの選択肢があった。
その中で自分が選んだのが1Writerである。

[1Writer](https://itunes.apple.com/jp/app/1writer-note-taking-writing-app/id680469088)

dropboxとの連携機能、まともな日本語入力、markdownのプレビュー、べらぼうに高いわけではない値段と、
自分の条件に合っていた。
使い始めは唐突にフォーカスが外れたりメチャクチャな動きをしていたが、今はそんなこともなく快適に編集ができている。
なんだったんだろう。

#### デスクトップ

普通にdropboxをインストールしてvscodeで書く。
markdownのプレビュー機能が付いているので便利。
しかもリアルタイムプレビューなのでgistよりも優れている。
特にとりたてて書くことがない。

### おわりに

この記事は1Writerを応援するためだけに書いたダイレクトマーケティング記事である。
自分がしてもらって嬉しいことを他人にするのである。
1回カフェに行かなければ買える値段なので、iPhoneでmarkdownを書きたい人にはおすすめである!買おう!さあ!
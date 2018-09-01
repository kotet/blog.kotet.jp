---
date: 2016-11-29
aliases:
- /2016/11/29/hamburger-menu-not-working.html
title:  'Jekyllのtheme"minima"のハンバーガーメニューがiOSで動作しないバグ'
tags:
- jekyll
- tech
excerpt: "現在このブログのハンバーガーメニューはうまく機能していない。今日はこの問題を解決しようと思って調べた。どうやら自分がなにかやらかしていたわけではなく、このブログのthemeであるminimaのバグのようだ。"
---

現在このブログのハンバーガーメニューはうまく機能していない。  
今日はこの問題を解決しようと思って調べた。どうやら自分がなにかやらかしていたわけではなく、このブログのthemeであるminimaのバグのようだ。

[Hamburger menu doesn't work on iOS · Issue #80 · jekyll/minima](https://github.com/jekyll/minima/issues/80)

すでにPRが送られているが、マージされてはいない。

[fix hamburger menu for iOs by melaniewalsh · Pull Request #85 · jekyll/minima](https://github.com/jekyll/minima/pull/85)

とりあえず修正できないか頑張る。

PRの内容通り8行目のspanにダミーハンドラ`onclick="void(0)"`を追加してみる。これによってiOSのブラウザはその要素をクリック可能なものとして認識するようだ。

```diff
-      <span class="menu-icon">
+      <span class="menu-icon" onclick="void(0)">
```

これで無事に動いた。めでたし。

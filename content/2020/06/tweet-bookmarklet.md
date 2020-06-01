---
title: "ツイートボタンがないページでツイート画面を開くブックマークレット 2020"
date: 2020-06-01
tags:
- tech
---

自分はウェブページをTwitterで共有するとき、よく以下のブックマークレットを使っていました。

[ツイートボタンがないページでもツイート画面を開くブックマークレット - Qiita](https://qiita.com/munieru_jp/items/24a4840c452c61c2dde9)

しかし今この記事を執筆している現在、このページにあるPC向けブックマークレットを起動しても正しく動作しません。
ツイート画面は出ますが、ページのタイトルとURLが入力された状態ではありません。
幸い簡単な修正で再び動くようになったので、ここに置いておきます。

### なぜ動かなくなったか

元記事のブックマークレットでは以下のようなURLを呼び出しています。

```javascript
"https://twitter.com/intent/tweet?status="+encodeURIComponent(document.title)+" "+encodeURIComponent(location.href)
```

たとえば元記事の場合は以下のようになります。

```
https://twitter.com/intent/tweet?status=%E3%83%84%E3%82%A4%E3%83%BC%E3%83%88%E3%83%9C%E3%82%BF%E3%83%B3%E3%81%8C%E3%81%AA%E3%81%84%E3%83%9A%E3%83%BC%E3%82%B8%E3%81%A7%E3%82%82%E3%83%84%E3%82%A4%E3%83%BC%E3%83%88%E7%94%BB%E9%9D%A2%E3%82%92%E9%96%8B%E3%81%8F%E3%83%96%E3%83%83%E3%82%AF%E3%83%9E%E3%83%BC%E3%82%AF%E3%83%AC%E3%83%83%E3%83%88%20-%20Qiita%20https%3A%2F%2Fqiita.com%2Fmunieru_jp%2Fitems%2F24a4840c452c61c2dde9
```

しかし`status`クエリは無視されるようになったらしく、それで動作しなくなっていました。
ツイート中のURLやハッシュタグを分けて指定できるようになったらしく、以下のように`text`と`url`を使ってあげると意図したとおりのツイート画面が出てきます。

```
https://twitter.com/intent/tweet?text=%E3%83%84%E3%82%A4%E3%83%BC%E3%83%88%E3%83%9C%E3%82%BF%E3%83%B3%E3%81%8C%E3%81%AA%E3%81%84%E3%83%9A%E3%83%BC%E3%82%B8%E3%81%A7%E3%82%82%E3%83%84%E3%82%A4%E3%83%BC%E3%83%88%E7%94%BB%E9%9D%A2%E3%82%92%E9%96%8B%E3%81%8F%E3%83%96%E3%83%83%E3%82%AF%E3%83%9E%E3%83%BC%E3%82%AF%E3%83%AC%E3%83%83%E3%83%88%20-%20Qiita&url=https%3A%2F%2Fqiita.com%2Fmunieru_jp%2Fitems%2F24a4840c452c61c2dde9
```

### ツイートダイアログを開くブックマークレット

```javascript
javascript:(function(){var w=550,h=420;window.open("https://twitter.com/intent/tweet?text="+encodeURIComponent(document.title)+"&url="+encodeURIComponent(location.href),"_blank","width="+w+",height="+h+",left="+(screen.width-w)/2+",top="+(screen.height-h)/2+",scrollbars=yes,resizable=yes,toolbar=no,location=yes")})()
```

### 新規タブでツイート画面を開くブックマークレット

```javascript
javascript:window.open("https://twitter.com/intent/tweet?text="+encodeURIComponent(document.title)+"&url="+encodeURIComponent(location.href))
```

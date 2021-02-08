---
title: "発動するとGoogle Calenderにコンテスト予定を登録してくれるブックマークレット"
date: 2021-02-08
tags:
- atcoder
- bookmarklet
- tech
- log
---

個人的に欲しかったので作った。
AtCoderのコンテストのトップページ
（[https://atcoder.jp/contests/arc112](https://atcoder.jp/contests/arc112)のような）
で発動するとコンテスト時間等をスクレイピングして、各情報を入力したGoogle Calendarの予定作成ページを開いてくれる。

AtCoderはいろんなツールが有志によって作られる世界的超大人気サービスのため、ひょっとしたら既にだれか作ってるかもしれない。
自分が軽くググったら似たようなことをやってくれるっぽいChrome拡張とGreasemonkeyユーザースクリプトが見つかった。
自分が作ったものはブックマークレットであり、クリックしたときだけ起動する。
使わないときもずっとプログラムが動いているのが好きではないという人は使うといいと思う。

### 完成品

<a href='javascript:(function(){var a=function(c){return c.getUTCFullYear()+(""+(101+c.getUTCMonth())).slice(1,3)+(""+(100+c.getUTCDate())).slice(1,3)+"T"+(""+(100+c.getUTCHours())).slice(1,3)+(""+(100+c.getUTCMinutes())).slice(1,3)+"00Z"},b=encodeURI,d=document.querySelector("#contest-nav-tabs > div > small.contest-duration"),e=b(a(new Date(d.querySelector("a:nth-child(1) > time").innerText)));a=b(a(new Date(d.querySelector("a:nth-child(2) > time").innerText)));d=b(document.title);var f=b(location.href);b=b(document.querySelector("#main-container > div.row > div:nth-child(2) > p").innerText);
window.open("https://www.google.com/calendar/render?action=TEMPLATE&text="+d+"&details="+b+"&location="+f+"&dates="+e+"%2F"+a,"_blank")})();'>
発動するとGoogle Calenderにコンテスト予定を登録してくれるブックマークレット
</a>（ブックマークバーにドラッグ&ドロップして登録）

```javascript
(function(){var a=function(c){return c.getUTCFullYear()+(""+(101+c.getUTCMonth())).slice(1,3)+(""+(100+c.getUTCDate())).slice(1,3)+"T"+(""+(100+c.getUTCHours())).slice(1,3)+(""+(100+c.getUTCMinutes())).slice(1,3)+"00Z"},b=encodeURI,d=document.querySelector("#contest-nav-tabs > div > small.contest-duration"),e=b(a(new Date(d.querySelector("a:nth-child(1) > time").innerText)));a=b(a(new Date(d.querySelector("a:nth-child(2) > time").innerText)));d=b(document.title);var f=b(location.href);b=b(document.querySelector("#main-container > div.row > div:nth-child(2) > p").innerText);window.open("https://www.google.com/calendar/render?action=TEMPLATE&text="+d+"&details="+b+"&location="+f+"&dates="+e+"%2F"+a,"_blank")})();
```

### 作り方

書いたコードを
[Closure Compiler](https://closure-compiler.appspot.com/home)
で小さくしてブックマークレット化した。
オリジナルのコードは以下である。
無駄に文字数を減らそうとした痕跡があるが、だいたいの努力は最適化に上書きされていて意味がなかったりする。

```javascript
(()=>{
  let F = (d) => d.getUTCFullYear()+(`${101+d.getUTCMonth()}`.slice(1,3))+(`${100+d.getUTCDate()}`.slice(1,3))+"T"+(`${100+d.getUTCHours()}`.slice(1,3))+(`${100+d.getUTCMinutes()}`.slice(1,3))+"00Z";
  let E = encodeURI;
  let d = document.querySelector("#contest-nav-tabs > div > small.contest-duration");
  let s = E(F(new Date(d.querySelector("a:nth-child(1) > time").innerText)));
  let e = E(F(new Date(d.querySelector("a:nth-child(2) > time").innerText)));
  let t = E(document.title);
  let l = E(location.href);
  let i = E(document.querySelector("#main-container > div.row > div:nth-child(2) > p").innerText);
  let u = `https://www.google.com/calendar/render?action=TEMPLATE&text=${t}&details=${i}&location=${l}&dates=${s}%2F${e}`;
  window.open(u,"_blank");
})();
```
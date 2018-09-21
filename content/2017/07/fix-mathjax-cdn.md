---
date: 2017-07-06
aliases:
- /2017/07/06/fix-mathjax-cdn.html
title: "MathJaxのCDNが警告を発しつつも使えてしまっていた"
tags:
- jekyll
- tech
- github
excerpt: "どうも数式表示のために読み込ませていたMathJaxのCDNである
`cdn.mathjax.org`が今年の4月30日でシャットダウンされていたようだ。
しかしどうもMathJaxは変わらず数式をレンダリングし続けてくれているように見える。"
image: 2017/07/06/twitter.png
---

生成されているHTMLを確認しようとChrome DevToolsを開いたところ、なにかWarningが出ていた。

![warning](/assets/2017/07/06/warning.png)

どうも数式表示のために読み込ませていたMathJaxのCDNである
`cdn.mathjax.org`が今年の4月30日でシャットダウンされていたようだ。

[MathJax CDN shutting down on April 30, 2017. Alternatives available.](https://www.mathjax.org/cdn-shutting-down/)

しかしどうもMathJaxは変わらず数式をレンダリングし続けてくれているように見える。
なぜだろう?と思って更に読み込んだところ上のページに追記があった。

> **Temporary redirect starting May 1, 2017**
>
> **[Updated 2017/04/10]**
>
> We will implement a temporary redirect on cdn.mathjax.org to redirect users to cdnjs.

いままでこのサイトで読み込まれていた[https://cdn.mathjax.org/mathjax/2.7-latest/MathJax.js](https://cdn.mathjax.org/mathjax/2.7-latest/MathJax.js)
を見てみると、なるほど確かにリダイレクト用に新しいCDNに`script`タグを置き換えるスクリプトになっている。

```javascript
(function () {
  var newMathJax = 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js';
  var oldMathJax = 'cdn.mathjax.org/mathjax/2.7-latest/MathJax.js';

  var replaceScript = function (script, src) {
    //
    //  Make redirected script
    //
    var newScript = document.createElement('script');
    newScript.src = newMathJax + src.replace(/.*?(\?|$)/, '$1');
    //
    //  Move onload and onerror handlers to new script
    //
    newScript.onload = script.onload; 
    newScript.onerror = script.onerror;
    script.onload = script.onerror = null;
    //
    //  Move any content (old-style configuration scripts)
    //
    while (script.firstChild) newScript.appendChild(script.firstChild);
    //
    //  Copy script id
    //
    if (script.id != null) newScript.id = script.id;
    //
    //  Replace original script with new one
    //
    script.parentNode.replaceChild(newScript, script);
    //
    //  Issue a console warning
    //
    console.warn('WARNING: cdn.mathjax.org has been retired. Check https://www.mathjax.org/cdn-shutting-down/ for migration tips.')
  }

  if (document.currentScript) {
    var script = document.currentScript;
    replaceScript(script, script.src);
  } else {
    //
    // Look for current script by searching for one with the right source
    //
    var n = oldMathJax.length;
    var scripts = document.getElementsByTagName('script');
    for (var i = 0; i < scripts.length; i++) {
      var script = scripts[i];
      var src = (script.src || '').replace(/.*?:\/\//,'');
      if (src.substr(0, n) === oldMathJax) {
        replaceScript(script, src);
        break;
      }
    }
  }
})();
```

MathJaxそのものよりもサイズが減って負荷軽減になっている……のだろうか?
自分みたいな他のCDNに移行するのを忘れている人にはありがたいが、おかげでDevToolsを開くまで異変に気が付かなかった。
ちゃんと動かなくなってくれたほうがかえって良かったかもしれない。

とにかく気づいたのでURLを別のCDNプロバイダのものに変更して対処。

![diff](/assets/2017/07/06/diff.png)

[Fix MathJax CDN · kotet/kotet.github.io@200f850](https://github.com/kotet/kotet.github.io/commit/200f8505a938263e4b3f38cf47f85c66751f4587)

無事にMathJaxの警告はなくなった。

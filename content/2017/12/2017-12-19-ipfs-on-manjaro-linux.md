---
date: 2017-12-19
title: "IPFS体験記10: `pacman -S go-ipfs`"
tags:
- ipfs
- tech
- ipfs体験記
excerpt: "いままでUbuntuを使っていたのだが、Manjaro Linuxに乗り換えて、こうして記事がかけるところまで環境構築ができた。"
---

[前回]({% include relative %}{% post_url 2017/11/2017-11-29-ipfs-wikipedia %})
:
[次回]({% include relative %}{% post_url 2017/12/2017-12-20-ipfs-soundcloud %})

---

いままで[Ubuntu](https://www.ubuntu.com/)を使っていたのだが、[Manjaro Linux](https://manjaro.org/)に乗り換えて、こうして記事がかけるところまで環境構築ができた。
ひとつ記事タイトルと関係ないことを言うと、vscodeのパッケージはvisual-studio-codeから[code](https://aur.archlinux.org/packages/code/)という名前に変わっており、
それをインストールすると`code-oss`が使えるようになる。

軽いし、いろいろ設定しやすいし、やたらと日本語のWikiが充実してるし、今の所とてもいい感じである。
慣れてきたら以前インストールすら満足にできなくて挫折した[Arch Linux](https://www.archlinux.org/)を使ってみたい。

ここから本題。
ArchのCommunityリポジトリにはIPFSのパッケージが存在する。

[Arch Linux JP Project - go-ipfs 0.4.13-1 (x86_64)](https://www.archlinux.jp/packages/community/x86_64/go-ipfs/)

なので`ipfs-update`とかを使うよりそれを使ったほうが簡単だと思う。

```console
$ sudo pacman -S go-ipfs
$ ipfs version
ipfs version 0.4.13
```

ちゃんと現時点の最新版である[`v0.4.13`](https://github.com/ipfs/go-ipfs/blob/v0.4.13/CHANGELOG.md)がインストールされた。

---

[前回]({% include relative %}{% post_url 2017/11/2017-11-29-ipfs-wikipedia %})
:
[次回]({% include relative %}{% post_url 2017/12/2017-12-20-ipfs-soundcloud %})
---
date: 2023-10-16
title: "20:curlは8.4.0からIPFSに対応している"
tags:
    - ipfs体験記
    - ipfs
    - tech
largeimage: /img/blog/2023/10/curl-release.png
---

curl 8.4.0がリリースされた。Arch Linuxとかなら既にパッケージマネージャからインストールできる。

[Release 8.4.0 · curl/curl](https://github.com/curl/curl/releases/tag/curl-8_4_0)

```console
$ curl --version
curl 8.4.0 (x86_64-pc-linux-gnu) libcurl/8.4.0 OpenSSL/3.1.3 zlib/1.3 brotli/1.1.0 zstd/1.5.5 libidn2/2.3.4 libpsl/0.21.2 (+libidn2/2.3.4) libssh2/1.11.0 nghttp2/1.57.0
Release-Date: 2023-10-11
Protocols: dict file ftp ftps gopher gophers http https imap imaps mqtt pop3 pop3s rtsp scp sftp smb smbs smtp smtps telnet tftp
Features: alt-svc AsynchDNS brotli GSS-API HSTS HTTP2 HTTPS-proxy IDN IPv6 Kerberos Largefile libz NTLM PSL SPNEGO SSL threadsafe TLS-SRP UnixSockets zstd
```

このリリースでは重大なヒープバッファオーバーフローの脆弱性が修正されている。
どうも「過去最悪」の脆弱性と呼ばれるほどのものだったらしい[^impress]ので、他のディストリビューションでも近いうちにアップデートされるだろう。

[^impress]: [「過去最悪」の脆弱性に対処した「curl 8.4.0」が公開 - 窓の杜](https://forest.watch.impress.co.jp/docs/news/1538153.html)

今回はそれとは関係なくこのリリースで入った新機能を試す。

### ipfsプロトコルのサポート

今回のリリースで、curlはipfsプロトコルをサポートした。
`ipfs://`や`ipns://`で始まるようなURLを認識してくれる。

ただし、curlがIPFSのノードになったわけではない。
ゲートウェイを利用してくれるようになっただけだ。
デフォルトでは`http://localhost:8080`を利用するので、ローカルでデーモンを動かしているなら特にオプションを指定しなくても動く。

他のゲートウェイを指定したい場合、`--ipfs-gateway`オプションを使う。

```console
$ curl --ipfs-gateway https://ipfs.io ipfs://QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
hello world
```

また、`IPFS_GATEWAY`環境変数や、設定ファイル`~/.ipfs/gateway`にゲートウェイのURLを書いておくと、それを利用してくれる。

```console
$ IPFS_GATEWAY="https://ipfs.io" curl ipfs://QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
hello world
$ echo "https://ipfs.io" > ~/.ipfs/gateway
# curl ipfs://QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
hello world
```

正直、IPFSデーモンが動いているなら`ipfs`コマンドも使えるだろうし、あまり意味がない気もする。
まあ、IPFSによるファイルの取得をcurlの統一されたインターフェースで行えることで何かしらのメリットがあるのかもしれない。

### 参考資料

- [curl - How To Use #--ipfs-gateway](https://curl.se/docs/manpage.html#--ipfs-gateway)
- [curl - Changes #8_4_0](https://curl.se/changes.html#8_4_0)

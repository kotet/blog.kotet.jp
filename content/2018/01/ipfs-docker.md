---
date: 2018-01-25
title: "14:IPFSとDocker"
tags:
- ipfs体験記
- ipfs
- tech
excerpt: go-ipfsはdockerコンテナを提供している。 たとえば以下のようにコマンド一つでIPFSデーモンが動かせる。
---

`go-ipfs`は[dockerコンテナを提供している](https://hub.docker.com/r/jbenet/go-ipfs/)。
たとえば以下のようにコマンド一つでIPFSデーモンが動かせる。

```
docker run -d --restart=always --name ipfs_host -v /home/kotet/Documents:/export -v /home/kotet/.ipfs/:/data/ipfs -p 4001:4001 -p 8080:8080 -p 5001:5001 ipfs/go-ipfs:latest
```

（パスなどを適切に置き換えて）これを実行するとIPFSデーモンが動き出し、ホストが再起動したときにも自動で起動される。
ローカルIPFSリポジトリが存在しない場合どうなるのかは調べていない。
`/export`は`ipfs add`などファイルを扱うときのルートだろうか。

デーモンのログは標準出力に出しているので`docker logs ipfs_host`で見られる。
また、コマンドも`docker exec ipfs_host ipfs version`のようにして実行できる。

ただ、ローカルゲートウェイやAPIサーバがホストで利用できず、ブラウザ拡張などが動かない。
他ノードとの接続等はちゃんとできているようなのでサーバとして使うぶんには問題ないが、自分はローカルゲートウェイを使うのでひとまず使用を断念した。
前にも同じような理由でDockerの利用を諦めた気がするので、IPFSの前にまずDockerの知識をつけなければならない……
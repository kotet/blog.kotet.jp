---
date: 2017-10-19
aliases:
- /2017/10/19/ipfs-config.html
title: "分散ファイルシステムIPFS体験記2:設定一覧"
tags:
- ipfs
- tech
- log
- ipfs体験記
image: 2017/10/19/twitter.png
excerpt: "今回はWebUI上で設定を確認する。 最初から最後まで全部読んでみたので、質的なものは別として量的に有用な日本語情報源として機能しそうな記事になったと思う。"
---

今回はWebUI上で設定を確認する。
最初から最後まで全部読んでみたので、質的なものは別として量的に有用な日本語情報源として機能しそうな記事になったと思う。

### Config

WebUI上ではさまざまな情報を見ることができる。
どうやらconfigファイルの編集もできるようなので今回はこれを使うが、もちろん好きなエディタで`~/.ipfs/config`を直接編集してもいいと思う。

![webui](/assets/2017/10/19/webui.png)

configはjson形式になっている。
ひょっとしたらjsonじゃないかもしれない、なんて考えて一応ドキュメントを見て確認してみる手間を省くためにも拡張子が付いているとありがたいのだが……
上から順番に確認していく。

#### `API`

```json
  "API": {
    "HTTPHeaders": null
  },
```

APIサーバのレスポンスヘッダを設定するものらしい。

#### `Addresses`

```json
  "Addresses": {
    "API": "/ip4/127.0.0.1/tcp/5001",
    "Announce": [],
    "Gateway": "/ip4/127.0.0.1/tcp/8080",
    "NoAnnounce": [],
    "Swarm": [
      "/ip4/0.0.0.0/tcp/4001",
      "/ip6/::/tcp/4001"
    ]
  }
```

ノードが待ち受けるアドレスを変更できる。

- `API`: ローカルAPIサーバのアドレス。WebUIと共有っぽい。
- `Gateway`: ローカルゲートウェイのアドレス。ipfs内のファイルにブラウザなどからアクセスするときに使える。
- `Swarm`: 他のノードと接続するためのアドレス。ポートを開かずにネットワークに貢献できるのかと心配していたが、
    [UPnP](https://ja.wikipedia.org/wiki/Universal_Plug_and_Play)
    のおかげで[大丈夫のようだ](https://discuss.ipfs.io/t/how-should-i-configure-my-firewall/471/3)。

ほかは[ドキュメント](https://github.com/ipfs/go-ipfs/blob/6beab668fddfc53995c17ec20df2264fe7d9bc1b/docs/config.md)に書かれていない。

#### `Bootstrap`

```json
  "Bootstrap": [
    "/dnsaddr/bootstrap.libp2p.io/ipfs/QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN",
    "/dnsaddr/bootstrap.libp2p.io/ipfs/QmQCU2EcMqAqQPR2i9bChDtGNJchTbq5TbXJJ16u19uLTa",
    "/dnsaddr/bootstrap.libp2p.io/ipfs/QmbLHAnMoJPWSCR5Zhtx6BHJX9KiKNN6tpvbUcqanj75Nb",
    "/dnsaddr/bootstrap.libp2p.io/ipfs/QmcZf59bWwK5XFi76CZX8cbJ4BhTzzA3gU1ZjYZcYW3dwt",
    "/ip4/104.131.131.82/tcp/4001/ipfs/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ",
    "/ip4/104.236.179.241/tcp/4001/ipfs/QmSoLPppuBtQSGwKDZT2M73ULpjvfd3aZ6ha4oFGL1KrGM",
    "/ip4/128.199.219.111/tcp/4001/ipfs/QmSoLSafTMBsPKadTEgaXctDQVcqN88CNLHXMkTNwMKPnu",
    "/ip4/104.236.76.40/tcp/4001/ipfs/QmSoLV4Bbm51jM9C4gDYZQ9Cy3U6aXMJDAbzgu2fzaDs64",
    "/ip4/178.62.158.247/tcp/4001/ipfs/QmSoLer265NRgSp2LA3dPaeykiS1J6DifTC88f5uVQKNAd",
    "/ip6/2604:a880:1:20::203:d001/tcp/4001/ipfs/QmSoLPppuBtQSGwKDZT2M73ULpjvfd3aZ6ha4oFGL1KrGM",
    "/ip6/2400:6180:0:d0::151:6001/tcp/4001/ipfs/QmSoLSafTMBsPKadTEgaXctDQVcqN88CNLHXMkTNwMKPnu",
    "/ip6/2604:a880:800:10::4a:5001/tcp/4001/ipfs/QmSoLV4Bbm51jM9C4gDYZQ9Cy3U6aXMJDAbzgu2fzaDs64",
    "/ip6/2a03:b0c0:0:1010::23:1001/tcp/4001/ipfs/QmSoLer265NRgSp2LA3dPaeykiS1J6DifTC88f5uVQKNAd"
  ]
```

起動時にネットワークに加わる入り口として接続するノードのアドレスたち。
これを自作ネットワークのノードに変えるとプライベートネットワークが作れるはず。

#### `Datastore`

```json
  "Datastore": {
    "BloomFilterSize": 0,
    "GCPeriod": "1h",
    "HashOnRead": false,
    "Spec": {
      "mounts": [
        {
          "child": {
            "path": "blocks",
            "shardFunc": "/repo/flatfs/shard/v1/next-to-last/2",
            "sync": true,
            "type": "flatfs"
          },
          "mountpoint": "/blocks",
          "prefix": "flatfs.datastore",
          "type": "measure"
        },
        {
          "child": {
            "compression": "none",
            "path": "datastore",
            "type": "levelds"
          },
          "mountpoint": "/",
          "prefix": "leveldb.datastore",
          "type": "measure"
        }
      ],
      "type": "mount"
    },
    "StorageGCWatermark": 90,
    "StorageMax": "10GB"
  }
```

ディスクの利用についての設定。

- `BloomFilterSize`: bloom filterのサイズをバイト数で設定するらしいが、デフォルト値は0、つまりこの機能は無効になっている。
- `GCPeriod`: GCの動作頻度を時間で設定。オートGCが有効の時のみ使われる値……とあるがオートGCは現在デフォルトで無効である。
- `HashOnRead`: データはブロックという単位で分割して扱われるのだが、たぶん`true`にするとディスクから読み込むときにブロックの検証を毎回行うようになる。
- `Spec`: データ構造を設定できるようだ。なんかいろいろ小難しいことをしたくなったらここを編集するんだろう。
- `StorageGCWatermark`: データストアの使用量が`StorageMax`の何%になったらGCを起動するか。これもオートGCが有効の時に使う値である。
- `StorageMax`: データストアの最大使用量。これを超えるデータストアへの書き込みは失敗する。
    このコンピュータはディスクが貧弱ですでに空き容量は10ギガバイトもないため、`2GB`に書き換えておく。

#### `Discovery`

```json
  "Discovery": {
    "MDNS": {
      "Enabled": true,
      "Interval": 10
    }
  }
```

"ipfs node discovery mechanisms"の設定……だそうだが、今の自分にはこれを理解する知識がない。

#### `Experimental`

```json
  "Experimental": {
    "FilestoreEnabled": false,
    "Libp2pStreamMounting": false,
    "ShardingEnabled": false
  }
```

その名の通り実験的機能を有効にできるのだろう。
多分開発者向け。

#### `Gateway`

```json
  "Gateway": {
    "HTTPHeaders": {
      "Access-Control-Allow-Headers": [
        "X-Requested-With",
        "Range"
      ],
      "Access-Control-Allow-Methods": [
        "GET"
      ],
      "Access-Control-Allow-Origin": [
        "*"
      ]
    },
    "PathPrefixes": [],
    "RootRedirect": "",
    "Writable": false
  }
```

先ほど少し触れたゲートウェイの設定。  
`ipfs cat /ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme`とコマンドを打つ代わりにブラウザで
`http://localhost:8080/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme`にアクセスできる。
gateway.ipfs.ioというパブリックゲートウェイがあるので、今誰かにIPFS上のファイルを見せようと思ったら
[`https://gateway.ipfs.io/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme`](https://gateway.ipfs.io/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme)
とするのが一番手軽ではあるが、このゲートウェイが封鎖してしまうとすべてリンク切れになってしまう。
どういうURLを貼るのが一番いいのだろうか？

- `HTTPHeaders`: ヘッダを設定できる。
- `PathPrefixes`: ドキュメントが完成していない。でもまあ名前通りなんだろう。
- `RootRedirect`: `/`をリダイレクトする。
- `Writeable`: ゲートウェイがwritableかそうでないかを設定できるらしいが、自分はその説明から意味を理解するだけの知識を持ち合わせていない。

#### `Identity`

```json
  "Identity": {
    "PeerID": "QmcEYwrw73GpQrxDBN9Zn4y2K9S6f1epQNGrttXa3ZRPeg"
  }
```

- `PeerID`: [PKI](https://ja.wikipedia.org/wiki/%E5%85%AC%E9%96%8B%E9%8D%B5%E5%9F%BA%E7%9B%A4) ID。
    IPFSではこのIDは実行時に鍵ペアから生成されるため、この設定値は人間などが確認するためにあるもので、書き換えても読まれない。

#### `Ipns`

```json
  "Ipns": {
    "RecordLifetime": "",
    "RepublishPeriod": "",
    "ResolveCacheSize": 128
  }
```

Inter-Planetary Naming Systemだそうだ。
IPFSではファイルのハッシュでデータにアクセス（ちょっとこの部分リズムが良くて声に出して読みたくなる）するため、ウェブサイト等変化するコンテンツを追うことができない。
IPNSはgitのブランチのように、PKI IDを変化するコンテンツの最新版へのポインタにできる。

- `RecordLifetime`: IPNSレコードの生存時間。デフォルトは24時間になっている。  
    ひょっとしてIPFS上でウェブサイトをホストするには定期的にIPNSレコードを送り続けなければならないのだろうか？
    ファイル自体は残り続けるとはいえ、自分の永遠に残るウェブサイト計画に暗雲が立ち込めてきた……
- `RepublishPeriod`: IPNSレコードをrepublishする頻度を指定する。デフォルトでは12時間。  
    やはりIPNSレコードは定期的に送り続けなければならないらしい。
    まあ考えてみたらサーバ無しでいくらでも利用できたらネットワークの負担がどんどん増えていってしまうので当然のことではある。
    それでも普通にWebサーバを運営するより低負荷なのだろう。
- `ResolveCacheSize`: キャッシュとして持つエントリの個数。

#### `Mounts`

```json
  "Mounts": {
    "FuseAllowOther": false,
    "IPFS": "/ipfs",
    "IPNS": "/ipns"
  }
```

FUSE mount pointの設定らしいが、まだよくわかっていない。

#### `Reprovider`

```json
  "Reprovider": {
    "Interval": "12h",
    "Strategy": "all"
  }
```

どんなコンテンツを持っているか他のノードに知らせる機能。

- `Interval`: Reprovidingの間隔。
    デフォルトでは12時間になっているが、自分のコンピュータは使う時しか動いていないので、IPFSネットワークに貢献するべく`0.5h`くらいに短くしておくことにした。
    [`ipfs name publish`](https://ipfs.io/docs/commands/#ipfs-name-publish)コマンドのパラメータと同じならこの表記は有効のはずである。
- `Strategy`: 何を知らせるかの戦略の設定。`all`、`pinned`、`roots`から選べるようだ。

#### `SupernodeRouting`

```json
  "SupernodeRouting": {
    "Servers": null
  }
```

~~ドキュメントに載っていない項目。
謎。~~
Deprecatedになった機能らしい。

#### `Swarm`

```json
  "Swarm": {
    "AddrFilters": null,
    "DisableBandwidthMetrics": false,
    "DisableNatPortMap": false,
    "DisableRelay": false,
    "EnableRelayHop": false
  }
```

P2P関連の設定。
ちょっとP2Pに関する知識が不足していて正確な理解ができない。

#### 以上

これでConfigのjsonは終わりである。
ドキュメントには`ConnMgr`というのがあったが、どうも見当たらない……と思ったらどうやら今の今まで自分の使っているのより先のバージョンのドキュメントを読んでいたようだ。
v0.4.11のドキュメントは[こちら](https://github.com/ipfs/go-ipfs/blob/v0.4.11/docs/config.md)である。
残念ながら前回気にしていた接続数の制限はその`ConnMgr`でできるようになるらしく、現バージョンではどうしようもない。
アップデートをのんびり待つのみである。

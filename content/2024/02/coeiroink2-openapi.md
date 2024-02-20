---
date: 2024-02-13
title: "COEIROINK（v2）をRustから使う"
tags:
    - windows
    - rust
    - tech
image: /img/blog/2024/02/coeiroink-cover.png
highlights:
    - rust
    - toml
    - powershell
---

COEIROINKは、個人制作の合成音声エンジンだ。
未調整でもわりといい感じに読んでくれるので、英語の音声を機械翻訳したものとか、単に長い記事とか、そういうテキストを読み上げさせて聞きたいと思った。
しかし、単にCOEIROINKのUIにテキストを貼り付けると、上手く行かないことがある。
改行がほとんどなかったりすることで、非常に長い文章の塊をひとつの音声として生成しようとしたりする。
あと、自分の環境ではGPU版が使えないので、リアルタイム生成すると喋り終わるまでに実際に喋っている時間の3倍くらいかかる。
そのため、
[SAPIforVOICEVOX](https://github.com/shigobu/SAPIForVOICEVOX)
のような、スクリーンリーダーでCOEIROINKを使うようなツールだと不満が残る。
そこで、雑に投げたテキストをCOEIROINKのAPIを使って音声にしてくれるツールを作ろうと思った。
v2になってからの情報が少ないし、OpenAPIを利用している情報はもっと少ないので記事を書くことにした。

## COEIROINK (v2) のAPI

COEIROINKは、かつてVOICEVOXとGUIを共有していたが、v2からは独自のGUIを持つようになった。
それに伴って、APIも変わっている。

APIドキュメントは、COEIROINKを起動すると、`http://localhost:50032/docs`で見ることができる。
見ての通りFastAPIで実装されているらしい。

![COEIROINKのAPIドキュメント。タイトルは"FastAPI"](/img/blog/2024/02/coeiroink-docs.png)

このAPIドキュメントは、OpenAPIという仕様に従って記述されたjsonファイルから生成されている。
ドキュメントの一番上に小さく貼られている`openapi.json`のリンクをクリックすると、その定義をダウンロードできる。
もちろんドキュメントページを読んで手動でリクエストを投げても良いのだが、このファイルを使ってクライアントライブラリを生成することができる。
そして、未知でドキュメントも少ないライブラリを使うならRustの強い型システムは頼りになる。

```sh
$ cargo init
```

## OpenAPIのクライアントライブラリを生成する

OpenAPIのクライアントライブラリを生成するツールはいくつかあるが、今回は
[OpenAPITools/openapi-generator](https://github.com/OpenAPITools/openapi-generator)
を使うことにした。
Rustだと
[progenitor](https://github.com/oxidecomputer/progenitor)
というツールもあるが、これはCOEIROINKが使っている`multipart/form-data`に対応していないようだった。

openapi-generatorのインストール方法はいろいろある。
今回は、npmでインストールすることにした。

```sh
$ npm install @openapitools/openapi-generator-cli -g
```

WSLからWindowsホストのサーバーにアクセスするのはちょっと面倒なので、今回のツールはWindowsで動かす。
openapi-generator-cliは、WSLにマウントされているWindowsのディレクトリで実行した。

```sh
$ pwd
/mnt/c/Users/kotet/Documents/coeiroink2-txt2wav
$ openapi-generator-cli generate -g rust-server -i openapi.json -o coeiroink2
```

これで、`coeiroink2`ディレクトリにRustのクレートが生成された。
サーバー用のコードとクライアント用のコードが生成されるが、今回はクライアント用のコードだけを使う。

```sh
$ tree -L 2
.
├── Cargo.toml
├── coeiroink2
│   ├── Cargo.toml
│   ├── README.md
│   ├── api
│   ├── docs
│   ├── examples
│   └── src
├── openapi.json
├── openapitools.json
└── src
    └── main.rs
```

## クライアントライブラリを使う

クライアントライブラリを使って、COEIROINKのAPIを叩く。
生成された`coeiroink2/examples`の例を元に書いてみる。

**Cargo.toml**

```toml
[package]
name = "coeiroink2-test"
version = "0.1.0"
edition = "2021"

[dependencies]
coeiroink2 = { path = "coeiroink2" }
swagger = { version = "6.1", features = ["serdejson", "server", "client", "tls", "tcp"] }
tokio = "1.36.0"
```

**src/main.rs**

```rust
use coeiroink2::ContextWrapperExt;
use swagger::{AuthData, ContextBuilder, EmptyContext, Push, XSpanIdString};
use tokio;

use std::io::Write;

type ClientContext = swagger::make_context_ty!(
    ContextBuilder,
    EmptyContext,
    Option<AuthData>,
    XSpanIdString
);

async fn async_main() {
    let context: ClientContext = swagger::make_context!(
        ContextBuilder,
        EmptyContext,
        None as Option<AuthData>,
        XSpanIdString::default(),
    );
    let client = Box::new(
        coeiroink2::Client::try_new_http("http://localhost:50032")
            .expect("failed to create client"),
    );
    let client: Box<dyn coeiroink2::ApiNoContext<ClientContext>> =
        Box::new(client.with_context(context));

    // 話者情報を取得。デフォルト話者・スタイルがあるので以下のコードで話者がいない場合の処理は省略している
    let coeiroink2::SpeakersV1SpeakersGetResponse::SuccessfulResponse(speakers) = client
        .speakers_v1_speakers_get()
        .await
        .expect("failed to retrieve speaker info");

    println!("using speaker: {} ({})", speakers[0].speaker_name, speakers[0].speaker_uuid);
    println!("using style: {} ({})", speakers[0].styles[0].style_name, speakers[0].styles[0].style_id);

    let response: coeiroink2::PredictV1PredictPostResponse = client
        .predict_v1_predict_post(coeiroink2::models::WavMakingParam {
            speaker_uuid: speakers[0].speaker_uuid.clone(),
            style_id: speakers[0].styles[0].style_id,
            text: "これはテスト音声です。".to_string(),
            prosody_detail: None,
            speed_scale: 1.0,
        })
        .await
        .expect("failed to predict speech");

    match response {
        coeiroink2::PredictV1PredictPostResponse::SuccessfulResponse(data) => {
            let data: Vec<u8> = data.0;
            // 返ってくるデータはwavファイルなのでそのままファイルに書き出す
            // 複数生成して繋げる場合にはデコードしてから繋げる必要がある
            let mut f = std::fs::File::create("output.wav").expect("failed to create file");
            f.write_all(&data).expect("failed to write to file");
            println!("output.wav created");
        }
        coeiroink2::PredictV1PredictPostResponse::ValidationError(err) => {
            eprintln!("validation error: {:?}", err.detail);
        }
    }
}

fn main() {
    let rt = tokio::runtime::Builder::new_current_thread()
        .enable_io()
        .enable_time()
        .build()
        .expect("failed to build tokio runtime");
    rt.block_on(async_main());
}
```

COEIROINKを起動した状態で、Windowsから実行すると、`output.wav`が生成される。

```powershell
PS > cargo run -q
using speaker: つくよみちゃん (3c37646f-3881-5374-2a83-149267990abc)
using style: れいせい (0)
output.wav created
```

## 作ったツール

以上のようにして作ったツールがcoeiroink2-txt2wavだ。

[kotet/coeiroink2-txt2wav: 長めのテキストをCOEIROINK (v2) に読ませるためのツール](https://github.com/kotet/coeiroink2-txt2wav)

ファイルをドラッグアンドドロップするとこのツールを呼び出して音声ファイルを作ってくれるバッチファイルも作った。
これでCOEIROINKを読み上げツールとして日常的に使いやすくなった。

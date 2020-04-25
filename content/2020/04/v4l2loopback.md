---
title: "v4l2loopbackで画面キャプチャをカメラ入力にする"
date: 2020-04-22
tags:
- linux
- tech
---

最後に記事を書いたのが2019年のまま4月下旬になってしまいました。
今日は「画面キャプチャ カメラ入力」でググって出てきてほしいと思った記事を書きます。
愛知県立大学はCOVID-19の影響により基本的にすべての活動をリモートで行うことになりました。
すべての活動が強制的にリモートになるとビデオ通話をする上でいろんな選択肢が欲しくなります。
今日は画面キャプチャをそのままカメラとして使いたいなと思いました。

### v4l2loopback

v4l2loopbackはダミーのビデオデバイスを作れるカーネルモジュールです。

[umlaeute/v4l2loopback: v4l2-loopback device](https://github.com/umlaeute/v4l2loopback)

このカーネルモジュールをロードするとループバックデバイス`/dev/videoX`が生えてきます。
それに何かを書き込むと、書き込んだデータストリームをカメラ入力として使えるようになります。

**Video for Linux 2**の略なので、4と2の間にあるのは数字の1ではなくアルファベットのLです。
間違えないようにしましょう（1敗）。
ブイフォーエルツーですよ！
気をつけて！

#### インストール

Arch Linuxでは[v4l2loopback-dkms](https://aur.archlinux.org/packages/v4l2loopback-dkms/)というAURパッケージが利用できます。
Ubuntuにも同名のパッケージが存在しますが、バージョンが古くてうまく動かなかったりするのでソースからインストールしましょう。

```console
$ sudo apt-get install build-essential libelf-dev linux-headers-$(uname -r) unzip
$ git clone https://github.com/umlaeute/v4l2loopback.git
$ cd v4l2loopback
$ make && sudo make install
$ sudo depmod -a
```

#### 設定

`/etc/modprobe.d/v4l2loopback.conf`にオプションを書きます。

```console
$ echo "options v4l2loopback video_nr=42 exclusive_caps=1" | sudo tee -a /etc/modprobe.d/v4l2loopback.conf
```

`video_nr`オプションで作られるループバックデバイスのIDを指定できます。
今回はてきとうに`42`にします。
`3,7,21,42`のように複数のデバイスを作ることもできます。

`exclusive_caps`はChrome等でデバイスを使えるようにするためのオプションです。

#### ロード

次に`/etc/modules-load.d/modules.conf`に`v4l2loopback`と書き足して、カーネルモジュールが自動的にロードされるようにします。

```console
$ echo v4l2loopback | sudo tee -a /etc/modules-load.d/modules.conf
```

`systemd-modules-load.service`を再起動することでカーネルモジュールが読み込まれます。
これ以降は起動時に自動的にカーネルモジュールがロードされるようになります。

```console
$ sudo systemctl restart systemd-modules-load.service
```

新しく`/dev/video42`が生えているのがわかります。

```console
$ ls /dev/video*
/dev/video0  /dev/video42
```

### ffmpeg

上で作った`/dev/video42`に映像を流し込んでいきます。
いろいろ方法があるようですがffmpegを使います。
ffmpegのインストールは以下のコマンドでできます。

```console
$ sudo apt install ffmpeg
```

以下のコマンドで画面キャプチャのビデオストリームの色空間を変換し、`/dev/video42`に出力します。
`-s 1920x1080`にはキャプチャしたい領域のサイズ、`-i $DISPLAY+0,0`にはキャプチャ領域のオフセットを指定します。
たとえば画面左上から右に123px、下に456pxの場合`-i $DISPLAY+123,456`のようになります。
使っている画面に応じて適宜書き換えてください。

```console
$ ffmpeg -f x11grab -s 1920x1080 -i $DISPLAY+0,0 -vf format=pix_fmts=yuv420p -f v4l2 /dev/video42
```

使うサービスによっては勝手に映像をクリッピングすることがあるので、
画面全体ではなくマウスを追いかけるような映像にする場合は以下のようにします。

```console
ffmpeg -f x11grab -follow_mouse centered -video_size vga -i $DISPLAY -vf format=pix_fmts=yuv420p -f v4l2 /dev/video42
```

もちろんスクリーンキャスト以外の映像も送れるので、ffmpegわかるマンはいろいろ遊んでみましょう。

### 結果

上のコマンドが走っている間、ChromeでなにかしらのWebビデオチャットを開いたりすると`Dummy video device`という名前のカメラが増えています。

![](/img/blog/2020/04/v4l2loopback.jpg)
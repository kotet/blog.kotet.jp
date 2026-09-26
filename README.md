# blog.kotet.jp

`make` でターゲットの一覧を表示できる。

新規記事

```bash
make new-post SLUG=filename
```

`content/<年>/<月>/filename.md` に作成される。`SLUG` を省略すると入力を求められる。
過去の日付に置きたい場合は `DATE=2026-09-01` を渡す。

タグ追加

```bash
make new-tag TAG=web_assembly
```

`TAG` を省略すると入力を求められる。タグ名は英小文字のアンダースコア区切りのみ受け付ける。
各言語のタグページを作成してパスを表示するので、タイトルを確かめて説明文を追記する。
記事から参照されていないタグページは `make check-tags` が失敗させるため、
タグを使う記事と合わせてコミットする。

画像追加

```bash
make add-image INPUT=image.png
```

`INPUT` を省略すると入力を求められる。`NAME` で保存名、`DATE` で年月を指定できる。

タグの表記検査

```bash
make check-tags
```

タグの元データが英語小文字のアンダースコア区切りか、タグページが各言語分そろっているかなどを検査する。

リンク切れ検査

```bash
make check-links
```

サイトを `tmp/` にビルドし、lychee でサイト内のリンク切れ(存在しないページ、画像、`#` のアンカー)を検査する。
外部サイトへのリンクは検査しない。lychee は devcontainer に入っている。設定は `lychee.toml`。

`make lint` で上の2つの検査をまとめて実行する。CIでも `make lint` が動く。

ビルドとローカルサーバ

```bash
make build
make serve
```

内部リンク

```markdown
[リンクテキスト](/{year}/{month}/{slug})
```

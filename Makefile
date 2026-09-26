# 記事作成、画像追加、検査、ビルドのエントリポイント。
# 引数を取るターゲットは、変数が未指定なら対話的に入力を求める。

# read -p を使うため sh ではなく bash を指定する
SHELL := /bin/bash

HUGO ?= hugo
LYCHEE ?= lychee

# リンク検査のためにサイトを書き出す先。lychee の root_dir と remap は絶対パスを要求するので両方用意する
LINK_CHECK_SITE_DIR := tmp/link-check-site
LINK_CHECK_SITE_ABS_DIR := $(CURDIR)/$(LINK_CHECK_SITE_DIR)

# テンプレートが .Permalink などで出す自サイトの絶対 URL。hugo.yaml の baseURL に合わせる
SITE_URL_PATTERN := https://blog\.kotet\.jp/(.*)

# 記事の置き場所は content/<年>/<月>/ 。DATE を渡すとその日付の年月になる
DATE_PATH := $(shell date +%Y/%m $(if $(DATE),--date="$(DATE)"))

# タグの元データとして許す形式。layouts/partials/lint/tags.html の検査1と同じもの
TAG_PATTERN := ^[a-z0-9]+(_[a-z0-9]+)*$$

# タグ1つにつき作成するページの名前を hugo の設定から導く。
# 既定言語だけが _index.md で、他の言語は _index.<言語コード>.md になる。
TAG_INDEX_FILES_QUERY := .defaultcontentlanguage as $$d | .languages | keys[] | if . == $$d then "_index.md" else "_index.\(.).md" end

.DEFAULT_GOAL := help
.PHONY: help new-post new-tag add-image check-tags check-links lint build serve

help: ## 使用できるターゲットを一覧表示する
	@awk -F':.*## ' '/^[a-z][a-z-]*:.*## /{printf "  make %-12s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

new-post: ## 新規記事を作成する (SLUG=ファイル名, DATE=日付)
	@slug="$(SLUG)"; \
	if [ -z "$$slug" ]; then \
		read -r -p "記事のスラッグ (例: my-first-post): " slug; \
	fi; \
	if [ -z "$$slug" ]; then \
		printf '記事のスラッグが指定されていません\n' >&2; \
		exit 1; \
	fi; \
	$(HUGO) new "content/$(DATE_PATH)/$$slug.md"

new-tag: ## タグページを各言語分作成する (TAG=タグ名)
	@tag="$(TAG)"; \
	if [ -z "$$tag" ]; then \
		read -r -p "タグ名 (英小文字のアンダースコア区切り): " tag; \
	fi; \
	if [ -z "$$tag" ]; then \
		printf 'タグ名が指定されていません\n' >&2; \
		exit 1; \
	fi; \
	if [[ ! "$$tag" =~ $(TAG_PATTERN) ]]; then \
		printf 'タグ名 "%s" が英小文字とアンダースコア区切りになっていません\n' "$$tag" >&2; \
		exit 1; \
	fi; \
	if [ -e "content/tags/$$tag" ]; then \
		printf 'content/tags/%s はすでにあります\n' "$$tag" >&2; \
		exit 1; \
	fi; \
	indexes="$$($(HUGO) config --format json | jq -r '$(TAG_INDEX_FILES_QUERY)')"; \
	if [ -z "$$indexes" ]; then \
		printf 'hugo の設定から言語を読み取れませんでした\n' >&2; \
		exit 1; \
	fi; \
	printf 'タグページを作成しました。タイトルを確かめて説明文を追記してください:\n'; \
	for index in $$indexes; do \
		$(HUGO) new "tags/$$tag/$$index" >/dev/null; \
		printf '  content/tags/%s/%s\n' "$$tag" "$$index"; \
	done

add-image: ## 画像を追加する (INPUT=画像ファイル, NAME=保存名, DATE=日付)
	@input="$(INPUT)"; \
	if [ -z "$$input" ]; then \
		read -r -p "画像ファイルのパス: " input; \
	fi; \
	if [ -z "$$input" ]; then \
		printf '画像ファイルが指定されていません\n' >&2; \
		exit 1; \
	fi; \
	./add-image.sh $(if $(DATE),-d "$(DATE)") $(if $(NAME),-n "$(NAME)") "$$input"

# --quiet を付けると errorf の内容まで隠れてしまうため、あえて付けない
check-tags: ## タグの表記を検査する
	HUGO_PARAMS_LINTTAGS=true $(HUGO) --renderToMemory

# 公開時と同じく未来日付の記事も含める。
# 前回の出力が残っていると消えたページへのリンクを見逃すので、--cleanDestinationDir で掃除する。
# lychee の他の設定は lychee.toml にある。ここで渡すのは絶対パスが必要なものだけ。
#   --root-dir: /2018/12/slug のような / 始まりのリンクを書き出したサイトの中で解決する
#   --remap:    自サイトの絶対 URL を書き出したサイトのファイルに読み替え、外部リンク扱いにさせない
# baseURL を / に差し替える方法は、.Site.BaseURL と画像パスを連結するテンプレートが
# //img/... を出してしまうため使わない。
check-links: ## サイト内のリンク切れを検査する
	$(HUGO) --buildFuture --cleanDestinationDir --destination $(LINK_CHECK_SITE_DIR)
	$(LYCHEE) --root-dir $(LINK_CHECK_SITE_ABS_DIR) --remap '$(SITE_URL_PATTERN) file://$(LINK_CHECK_SITE_ABS_DIR)/$$1' $(LINK_CHECK_SITE_DIR)

lint: check-tags check-links ## タグの表記とリンク切れを検査する

build: ## 公開用にサイトをビルドする
	$(HUGO) --minify

serve: ## ローカルサーバを起動する
	$(HUGO) server

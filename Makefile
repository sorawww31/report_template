# コンパイル対象（拡張子なし）。別ファイルを組む場合は例:
#   make MAIN=paper1 (paper1.tex → paper1.pdf)
MAIN    ?= paper1

# docker compose の実行サービス名
SERVICE ?= latex

# eps→pdf 変換のため shell-escape を有効化した latexmk を使用
LATEXMK = latexmk -pdf -shell-escape -bibtex -interaction=nonstopmode -halt-on-error

# ホスト側の UID/GID を渡してファイル所有権を保つ
DC = HOST_UID=$(shell id -u) HOST_GID=$(shell id -g) docker compose

.PHONY: help build pdf watch shell bibtex clean distclean

help: ## このヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

build: ## Docker イメージをビルド
	$(DC) build

pdf: ## PDF をコンパイル（$(MAIN).tex → $(MAIN).pdf）
	$(DC) run --rm $(SERVICE) $(LATEXMK) $(MAIN).tex

watch: ## ファイル変更を監視して自動再コンパイル
	$(DC) run --rm $(SERVICE) $(LATEXMK) -pvc -view=none $(MAIN).tex

shell: ## コンテナ内で対話シェルを起動
	$(DC) run --rm $(SERVICE) /bin/bash

clean: ## 中間ファイルを削除（PDF は残す）
	$(DC) run --rm $(SERVICE) latexmk -c $(MAIN).tex

distclean: ## 中間ファイル＋PDF を削除
	$(DC) run --rm $(SERVICE) latexmk -C $(MAIN).tex

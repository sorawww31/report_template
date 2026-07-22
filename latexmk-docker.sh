#!/usr/bin/env bash
# ==========================================================================
# エディタ（LaTeX Workshop）から Docker 経由で latexmk を実行するラッパー
#   使い方: ./latexmk-docker.sh <対象ファイル（拡張子なし可）>
#   ホストの UID/GID を渡し、生成ファイルの所有権をホスト側に合わせる
# ==========================================================================
set -euo pipefail

# このスクリプトのあるディレクトリ（＝プロジェクトルート）へ移動
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec env HOST_UID="$(id -u)" HOST_GID="$(id -g)" \
  docker compose run --rm latex \
  latexmk -pdf -shell-escape -bibtex \
  -synctex=1 -interaction=nonstopmode -file-line-error -halt-on-error \
  "$@"

#!/usr/bin/env bash
# ==========================================================================
# VS Code LaTeX Workshop 用 latexindent ラッパー
#   目的: ホストではなく Docker の TeX Live 環境で LaTeX を整形する。
#   理由: ビルド環境と整形環境をそろえ、ホストへの追加インストールを避ける。
# ==========================================================================
set -euo pipefail

# このスクリプトのあるディレクトリ（＝プロジェクトルート）へ移動
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -eq 0 ]; then
  echo "usage: $0 <latexindent args...>" >&2
  exit 2
fi

host_root="$(pwd)"
mount_index=0
mount_args=()
container_args=()
mapped_arg=""

map_arg() {
  local arg="$1"
  local abs_path=""

  mapped_arg="$arg"
  if [ ! -e "$arg" ]; then
    return
  fi

  case "$arg" in
    /*) abs_path="$arg" ;;
    *) abs_path="$host_root/$arg" ;;
  esac

  case "$abs_path" in
    "$host_root")
      mapped_arg="/workspace"
      ;;
    "$host_root"/*)
      mapped_arg="/workspace/${abs_path#"$host_root"/}"
      ;;
    *)
      # LaTeX Workshop がワークスペース外に一時ファイルを作る場合だけ、
      # その親ディレクトリを読み取り専用で追加マウントする。
      local parent_dir
      local base_name
      local mount_point
      parent_dir="$(dirname "$abs_path")"
      base_name="$(basename "$abs_path")"
      mount_point="/latexindent-input-${mount_index}"
      mount_index=$((mount_index + 1))
      mount_args+=("-v" "${parent_dir}:${mount_point}:ro")
      mapped_arg="${mount_point}/${base_name}"
      ;;
  esac
}

for arg in "$@"; do
  map_arg "$arg"
  container_args+=("$mapped_arg")
done

exec env HOST_UID="$(id -u)" HOST_GID="$(id -g)" \
  docker compose run --rm -q -T --no-deps "${mount_args[@]}" latex \
  latexindent -c /tmp/ "${container_args[@]}"

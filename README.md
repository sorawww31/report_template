# LaTeX Report Template

このリポジトリは、Docker 上の TeX Live で LaTeX 文書をビルドするためのテンプレートリポジトリです。  
派生リポジトリごとに本文の `.tex` ファイルを追加し、同じビルド環境を安全に再利用することを目的にしています。

## 想定用途

- LaTeX の実行環境をホストに直接入れず、Docker で固定して使う
- `latexmk` による PDF ビルド、監視ビルド、クリーンを `make` から実行する
- VS Code LaTeX Workshop からも Docker 経由でビルドと整形を行う
- PDF はルート直下に出し、中間ファイルは `build/` 以下にまとめる

## 必要なもの

- Docker
- Docker Compose v2
- `make`
- VS Code と LaTeX Workshop 拡張機能、必要な場合のみ

## テンプレートから始める手順

1. GitHub の `Use this template` から新しいリポジトリを作成します。
2. 新しいリポジトリを clone します。
3. 本文となる `.tex` ファイルと、必要な `.bib`、画像、スタイルファイルを追加します。
4. `Makefile` の `MAIN` を本文ファイル名に合わせるか、実行時に `MAIN` を指定します。
5. PDF をビルドします。

```bash
make build
make pdf
```

既定の `MAIN` は `paper1` です。  
別名のファイルを使う場合は、拡張子なしで指定してください。

```bash
make MAIN=paper pdf
```

この例では `paper.tex` をビルドし、PDF は `paper.pdf` に出力されます。

## よく使うコマンド

```bash
make help
```

利用できる `make` ターゲットを表示します。

```bash
make build
```

Docker イメージをビルドします。

```bash
make pdf
```

`$(MAIN).tex` を PDF にコンパイルします。

```bash
make MAIN=paper pdf
```

`paper.tex` のように、既定以外の本文ファイルを指定してビルドします。

```bash
make watch
```

ファイル変更を監視して自動再ビルドします。

```bash
make clean
```

中間ファイルを削除します。PDF は残します。

```bash
make distclean
```

中間ファイルと PDF を削除します。

```bash
make shell
```

LaTeX コンテナ内で対話シェルを開きます。

## VS Code で使う場合

`.vscode/settings.json` は LaTeX Workshop が Docker 経由で動くように設定されています。

- ビルドは `./latexmk-docker.sh` 経由で実行します。
- 整形は `./latexindent-docker.sh` 経由で実行します。
- 保存時の自動ビルドと保存時整形が有効です。

派生リポジトリで VS Code を使う場合は、LaTeX Workshop 拡張機能を入れてから `.tex` ファイルを開いてください。

## 出力先

`.latexmkrc` により、PDF はルート直下、中間ファイルは `build/` 以下に出力されます。  
`build/` とルート直下の `*.pdf` は `.gitignore` で除外しているため、生成物は通常 commit しません。

## ファイル構成

```text
.
├── Dockerfile              # TeX Live ベースのビルド環境
├── compose.yaml            # LaTeX 用 Docker Compose 設定
├── Makefile                # PDF ビルド、監視、クリーン用コマンド
├── latexmk-docker.sh       # VS Code などから latexmk を呼ぶラッパー
├── latexindent-docker.sh   # VS Code などから latexindent を呼ぶラッパー
├── .latexmkrc              # latexmk の出力先設定
├── .gitignore              # LaTeX 生成物とOSファイルの除外設定
└── .vscode/settings.json   # LaTeX Workshop 用設定
```

## テンプレート運用時の注意

- 本文の `.tex` や提出先固有のファイルは、原則として派生リポジトリ側で追加します。
- テンプレート側には、共通して使うビルド環境、エディタ設定、最小限の運用メモだけを置きます。
- PDF、ログ、中間ファイルなどの生成物は commit しません。
- PDF 形式の図表を管理したい場合は、`figures/` などのサブディレクトリに置くか、`.gitignore` を派生リポジトリ側で調整します。
- 秘密情報、個人のローカルパス、特定プロジェクトだけの設定は入れません。
- 既定の `MAIN` を変える場合は、README の例も合わせて更新します。

## トラブルシュート

### `$(MAIN).tex` が見つからない

`Makefile` の `MAIN` と実際の `.tex` ファイル名が一致しているか確認してください。  
一時的に指定する場合は、次のように実行します。

```bash
make MAIN=paper pdf
```

### Docker の権限で生成ファイルの所有者がずれる

`Makefile` とラッパースクリプトは `HOST_UID` と `HOST_GID` を渡す設定です。  
問題が続く場合は、Docker Desktop や WSL のファイル共有設定を確認してください。

### VS Code からビルドできない

LaTeX Workshop 拡張機能が入っていること、Docker が起動していること、リポジトリルートを VS Code で開いていることを確認してください。

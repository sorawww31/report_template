# texlive/texlive をベースにした LaTeX コンパイル環境
# https://hub.docker.com/r/texlive/texlive
FROM texlive/texlive:latest

# 作業ディレクトリ（compose 側で volume マウントする）
WORKDIR /workspace

# latexmk / bibtex / epstopdf などは texlive イメージに同梱済み
CMD ["/bin/bash"]

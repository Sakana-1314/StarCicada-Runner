#!/usr/bin/env bash
# 计算下一个上传版本号：vYYYY.MM.DD-hotfix.NN
# - 以 CST（亚洲上海）取日期；
# - 读当前仓库已有的同日 tag，最后一段两位自增；没有则从 .01 开始。
# 必须在 StarCicada 的检出目录内执行。
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null

today="$(TZ=Asia/Shanghai date +%Y.%m.%d)"
latest="$(git tag --list "v${today}-hotfix.*" --sort=-v:refname | head -n 1 || true)"

if [ -n "$latest" ]; then
  number=$((10#${latest##*.} + 1))
else
  number=1
fi

printf 'v%s-hotfix.%02d\n' "$today" "$number"

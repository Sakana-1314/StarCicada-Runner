# StarCicada-Runner

星蝉CX 小程序的自动化上传运行器。源码在 [`Sakana-1314/StarCicada`](https://github.com/Sakana-1314/StarCicada)，本仓库只放工作流与脚本。

## 工作流

`.github/workflows/upload-miniprogram.yml`

- **自动**：StarCicada 的 `trigger-runner.yml` 在 `main` push / PR / 手动触发时，通过 `repository_dispatch` 派发 `starcicada_miniprogram`。
  - push：版本号 `vYYYY.MM.DD-hotfix.NN`（同日自增，成功上传后打 tag），robot 1，描述取提交标题。
  - PR：版本号 `PR #<编号>`，robot 21–30，描述固定。
- **手动**：本仓库 Actions → 小程序代码上传 → Run workflow，可指定版本号、robot 与描述。

上传目标为**开发版**，不会提交审核。

## 必需的仓库 Secret

本仓库（StarCicada-Runner）：

| Secret | 说明 |
| --- | --- |
| `PAT` | 有 `Sakana-1314/StarCicada` 读写权限的 GitHub Token（签出代码、回写 commit status、推送版本 tag） |
| `MINIPROGRAM_PRIVATE_KEY` | 微信小程序代码上传密钥（PEM 原文） |

StarCicada 仓库：

| Secret | 说明 |
| --- | --- |
| `RUNNER_PAT` | 有权向本仓库发送 `repository_dispatch` 的 GitHub Token |

建议使用 Fine-grained PAT，权限最小化：StarCicada 需要 `Contents: Read and write`、`Commit statuses: Write`；本仓库需要 `Actions: Read`。

## 密钥安全

- 上传密钥只在运行时从 Secret 写到 `$RUNNER_TEMP/starcicada-secret/private.key`，**从不进入代码目录**，也不会被打进代码包。
- 上传前有硬校验：
  1. StarCicada 工作区不得存在 `*.key`、`*.pem`、`project.private.config.json`；
  2. `git ls-files` 不得包含 `.private/`、`*.key`、`*.pem`；
  3. 密钥真实路径不得位于 `$GITHUB_WORKSPACE` 或代码检出目录内。
- `miniprogram-ci` 上传时再通过 `--pi` 忽略 `.private/**`、`.git/**`、`node_modules/**`、`project.private.config.json` 等。
- 本项目没有「先打包成 zip 再上传」的步骤，避免把临时文件带进包。

## 版本号

`scripts/next-version.sh`：按 CST 日期读 StarCicada 的 `vYYYY.MM.DD-hotfix.NN` tag，最后两位自增；没有则 `.01`。上传成功后才打 tag，失败不会占用版本号。

## 本地验证

```bash
bash -n scripts/next-version.sh
# 在 StarCicada 检出目录内
TZ=Asia/Shanghai bash /path/to/scripts/next-version.sh
```

# StarCicada-Runner

星蝉CX 小程序的自动化上传运行器。源码在 [Sakana-1314/StarCicada](https://github.com/Sakana-1314/StarCicada)，本仓库只放工作流与脚本。

## 工作流

[`.github/workflows/upload-miniprogram.yml`](.github/workflows/upload-miniprogram.yml)

- 自动：StarCicada 的 `trigger-runner.yml` 在 push main / PR / 手动触发时派发 `repository_dispatch`。
- 手动：本仓库 Actions → 小程序代码上传 → Run workflow。
- 每次运行都会：`npm ci` → `npm run build:npm`（重新构建 `miniprogram_npm`）→ 校验 → 注入版本号 → 上传开发版。
- 版本号：push 为 `vYYYY.MM.DD-hotfix.NN`（成功后才打 tag）；PR 为 `PR #<编号>`。
- 上传目标为开发版，不提交审核。

## Secrets

本仓库：

| Secret | 说明 |
| --- | --- |
| `PAT` | 有 StarCicada 读写权限的 GitHub Token（签出、回写 commit status、推 tag） |
| `MINIPROGRAM_PRIVATE_KEY` | 微信小程序代码上传密钥（PEM 原文） |

StarCicada：

| Secret | 说明 |
| --- | --- |
| `RUNNER_PAT` | 有权向本仓库发 `repository_dispatch` 的 Token |

建议 Fine-grained PAT：StarCicada 需要 `Contents: Read and write`、`Commit statuses: Write`；本仓库需要 `Actions: Read`。

## 微信侧前置条件

上传密钥的 **IP 白名单**必须允许 Runner 出口 IP。GitHub 托管 Runner IP 不固定，建议关闭白名单；必须保留时，使用固定 IP 的自托管 Runner，并设置本仓库变量 `RUNNER_LABEL`（如 `self-hosted`）。

未配置时上传报 `invalid ip: <IP>`。

## 密钥安全

- 密钥只在运行时从 Secret 写到 `$RUNNER_TEMP/starcicada-secret/private.key`，不进入代码目录。
- 上传前校验：工作区不得有 `*.key` / `*.pem` / `project.private.config.json`；`git ls-files` 不得包含 `.private/`、`*.key`、`*.pem`；密钥路径不得位于代码目录。
- `miniprogram-ci --pi` 再忽略 `.private/**`、`.git/**`、`node_modules/**` 等。
- 没有「先打 zip 再上传」的步骤。

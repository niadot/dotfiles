# WSL 環境のコマンド

この環境は Nix と Home Manager で管理している。以下のコマンドを用途に応じて使う。
代替コマンドは完全互換ではないため、記載した例外では元のコマンドを使う。

## ファイルと検索

| 元のコマンド | 推奨コマンド | 使い分け |
| --- | --- | --- |
| `grep` | `rg` | 通常のテキスト検索と再帰検索には `rg` を使う。POSIX互換の挙動が必要なら `grep` を使う。 |
| `find` | `fd` | 名前や種類による単純なファイル検索には `fd` を使う。複雑な述語や `-exec` が必要なら `find` を使う。 |
| `cat` | `bat` | 人が内容を読むときは `bat` を使う。生データ、パイプ、連結には `cat` を使う。 |
| `ls` | `eza` | 対話的な一覧表示には `eza` を使う。スクリプトでは `ls` の出力を解析しない。 |
| `tree` | `eza --tree` | ツリー表示には `eza --tree` または `lt` を使う。 |

`eza` のエイリアスは次のとおり。

| エイリアス | 展開 |
| --- | --- |
| `ls` | `eza` |
| `ll` | `eza -l --git` |
| `la` | `eza -la --git` |
| `lt` | `eza --tree` |
| `l` | `eza -1` |

`fzf` は対話的な絞り込みに使う。通常入力と `Ctrl-T` のファイル検索、`Alt-C` のディレクトリ検索には `fd` が設定されている。`Ctrl-R` はコマンド履歴検索に使う。

`zoxide` の `z` は履歴を使ったディレクトリ移動、`zi` は対話的な移動に使う。正確な相対・絶対パスを指定するときやスクリプトでは `cd` を使う。

## Git と GitHub

| コマンド | 用途 |
| --- | --- |
| `git` | Git操作。diffとログの表示には自動的に`delta`が使われる。 |
| `gs` | `git status -sb` の短縮形。 |
| `gh` | GitHubのIssue、Pull Request、リリース、API操作。 |
| `ghq` | `~/ghq` 配下のリポジトリ取得と管理。 |
| `lazygit` | Gitを対話的に操作するTUI。 |

WSLではGitのSSH接続にWindows側の`ssh.exe`と1Password SSH agentを使う。

## Nix と開発環境

| コマンド | 用途 |
| --- | --- |
| `hms` | 現在のWSL用Home Manager構成を適用する。 |
| `hmu` | リモートと同期し、flake inputsを更新・適用して日付単位でコミット・pushする。 |
| `nix flake check` | WSL/Linux構成とflake outputsを検証する。 |
| `nix fmt` | Nixファイルを整形する。 |
| `direnv` | ディレクトリ単位で環境を読み込む。Nix環境にはnix-direnvを使う。 |
| `devenv` | プロジェクト固有の開発環境を定義・起動する。自動起動はdirenv経由を優先する。 |

JavaScript関連では、通常のNode.js環境に`node`、`npm`、`npx`を使い、pnpmプロジェクトには`pnpm`、Bunプロジェクトには`bun`を使う。プロジェクトが指定するパッケージマネージャーとlockfileを優先する。

Python関連では、単体スクリプトに`python`または`python3`を使う。どちらもHome Managerが導入する同じPythonを指す。プロジェクトの仮想環境と依存関係には`uv sync`と`uv run`を使い、グローバル環境へ`pip install`しない。NixのdevShellがあるプロジェクトでは、そのdevShellが提供するPythonとuvを優先する。

## データ、編集、セッション

| コマンド | 用途 |
| --- | --- |
| `jq` | JSONの抽出、変換、整形。 |
| `curl` | HTTPリクエストとダウンロード。 |
| `nvim` | 既定のエディタ。`EDITOR`と`VISUAL`に設定されている。 |
| `tmux` | 長時間動かす処理や複数シェルの管理。 |

## 秘密情報とAI CLI

| コマンド | 用途 |
| --- | --- |
| `op` | 1Passwordから秘密情報を読む。`op run`、`op read`、`op inject`を使い、秘密をNix設定やリポジトリへ書かない。 |
| `claude` | Claude Codeを起動する。 |
| `codex` | Codex CLIを起動する。 |
| `opencode` | OpenCodeを起動する。 |
| `sks` | `skills/Skillfile`にある未導入スキルをインストールする。 |
| `sku` | 導入済みスキルを更新する。 |

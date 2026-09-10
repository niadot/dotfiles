# dotfiles

Nix Home Manager による個人用 dotfiles。
WSL2 / Ubuntu / macOS (Apple Silicon) で同じ CLI 環境を再現する。

## セットアップ

```bash
git clone git@github.com:niadot/dotfiles.git ~/ghq/github.com/niadot/dotfiles
nix run home-manager -- switch \
  --flake ~/ghq/github.com/niadot/dotfiles#nia@wsl
```

構成名は環境に応じて `nia@wsl` / `nia@linux` / `nia@mac` を指定する。
以降は `~/.config/home-manager` が張られるので `hms` だけでよい。

## 独自コマンド

`shell/common.sh` で定義し、Home Manager が生成する bash / zsh の設定へ
埋め込んでいるシェル関数。

### `hms` — 構成を適用

```bash
hms                    # 現ホストの構成を適用
hms --dry-run          # 追加引数は home-manager にそのまま渡る
```

`home-manager switch -b backup --flake <設定>#$HM_TARGET` を実行する。
`HM_TARGET` は `hosts/*.nix` が設定するので、どのマシンでも `hms` だけでよい。
未設定なら実行せずエラーを返す。

### `hmu` — 更新して適用

```bash
hmu
```

`nix flake update` で `flake.lock` を更新してから `hms` を呼ぶ。
更新に失敗した場合は適用しない。

### `sks` — スキルを導入

```bash
sks
```

`Skillfile` を 1 行ずつ読み、`~/.agents/skills/<name>` が無いものだけ
`npx skills add` で導入する。空行と `#` 始まりは無視する。
導入済みは `skip:` と表示してスキップするため、何度実行してもよい。

### `sku` — スキルを更新

```bash
sku                    # 導入済みを全て更新
sku find-skills        # 追加引数は skills にそのまま渡る
```

`npx skills update -g` を実行する。`Skillfile` は参照せず、実際に
入っているものを対象にする。

## スキル

`skills/` が実体で、エージェントごとに読むディレクトリが違うため 2 箇所へ張る。

| エージェント | 読むディレクトリ |
|-------------|----------------|
| Claude Code | `~/.claude/skills` のみ |
| Codex       | `~/.agents/skills` のみ |
| OpenCode    | 両方 |

```
~/.agents/skills ─┐
                  ├─→ skills/
~/.claude/skills ─┘
```

スキル本体は git 管理外で、環境ごとに `npx skills` で管理する。
`Skillfile` は常用するものの一覧で、`sks` がここから未導入のものを導入する。

```bash
npx -y skills find <query>            # 探す
npx -y skills add <owner>/<repo> -g   # 入れる
npx -y skills ls -g                   # 一覧
npx -y skills remove                  # 消す
```

常用すると決めたら `Skillfile` に `<owner>/<repo>@<skill-name>` を追記する。

### 自作スキル

`skills/<name>/SKILL.md` を作り、`skills/.gitignore` に 2 行足して追跡する。

```gitignore
!my-skill/
!my-skill/**
```

ディレクトリと中身の両方が必要（`*` が配下のファイルにも当たるため）。
配線は不要で、置いた時点で全エージェントから見える。

## ライセンス

[MIT](LICENSE)

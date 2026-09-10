# Home Manager が生成する Bash / Zsh 設定から読み込む共通処理。

if [ -x /usr/bin/lesspipe ]; then
    eval "$(SHELL=/bin/sh /usr/bin/lesspipe)"
elif command -v lesspipe.sh >/dev/null 2>&1; then
    export LESSOPEN="| lesspipe.sh %s"
fi

# macOS には dircolors が無い
if command -v dircolors >/dev/null 2>&1; then
    if [ -r "$HOME/.dircolors" ]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi

# HM_TARGET は hosts/*.nix が設定する
hms() {
    if [ -z "$HM_TARGET" ]; then
        echo "hms: HM_TARGET が未設定" >&2
        return 1
    fi
    home-manager switch -b backup --flake "${XDG_CONFIG_HOME:-$HOME/.config}/home-manager#$HM_TARGET" "$@"
}

# flake.lock を更新してから switch
hmu() {
    nix flake update --flake "${XDG_CONFIG_HOME:-$HOME/.config}/home-manager" && hms "$@"
}

# Skillfile に列挙したスキルのうち未導入のものを導入する
sks() {
    local f="${XDG_CONFIG_HOME:-$HOME/.config}/home-manager/skills/Skillfile"
    [ -f "$f" ] || { echo "sks: $f が無い" >&2; return 1; }
    local line name status=0
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in ''|'#'*) continue ;; esac
        name="${line##*@}"
        if [ -e "$HOME/.agents/skills/$name" ]; then
            echo "skip:    $name"
            continue
        fi
        echo "install: $line"
        if ! npx -y skills add "${line%@*}" -g -s "$name" -y; then
            echo "failed:  $line" >&2
            status=1
        fi
    done < "$f"
    return "$status"
}

# 導入済みスキルを更新する
sku() {
    npx -y skills update -g "$@"
}

if [ -f "$HOME/.shell_aliases" ]; then
    . "$HOME/.shell_aliases"
fi

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

# リモートと同期し、flake.lock を更新・適用・コミット・push する
hmu() {
    local repo="${XDG_CONFIG_HOME:-$HOME/.config}/home-manager"
    local upstream remote branch remote_ref remote_head
    local message head_message head

    upstream="$(
        git -C "$repo" rev-parse \
            --abbrev-ref --symbolic-full-name '@{upstream}'
    )" || {
        echo "hmu: upstream が設定されていない" >&2
        return 1
    }

    remote="${upstream%%/*}"
    branch="${upstream#*/}"
    remote_ref="refs/remotes/$remote/$branch"

    git -C "$repo" fetch "$remote" "$branch" || return 1
    remote_head="$(git -C "$repo" rev-parse "$remote_ref")" || return 1

    # リモートが先行していれば fast-forward し、分岐していれば止める
    if git -C "$repo" merge-base --is-ancestor HEAD "$remote_ref"; then
        git -C "$repo" merge --ff-only "$remote_ref" || return 1
    elif ! git -C "$repo" merge-base --is-ancestor "$remote_ref" HEAD; then
        echo "hmu: ローカルとリモートの履歴が分岐している" >&2
        return 1
    fi

    nix flake update --flake "$repo" || return 1
    hms "$@" || return 1

    message="Update flake inputs ($(date +%F))"
    head_message="$(git -C "$repo" log -1 --format=%s)"
    head="$(git -C "$repo" rev-parse HEAD)"

    if git -C "$repo" diff --quiet HEAD -- flake.lock; then
        # 前回 push に失敗した同日コミットがあれば再試行する
        if [ "$head_message" = "$message" ] && [ "$head" != "$remote_head" ]; then
            git -C "$repo" push \
                --force-with-lease="refs/heads/$branch:$remote_head" \
                "$remote" "HEAD:refs/heads/$branch"
        else
            echo "hmu: flake.lock に更新なし"
        fi
        return
    fi

    if [ "$head_message" = "$message" ]; then
        git -C "$repo" commit --amend --no-edit --only -- flake.lock || return 1
    else
        git -C "$repo" commit --only -m "$message" -- flake.lock || return 1
    fi

    git -C "$repo" push \
        --force-with-lease="refs/heads/$branch:$remote_head" \
        "$remote" "HEAD:refs/heads/$branch"
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

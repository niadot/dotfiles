# CLAUDE.md - スキル管理

This file provides guidance to Claude Code (claude.ai/code) when working with code in this directory.

## スキルとは

Claude Codeのスキルは、`/コマンド名`で呼び出せるカスタムコマンド。特定のタスクを自動化できる。

## ディレクトリ構造

```
skills/
├── スキル名/
│   └── SKILL.md    # スキル定義ファイル（必須、大文字）
└── 別のスキル名/
    └── SKILL.md
```

## SKILL.mdの書き方

```markdown
# スキル名

スキルの説明。

## 使い方
/スキル名 [引数]

## 指示

ユーザーがこのスキルを実行したとき、以下を行ってください：

1. 最初のステップ
2. 次のステップ
3. 結果の報告
```

## このディレクトリのスキル

- **hello**: 挨拶メッセージを表示
- **code-review**: コードの品質、セキュリティ、パフォーマンスをレビュー
- **find-todos**: TODO/FIXME/HACKコメントを検索して優先度別に整理

## 注意事項

- ファイル名は`SKILL.md`（大文字、単数形）
- スキルは`~/.claude/skills/`にシンボリックリンクされている
- 編集後は即座に反映される（`home-manager switch`不要）

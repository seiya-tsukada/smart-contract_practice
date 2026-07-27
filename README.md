# web3-handson

スマートコントラクトと Python クライアントをハンズオンで開発するための作業リポジトリ。

## ゴール

1. ブロックチェーン上にスマートコントラクトを開発・デプロイする
2. そのコントラクトを利用する Python クライアントアプリを開発する
3. 運用に必要な監査・セキュリティの観点を身につける

## 技術スタック

| 領域 | 採用 | 理由 |
|---|---|---|
| チェーン | Base Sepolia (testnet, Chain ID `84532`) → Base mainnet | Coinbase Wallet がネイティブ対応、EVM 互換、ガス代が極小 |
| コントラクト言語 | Solidity | 監査ツール・ライブラリの成熟度が最も高い |
| 開発・テスト | Foundry (`forge` / `anvil` / `cast`) | 業界標準。テストが高速で、ファズ・invariant テストが標準装備 |
| クライアント | Python 3.11+ / web3.py v7 | 指定要件 |
| 静的解析 | Slither | Foundry プロジェクトを自動検出 |
| 開発環境 | macOS (Apple Silicon / Intel), zsh | 実行環境 |

## ロードマップ

| Step | 内容 | ドキュメント | 状態 |
|---|---|---|---|
| 0 | 環境構築（Foundry / Python / Slither / 開発用ウォレット / faucet） | [docs/00-setup-macos.md](docs/00-setup-macos.md) | 進行中 |
| 1 | Counter コントラクト — 開発〜テスト〜ローカル〜testnet デプロイ〜Python 呼び出し | `docs/01-counter.md` | 未着手 |
| 2 | ERC-20 トークン — OpenZeppelin、アクセス制御、イベント、Python クライアント | `docs/02-erc20.md` | 未着手 |
| 3 | Vault（預入 / 引出） — 再入可能性・CEI パターン・攻撃と防御 | `docs/03-vault.md` | 未着手 |
| 4 | 監査と運用 — Slither / coverage / CI / verify / モニタリング / mainnet 判断 | `docs/04-audit-ops.md` | 未着手 |

## 用語集

不明な用語は [docs/glossary.md](docs/glossary.md) を参照。

## セキュリティ上の大前提

**資産の入った Coinbase Wallet を開発に使わないこと。**
開発では秘密鍵をツールに渡す場面が発生する。開発専用の新規アカウントを生成し、
Coinbase Wallet は「エンドユーザーとして dApp に接続する側」の検証にのみ使用する。

詳細は [docs/security-baseline.md](docs/security-baseline.md)。

## ディレクトリ構成（最終形の想定）

```
web3-handson/
├── README.md
├── .gitignore
├── docs/                  # ハンズオンの手順書
├── contracts/             # Foundry プロジェクト（Step 1 で作成）
│   ├── src/
│   ├── test/
│   ├── script/
│   └── foundry.toml
└── client/                # Python クライアント（Step 1 で作成）
    ├── pyproject.toml
    └── src/
```

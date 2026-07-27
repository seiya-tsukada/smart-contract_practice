# Step 0: 環境構築（macOS）

対象: macOS（Apple Silicon / Intel 両対応）、デフォルトシェル zsh。

所要時間の目安: 20〜30分（faucet の待ち時間を含む）。

---

## 0-0. 前提ツールの確認

```bash
# Xcode Command Line Tools（git, curl, cc などが入る）
xcode-select -p || xcode-select --install

# Homebrew
brew --version || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Apple Silicon で Homebrew を新規インストールした場合、PATH 追加が必要。

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**チェックポイント**: `brew --version` がバージョンを返すこと。

---

## 0-1. Foundry のインストール

Foundry は Rust 製のスマートコントラクト開発ツールキット。4つのバイナリが入る。

| バイナリ | 役割 |
|---|---|
| `forge` | ビルド、テスト、デプロイスクリプト実行 |
| `cast` | チェーンへの問い合わせ、トランザクション送信、ウォレット管理 |
| `anvil` | ローカルテストネット（インメモリの EVM ノード） |
| `chisel` | Solidity の REPL |

```bash
curl -L https://foundry.paradigm.xyz | bash
source ~/.zshenv          # インストーラが PATH を書き込んだファイルを読み直す
foundryup
```

`source ~/.zshenv` でうまくいかない場合は、ターミナルを開き直すか以下を試す。

```bash
source ~/.zshrc
# それでもだめなら
export PATH="$HOME/.foundry/bin:$PATH"
```

**チェックポイント**:

```bash
forge --version
cast --version
anvil --version
```

3つともバージョン（例: `forge Version: 1.x.x-stable`）を返せば成功。

> Homebrew 経由でのインストールは公式に非推奨。必ず `foundryup` を使う。
> 更新したいときも `foundryup` を再実行するだけでよい。

---

## 0-2. Python 環境

macOS 標準の Python は使わず、Homebrew の Python + venv を使う。

```bash
brew install python@3.12
python3.12 --version
```

作業ディレクトリと仮想環境を作る。

```bash
mkdir -p ~/dev/web3-handson && cd ~/dev/web3-handson

python3.12 -m venv .venv
source .venv/bin/activate       # 以後、作業のたびにこれを実行する

pip install --upgrade pip
pip install "web3>=7,<8" eth-account python-dotenv rich
```

**チェックポイント**:

```bash
python -c "import web3; print(web3.__version__)"
# → 7.x.x が出れば成功
```

> web3.py は現在 v7 系が stable（v8 はベータ段階）。ハンズオン中の破壊的変更を避けるため v7 に固定している。

---

## 0-3. 静的解析ツール（Slither）

コードを書く前に入れておく。後回しにすると使わなくなるため。

```bash
# .venv が有効な状態で
pip install slither-analyzer
slither --version
```

Slither は Foundry プロジェクトを自動検出し、`forge build` 経由でコンパイルする。
そのため solc の個別インストールは不要。

---

## 0-4. 開発専用アカウントの作成

**資産の入った Coinbase Wallet の鍵は絶対に使わない。**

### 新規アカウントを生成

```bash
cast wallet new
```

出力例:

```
Successfully created new keypair.
Address:     0xAbC...123
Private key: 0x4f3e...
```

- **Address**: 控えておく（公開情報なので共有して問題ない）
- **Private key**: 次の手順で暗号化キーストアに取り込む。平文で `.env` やコードに書かない

### キーストアに取り込む

```bash
cast wallet import dev-deployer --interactive
```

対話プロンプトで:

1. `Enter private key:` → 上で生成した private key を貼り付け（画面には表示されない）
2. `Enter password:` → キーストア用のパスワードを設定（忘れないこと）

保存先は `~/.foundry/keystores/dev-deployer`。

**チェックポイント**:

```bash
cast wallet list
# → dev-deployer (Local) が表示される

cast wallet address --account dev-deployer
# → パスワードを入力すると 0-4 で生成したアドレスが返る
```

これで、以後のデプロイは `--account dev-deployer` を指定するだけで済み、
秘密鍵をファイルや環境変数に置く必要がなくなる。

---

## 0-5. Base Sepolia のテスト用 ETH を入手

### ネットワーク情報

| 項目 | 値 |
|---|---|
| ネットワーク名 | Base Sepolia |
| Chain ID | `84532` |
| RPC URL | `https://sepolia.base.org` |
| 通貨シンボル | ETH（テスト用、価値なし） |
| エクスプローラ | `https://sepolia.basescan.org` |

### 接続確認

```bash
cast chain-id --rpc-url https://sepolia.base.org
# → 84532

cast block-number --rpc-url https://sepolia.base.org
# → 現在のブロック番号
```

### faucet から受け取る

以下のいずれかで、**0-4 で作成した開発用アドレス**に送る。

- Alchemy: `https://www.alchemy.com/faucets/base-sepolia`
- Chainlink: `https://faucets.chain.link/base-sepolia`
- Base 公式の faucet 一覧: `https://docs.base.org/base-chain/network-information/network-faucets`

一部の faucet は「Ethereum mainnet に一定の残高・取引履歴があること」を条件にする。
その条件確認に Coinbase Wallet を接続するのは問題ないが、
**送金先アドレスは必ず開発用アドレスにする**こと。

**チェックポイント**:

```bash
cast balance <開発用アドレス> --rpc-url https://sepolia.base.org --ether
# → 0 より大きい値が返る
```

0.01 ETH 程度あれば Step 1〜4 は十分に足りる。

---

## 0-6. シェルの補助設定（任意だが推奨）

毎回 RPC URL を打つのが面倒なので、エイリアスを用意しておく。

```bash
cat >> ~/.zshrc <<'EOF'

# --- web3 handson ---
export BASE_SEPOLIA_RPC="https://sepolia.base.org"
alias w3="cd ~/dev/web3-handson && source .venv/bin/activate"
EOF

source ~/.zshrc
```

以後、`w3` と打つだけで作業ディレクトリに移動して仮想環境が有効になる。

---

## Step 0 完了チェックリスト

- [ ] `forge --version` / `cast --version` / `anvil --version` が通る
- [ ] `.venv` が有効化でき、web3.py 7.x が import できる
- [ ] `slither --version` が通る
- [ ] `cast wallet list` に `dev-deployer` が表示される
- [ ] `cast chain-id --rpc-url $BASE_SEPOLIA_RPC` が `84532` を返す
- [ ] 開発用アドレスの Base Sepolia 残高が 0 より大きい

すべて埋まったら Step 1 へ。

---

## トラブルシューティング

**`foundryup: command not found`**
インストーラは `~/.zshenv` に PATH を書き込む。ターミナルを開き直すか、
`export PATH="$HOME/.foundry/bin:$PATH"` を実行する。

**`cast wallet import` でパスワードを忘れた**
キーストアファイル（`~/.foundry/keystores/dev-deployer`）を削除し、
`cast wallet new` からやり直す。testnet の資産なので損失はない。

**faucet が受け付けてくれない**
複数の faucet を順に試す。時間帯によって枯渇していることがある。
`sepolia.basescan.org` でアドレスを検索すると着金状況を確認できる。

**Apple Silicon で pip install が失敗する**
`brew install libffi` を入れてから再試行する。

# Rails Version Catalog

Rails のバージョン差分と標準構成の変化を、実際の Rails アプリ上で確認できる**比較カタログ**です。
現在の比較対象は **Rails 7.0 / Rails 8.0 / Rails 8.1.4** です。

## 目的 ✨

- 単一の変更前後ではなく、**複数バージョンを横並びで比較**する
- **体験デモ** は現在の実行環境の挙動確認、**バージョン比較** はバージョン間の差分確認、と役割を分ける
- Solid Queue / Solid Cache / Kamal などは、採用判断・運用判断の論点も機能の詳細で確認できるようにする
- 機能ごとの比較データを YAML で持ち、**データ追加中心で拡張**しやすくする
- 将来 **Rails 9.0 / 9.2** などが出たときに、比較軸を増やしやすくする

## 確認できる内容

### 体験デモ

- 認証ジェネレーター
- Solid Queue
- Solid Cable
- Solid Cache
- 実行環境の構成概要

### 設定・基盤の違い

- Active Job の継続処理（Continuations）
- 構造化イベント報告
- Markdown の描画
- ローカル CI（Local CI）
- コマンドラインからの認証情報取得
- 関連付けの非推奨化
- Propshaft
- Kamal によるデプロイ
- Thruster と本番環境の標準設定

### 各セクションの役割

- **概要**
  機能の概要と、どのバージョンを比較しているかをまとめます。
- **バージョン比較**
  バージョンごとの状態・説明・主な変更点・関連ファイル・移行の影響を並べて比較します。
- **体験デモ**
  現在の実行環境上で実際に触れる操作や画面を確認します。
- **採用判断**
  採用を検討する条件、慎重になる条件、代替技術、実行環境の必要条件をまとめます。
- **コード・設定の違い**
  バージョンごとの関連ファイル、設定、移行観点をまとめて確認します。

## 設計の要点 🛠️

- `VersionCatalog`
  - 比較対象バージョンのメタデータを一元管理
- `FeatureCatalog`
  - 機能ごとのバージョン比較表を管理
  - `notes_by_version` / `highlights_by_version` / `source_links_by_version` に加えて、`status_by_version` / `files_by_version` / `upgrade_notes_by_version` などで比較データを拡張できる
  - `adoption_when` / `adoption_cautions` / `adoption_alternatives` / `adoption_requirements` で機能単位の採用判断データを扱う
- UI
  - `compare` クエリパラメーターで表示対象バージョンを切り替え
  - 詳細画面は **概要／比較／体験デモ／採用判断／移行時の注意** のようにセクションを分けて表示

## 技術構成

- Rails 8.1.4
- PostgreSQL
- Hotwire + Tailwind CSS
- Solid Queue / Solid Cable / Solid Cache
- RSpec

> 補足: アプリの実行環境は現在このリポジトリの Rails バージョンで動いています。
> 比較データは **Rails 7.0 / 8.0 / 8.1.4** の公式情報を基準に整理しています。

## ローカル環境の準備

### 方法 A: プロジェクト専用の Docker PostgreSQL

```bash
cp .env.example .env
docker compose up -d db

bin/rails db:prepare
bin/rails db:seed
bin/rails tailwindcss:build
bin/dev
```

`bin/dev` は `web` / `jobs` を起動します。
`bin/dev` は `.env` を自動読込します。

> 補足:
> 一部の macOS 環境では `tailwindcss:watch` が
> `Error starting FSEvents stream` で停止します。
> このリポジトリでは `bin/dev` に CSS の変更監視を含めず、
> CSS 変更時は `bin/rails tailwindcss:build` を実行する運用にしています。

### 方法 B: 外部またはローカルの PostgreSQL

```bash
bundle install
export PGUSER=your_postgres_user
export PGPASSWORD=your_postgres_password
bin/rails db:prepare
bin/rails db:seed
bin/rails tailwindcss:build
bin/dev
```

`bin/dev` は `web` / `jobs` を起動します。
外部 DB を使う場合は、必要な環境変数をシェル側で export してください。

## デモアカウント

- メールアドレス: `demo@example.com`
- パスワード: `password123`

## 将来のバージョンを追加する

将来 `Rails 9.0` や `Rails 9.2` を足すときは、基本的に次を更新します。

1. カタログデータ
   - バージョンのメタデータや機能の比較データを追加
2. 必要ならデモ・比較用の部分テンプレートを追加
3. `bundle exec rspec spec/models/version_catalog_spec.rb spec/models/feature_catalog_spec.rb spec/requests/feature_catalog_flow_spec.rb`
   - スキーマの検証と画面回帰を確認

大きな 2カラム UI 改修をせず、**YAML データの追加**を中心に広げる前提です。

## 参照資料（英語）

- [Rails 7.0 リリースノート](https://guides.rubyonrails.org/7_0_release_notes.html)
- [Rails 8.0 リリースノート](https://guides.rubyonrails.org/8_0_release_notes.html)
- [Rails 8.1 リリースノート](https://guides.rubyonrails.org/8_1_release_notes.html)
- [Ruby on Rails のアップグレードガイド](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html)

## 補足

- `config/database.yml` は、次の環境変数から PostgreSQL の接続情報を取得します。
  - `POSTGRES_HOST` / `POSTGRES_PORT`
  - または `PGHOST` / `PGPORT`
  - `POSTGRES_USER` / `POSTGRES_PASSWORD`
  - または `PGUSER` / `PGPASSWORD`
- 接続 URL 全体を `DATABASE_URL` で指定することもできます。

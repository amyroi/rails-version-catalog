# Rails Multi-Version Feature Catalog

Rails の**比較カタログ**を UI で確認できる app です。  
現在の初期比較対象は **Rails 7.0 / Rails 8.0 / Rails 8.1.2** です。

## 目的 ✨

- 単一の before / after ではなく、**複数 version を横並びで比較**する
- **live demo** は current runtime の挙動確認、**version comparison** は version 間の差分確認、と役割を分ける
- feature ごとの比較 data を YAML で持ち、**データ追加中心で拡張**しやすくする
- 将来 **Rails 9.0 / 9.2** などが出たときに、比較軸を増やしやすくする

## What you can see

### Interactive demos

- Authentication generator
- Solid Queue
- Solid Cable
- Solid Cache
- Runtime stack overview

### Config / platform differences

- Active Job Continuations
- Structured Event Reporting
- Markdown Rendering
- Local CI
- Command-line Credentials Fetching
- Deprecated Associations
- Propshaft
- Kamal deployments
- Thruster / production defaults

### What each section means

- **Overview**  
  feature の概要と、どの version を比較しているかをまとめます。
- **Version comparison matrix**  
  version ごとの status / summary / key changes / files / upgrade impact を並べて比較します。
- **Live demo**  
  current runtime 上で実際に触れる操作や画面を確認します。

## Architecture highlights 🛠️

- `VersionCatalog`
  - 比較対象 version の metadata を一元管理
- `FeatureCatalog`
  - feature ごとの version matrix を管理
  - `notes_by_version` / `highlights_by_version` / `source_links_by_version` に加えて、`status_by_version` / `files_by_version` / `upgrade_notes_by_version` などで比較 data を拡張できる
- UI
  - `compare` query param で表示対象 version を切替
  - 詳細画面は **overview / comparison / live demo / upgrade notes** のように section を分けて表示

## Stack

- Rails 8.1.2
- PostgreSQL
- Hotwire + Tailwind CSS
- Solid Queue / Solid Cable / Solid Cache
- Minitest

> 補足: app runtime は現在この repo の Rails version で動いています。  
> 比較データは **Rails 7.0 / 8.0 / 8.1.2** の公式情報を基準に整理しています。

## Local setup

### Option A: project-local Docker PostgreSQL

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

> Note:
> 一部の macOS 環境では `tailwindcss:watch` が
> `Error starting FSEvents stream` で停止します。
> この repo では `bin/dev` に CSS watcher を含めず、
> CSS 変更時は `bin/rails tailwindcss:build` を実行する運用にしています。

### Option B: external/local PostgreSQL

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
外部 DB を使う場合は、必要な環境変数を shell 側で export してください。

## Demo account

- email: `demo@example.com`
- password: `password123`

## Add a future version

将来 `Rails 9.0` や `Rails 9.2` を足すときは、基本的に次を更新します。

1. catalog data
   - version metadata や feature 比較 data を追加
2. 必要なら demo / comparison partial を追加
3. `bin/rails test test/models/version_catalog_test.rb test/models/feature_catalog_test.rb test/integration/feature_catalog_flow_test.rb`
   - schema validation と画面回帰を確認

大きな 2カラム UI 改修をせず、**YAML data の追加**を中心に広げる前提です。

## Sources

- Rails 7.0 Release Notes  
  https://guides.rubyonrails.org/7_0_release_notes.html
- Rails 8.0 Release Notes  
  https://guides.rubyonrails.org/8_0_release_notes.html
- Rails 8.1 Release Notes  
  https://guides.rubyonrails.org/8_1_release_notes.html
- Upgrading Ruby on Rails  
  https://guides.rubyonrails.org/upgrading_ruby_on_rails.html

## Notes

- `config/database.yml` expects PostgreSQL credentials via:
  - `POSTGRES_HOST` / `POSTGRES_PORT`
  - or `PGHOST` / `PGPORT`
  - `POSTGRES_USER` / `POSTGRES_PASSWORD`
  - or `PGUSER` / `PGPASSWORD`
- You can also provide a full `DATABASE_URL`.

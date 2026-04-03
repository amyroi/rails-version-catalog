# Rails Multi-Version Feature Catalog

Rails の**複数メジャーバージョン比較**を UI で確認できるカタログ app です。  
現在の初期比較対象は **Rails 7.0 / Rails 8.0 / Rails 8.1.2** です。

## 目的 ✨

- 単一の before / after ではなく、**複数 version を横並びで比較**する
- runtime demo と comparison card を分けて、**触って理解**しやすくする
- 将来 **Rails 9.0 / 9.2** などが出たときに、**データ追加中心で拡張**しやすくする

## What you can see

### Runtime demos

- Authentication generator
- Solid Queue
- Solid Cable
- Solid Cache
- Runtime stack overview

### Comparison cards

- Active Job Continuations
- Structured Event Reporting
- Markdown Rendering
- Local CI
- Command-line Credentials Fetching
- Deprecated Associations
- Propshaft
- Kamal deployments
- Thruster / production defaults

## Architecture highlights 🛠️

- `VersionCatalog`
  - 比較対象 version の metadata を一元管理
  - release date / label / official source / latest status を保持
- `FeatureCatalog`
  - feature ごとの version matrix を管理
  - `notes_by_version` / `highlights_by_version` / `source_links_by_version` で拡張可能
- UI
  - `compare` query param で表示対象 version を切替
  - 詳細画面は **multi-version matrix** で表示

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

1. `app/models/version_catalog.rb`
   - version metadata を追加
2. `app/models/feature_catalog.rb`
   - 各 feature の `notes_by_version` / `highlights_by_version` を追加
3. 必要なら demo / comparison partial を追加

大きな 2カラム UI 改修をせず、**version metadata と feature data の追加**で広げる前提です。

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

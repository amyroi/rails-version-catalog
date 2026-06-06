# Rails Version Catalog

Rails version 差分と default stack changes を、実際の Rails app 上で確認できる**比較カタログ**です。  
現在の初期比較対象は **Rails 7.0 / Rails 8.0 / Rails 8.1.2 / Rails 8.1.3** です。

## 目的 ✨

- 単一の before / after ではなく、**複数 version を横並びで比較**する
- **live demo** は current runtime の挙動確認、**version comparison** は version 間の差分確認、と役割を分ける
- Solid Queue / Solid Cache / Kamal などは、採用判断・運用判断の論点も feature detail で確認できるようにする
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
- **Adoption readiness**  
  採用を検討する条件、慎重になる条件、代替技術、runtime requirements をまとめます。
- **Code / config diff**  
  version ごとの関連ファイル、設定、移行観点をまとめて確認します。

## Architecture highlights 🛠️

- `VersionCatalog`
  - 比較対象 version の metadata を一元管理
- `FeatureCatalog`
  - feature ごとの version matrix を管理
  - `notes_by_version` / `highlights_by_version` / `source_links_by_version` に加えて、`status_by_version` / `files_by_version` / `upgrade_notes_by_version` などで比較 data を拡張できる
  - `adoption_when` / `adoption_cautions` / `adoption_alternatives` / `adoption_requirements` で feature 単位の採用判断 data を扱う
- UI
  - `compare` query param で表示対象 version を切替
  - 詳細画面は **overview / comparison / live demo / adoption readiness / upgrade notes** のように section を分けて表示

## Stack

- Rails 8.1.3
- PostgreSQL
- Hotwire + Tailwind CSS
- Next.js 15 + TypeScript
- Solid Queue / Solid Cable / Solid Cache
- RSpec

> 補足: app runtime は現在この repo の Rails version で動いています。  
> 比較データは **Rails 7.0 / 8.0 / 8.1.2 / 8.1.3** の公式情報を基準に整理しています。

## Frontend architecture 🧭

この repo は移行期間中、Rails と Next.js を並べて動かします。

- Rails
  - 既存の Rails app / interactive demo / catalog API を担当
  - live demo はこの段階では Rails 側に残す
- Next.js frontend
  - catalog browsing UI を担当
  - Rails API から catalog data を取得する
  - App Router / Server Components を基本にする

### Next.js page map

- `/`
  - version summary と feature overview
- `/features`
  - feature 一覧と compare version selector
- `/features/[slug]`
  - feature detail、comparison matrix、adoption readiness、code/config diff、live demo placeholder、upgrade notes

### Frontend environment variables

```bash
cp frontend/.env.local.example frontend/.env.local
```

- `RAILS_API_URL`
  - Next.js server-side fetch 用
  - browser には公開しない前提
  - local default は `http://127.0.0.1:3100`
- `NEXT_PUBLIC_RAILS_URL`
  - browser-visible な Rails demo link 用
  - `NEXT_PUBLIC_` prefix のため client 側にも公開される
  - local default は `http://127.0.0.1:3100`

通常の local development では `bin/dev` が Rails と Next.js をまとめて起動します。
`bin/dev` は `.env.example` の `APP_PORT=3100` を Rails port として使い、Next.js からの API fetch も同じ Rails port に向けます。
Next.js は一部環境の file watcher 問題を避けるため、`npm run dev:polling --prefix frontend` 相当で起動します。

## Local setup

### Option A: project-local Docker PostgreSQL

```bash
cp .env.example .env
cp frontend/.env.local.example frontend/.env.local
docker compose up -d db

npm install --prefix frontend
bin/rails db:prepare
bin/rails db:seed
bin/rails tailwindcss:build
bin/dev
```

`bin/dev` は `web` / `jobs` / `next` を起動します。  
`bin/dev` は `.env` を自動読込します。

> Note:
> 一部の macOS 環境では `tailwindcss:watch` が
> `Error starting FSEvents stream` で停止します。
> この repo では `bin/dev` に CSS watcher を含めず、
> CSS 変更時は `bin/rails tailwindcss:build` を実行する運用にしています。

### Option B: external/local PostgreSQL

```bash
bundle install
npm install --prefix frontend
cp frontend/.env.local.example frontend/.env.local
export PGUSER=your_postgres_user
export PGPASSWORD=your_postgres_password
bin/rails db:prepare
bin/rails db:seed
bin/rails tailwindcss:build
bin/dev
```

`bin/dev` は `web` / `jobs` / `next` を起動します。  
外部 DB を使う場合は、必要な環境変数を shell 側で export してください。

## Demo account

- email: `demo@example.com`
- password: `password123`

## Add a future version

将来 `Rails 9.0` や `Rails 9.2` を足すときは、基本的に次を更新します。

1. catalog data
   - version metadata や feature 比較 data を追加
2. 必要なら demo / comparison partial を追加
3. `bundle exec rspec spec/models/version_catalog_spec.rb spec/models/feature_catalog_spec.rb spec/requests/feature_catalog_flow_spec.rb`
   - schema validation と画面回帰を確認

大きな 2カラム UI 改修をせず、**YAML data の追加**を中心に広げる前提です。

## Updating frontend API types

When catalog API response shapes change, update the TypeScript types in `frontend/lib/types.ts` and the fetch helpers in `frontend/lib/api.ts` together.

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

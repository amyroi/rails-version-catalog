# Rails8 Feature Catalog

Rails 7.2 → Rails 8.0 の差分や新機能を **UI で確認できる Rails 8.0 app** です。

## What you can see

- Authentication generator
- Solid Queue
- Solid Cable
- Solid Cache
- Runtime stack overview
- Docker / deploy orientation
- Propshaft
- Kamal 2 integration
- Thruster / production defaults

## Stack

- Rails 8.0.4
- PostgreSQL
- Hotwire + Tailwind CSS
- Solid Queue / Solid Cable / Solid Cache
- Minitest

## Local setup

```bash
bundle install
export PGUSER=your_postgres_user
export PGPASSWORD=your_postgres_password
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

`Procfile.dev` starts:

- web
- Tailwind watcher
- Solid Queue worker

## Demo account

- email: `demo@example.com`
- password: `password123`

## Notes

- The catalog uses official Rails 8 release / upgrading information as the comparison baseline:
  - https://guides.rubyonrails.org/8_0_release_notes.html
  - https://guides.rubyonrails.org/upgrading_ruby_on_rails.html
- `config/database.yml` expects PostgreSQL credentials via `POSTGRES_USER` / `POSTGRES_PASSWORD` or `PGUSER` / `PGPASSWORD`.
- You can also provide a full `DATABASE_URL`.

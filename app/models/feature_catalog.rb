class FeatureCatalog
  class << self
    def all
      @all ||= [
        runtime_feature(
          slug: "authentication-generator",
          title: "Authentication generator",
          summary: "Rails の標準認証 story がどう変わったかを、サインアップ・ログイン・保護ページで確認できます。",
          live_demo_available: true,
          notes_by_version: {
            "7.0" => "標準認証 generator は未同梱で、Devise などの外部ライブラリか手作業実装に寄りがちでした。",
            "8.0" => "generate authentication で Users / Sessions / Password reset の土台をすぐに作れるようになりました。",
            "8.1.2" => "認証 generator は Rails 8 系の標準導線として定着し、Current session・rate limit・password reset と一緒に学びやすくなっています."
          },
          status_by_version: {
            "7.0" => "not available",
            "8.0" => "default",
            "8.1.2" => "default"
          },
          files_by_version: {
            "7.0" => [],
            "8.0" => [ "app/models/user.rb", "app/models/session.rb", "app/controllers/sessions_controller.rb" ],
            "8.1.2" => [ "app/models/user.rb", "app/models/session.rb", "app/controllers/sessions_controller.rb" ]
          },
          upgrade_notes_by_version: {
            "7.0" => [ "既存 app では first-party auth を追加するか、既存認証実装を維持するかを決める必要があります。" ],
            "8.0" => [ "Current/session に寄せると、Rails 標準の auth flow に沿いやすくなります。" ],
            "8.1.2" => [ "password reset や rate limit を含む生成物を baseline として揃えるのがよいです。" ]
          },
          code_examples_by_version: {
            "8.0" => [ "bin/rails generate authentication" ],
            "8.1.2" => [ "bin/rails generate authentication" ]
          },
          operational_notes_by_version: {
            "8.0" => [ "Session / mailer / protected page の基本フローを integration test で押さえると安心です。" ],
            "8.1.2" => [ "Current.session を前提に、認証済み状態の表示と保護ページの遷移を確認しやすくなります。" ]
          },
          highlights_by_version: {
            "7.0" => "No first-party auth generator",
            "8.0" => "First-party authentication generator",
            "8.1.2" => "Stable Rails 8 auth baseline"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        runtime_feature(
          slug: "solid-queue",
          title: "Solid Queue",
          summary: "Active Job backend の変化を、enqueue と状態遷移の UI で確認できます。",
          live_demo_available: true,
          notes_by_version: {
            "7.0" => "デフォルトは in-process / non-durable backend で、永続 queue は別途選定が必要でした。",
            "8.0" => "Solid Queue が production default story に入り、DB-backed queue を採用しやすくなりました。",
            "8.1.2" => "Continuations と組み合わせやすい durable backend として、Rails 8.1 系の新機能の土台にもなります。"
          },
          status_by_version: {
            "7.0" => "custom",
            "8.0" => "default",
            "8.1.2" => "default"
          },
          files_by_version: {
            "7.0" => [],
            "8.0" => [ "config/queue.yml", "Procfile.dev" ],
            "8.1.2" => [ "config/queue.yml", "Procfile.dev" ]
          },
          upgrade_notes_by_version: {
            "7.0" => [ "active_job queue adapter を別途選ぶ前提です。" ],
            "8.0" => [ "worker process を起動する運用に切り替えると、queue の挙動を追いやすいです。" ],
            "8.1.2" => [ "Continuations を扱う job は durable backend 前提で考えると整理しやすいです。" ]
          },
          code_examples_by_version: {
            "8.0" => [ "bin/jobs start" ],
            "8.1.2" => [ "bin/jobs start" ]
          },
          operational_notes_by_version: {
            "8.0" => [ "queue worker が動いていないと job が進まないので、CI とローカルで起動確認を入れると安心です。" ],
            "8.1.2" => [ "状態遷移を見るために recent jobs の一覧と turbo stream の更新が有効です。" ]
          },
          highlights_by_version: {
            "7.0" => "Async / external queue choice",
            "8.0" => "Solid Queue arrives",
            "8.1.2" => "Continuations-ready durable queue"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        runtime_feature(
          slug: "solid-cable",
          title: "Solid Cable",
          summary: "Turbo Stream と DB-backed cable story の違いを、ライブ更新 UI で確認できます。",
          live_demo_available: true,
          notes_by_version: {
            "7.0" => "Action Cable は Redis 構成が一般的で、DB-backed cable は標準の主流ではありませんでした。",
            "8.0" => "Solid Cable が Rails 8 の default stack に入り、DB-backed realtime の選択肢が近くなりました。",
            "8.1.2" => "Solid 系 stack とあわせて、single-app で queue / cache / cable を揃えやすい構成が続いています。"
          },
          status_by_version: {
            "7.0" => "custom",
            "8.0" => "default",
            "8.1.2" => "default"
          },
          files_by_version: {
            "7.0" => [],
            "8.0" => [ "config/cable.yml" ],
            "8.1.2" => [ "config/cable.yml" ]
          },
          upgrade_notes_by_version: {
            "7.0" => [ "Redis / external cable 構成を前提にしたままでも動かせます。" ],
            "8.0" => [ "DB-backed realtime を採用する場合は、channel 更新の見え方を確認してください。" ],
            "8.1.2" => [ "Turbo Stream と合わせて、単一 app での realtime を整理しやすいです。" ]
          },
          code_examples_by_version: {
            "8.0" => [ "turbo_stream_from \"solid_cable_messages\"" ],
            "8.1.2" => [ "turbo_stream_from \"solid_cable_messages\"" ]
          },
          operational_notes_by_version: {
            "8.0" => [ "複数タブで投稿し、broadcast の反映を確認すると分かりやすいです。" ],
            "8.1.2" => [ "DB-backed cable でも broadcast の配信先と一覧更新の関係を追えるようにしておくと安心です。" ]
          },
          highlights_by_version: {
            "7.0" => "Redis-first realtime setups",
            "8.0" => "Solid Cable default story",
            "8.1.2" => "DB-backed realtime remains first-class"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        runtime_feature(
          slug: "solid-cache",
          title: "Solid Cache",
          summary: "Cache hit / miss を通じて、durable cache story の違いを比較できます。",
          live_demo_available: true,
          notes_by_version: {
            "7.0" => "memory_store や Redis を環境ごとに選ぶことが多く、durable cache は標準同梱ではありませんでした。",
            "8.0" => "Solid Cache が標準 stack に入り、DB-backed cache を採用しやすくなりました。",
            "8.1.2" => "Solid Cache は Rails 8.1 系でも durable stack の一部として継続し、queue / cable と一緒に理解しやすくなっています."
          },
          status_by_version: {
            "7.0" => "custom",
            "8.0" => "default",
            "8.1.2" => "default"
          },
          files_by_version: {
            "7.0" => [],
            "8.0" => [ "config/cache.yml" ],
            "8.1.2" => [ "config/cache.yml" ]
          },
          upgrade_notes_by_version: {
            "7.0" => [ "cache backend を環境ごとに選ぶ前提です。" ],
            "8.0" => [ "cache hit/miss を確認する UI があると、採用後の挙動を追いやすいです。" ],
            "8.1.2" => [ "queue / cable と同様に、durable stack としてまとめて考えると整理しやすいです。" ]
          },
          code_examples_by_version: {
            "8.0" => [ "Rails.cache.fetch(\"demo\")" ],
            "8.1.2" => [ "Rails.cache.fetch(\"demo\")" ]
          },
          operational_notes_by_version: {
            "8.0" => [ "refresh / clear の2操作で cache behavior を確認すると分かりやすいです。" ],
            "8.1.2" => [ "payload 生成時刻や checksum を見せると cache の効き方を追いやすいです。" ]
          },
          highlights_by_version: {
            "7.0" => "Choose cache backend yourself",
            "8.0" => "Solid Cache arrives",
            "8.1.2" => "Durable stack remains cohesive"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        runtime_feature(
          slug: "runtime-stack",
          title: "Runtime stack overview",
          summary: "現行 app の runtime facts を見ながら、Rails の標準 stack がどう進化したかを俯瞰できます。",
          notes_by_version: {
            "7.0" => "Hotwire は大きなテーマでしたが、queue / cache / cable / deploy は個別選定の色が強めでした。",
            "8.0" => "Solid Queue / Cache / Cable、Kamal、Thruster などで default story が一段まとまりました。",
            "8.1.2" => "8.1 では Continuations・Structured Event Reporting・Local CI など、運用と開発体験の story がさらに広がりました。"
          },
          highlights_by_version: {
            "7.0" => "Hotwire era baseline",
            "8.0" => "Default stack gets cohesive",
            "8.1.2" => "Operational developer experience expands"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        comparison_feature(
          slug: "active-job-continuations",
          title: "Active Job Continuations",
          summary: "長い job を step 単位で継続できる Rails 8.1 の新機能です。",
          notes_by_version: {
            "7.0" => "中断に強い multi-step job を標準 API だけで表現するのは難しく、再開ロジックは自前で持ちがちでした。",
            "8.0" => "Solid Queue は入りましたが、job continuation 自体はまだ標準 API ではありませんでした。",
            "8.1.2" => "ActiveJob::Continuable により step / cursor を用いた再開可能ジョブを標準で組み立てられます。"
          },
          highlights_by_version: {
            "7.0" => "Custom resumable jobs",
            "8.0" => "Durable queue without continuations",
            "8.1.2" => "ActiveJob::Continuable"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        comparison_feature(
          slug: "structured-event-reporting",
          title: "Structured Event Reporting",
          summary: "Rails 8.1 の Event Reporter により、構造化イベントを標準インターフェースで発行できます。",
          notes_by_version: {
            "7.0" => "構造化イベントは ActiveSupport::Notifications や独自 logger 設計に分散しやすい状態でした。",
            "8.0" => "運用向け default story は広がりましたが、統一的な structured event API はまだありませんでした。",
            "8.1.2" => "Rails.event.notify / tagged / set_context と subscriber により、post-processing 向けイベントを標準化できます。"
          },
          highlights_by_version: {
            "7.0" => "Notifications + custom logging",
            "8.0" => "No unified event reporter yet",
            "8.1.2" => "Rails.event"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        comparison_feature(
          slug: "markdown-rendering",
          title: "Markdown Rendering",
          summary: "Rails 8.1 では Markdown response / rendering をより直接扱えるようになりました。",
          notes_by_version: {
            "7.0" => "Markdown response は gem や custom responder による拡張が前提になりやすかったです。",
            "8.0" => "標準 rendering story は引き続き HTML / JSON 中心でした。",
            "8.1.2" => "respond_to の中で render markdown: object を使う導線が公式 release notes に登場しました。"
          },
          highlights_by_version: {
            "7.0" => "Custom markdown rendering",
            "8.0" => "No first-class markdown response",
            "8.1.2" => "render markdown:"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        comparison_feature(
          slug: "local-ci",
          title: "Local CI",
          summary: "Rails 8.1 の Local CI DSL は、cloud CI 以外の軽量な標準導線を提供します。",
          notes_by_version: {
            "7.0" => "CI は GitHub Actions や CircleCI などクラウド設定ファイル中心でした。",
            "8.0" => "新規 app に CI workflow は入りますが、ローカル実行前提の DSL はありませんでした。",
            "8.1.2" => "config/ci.rb と bin/ci によって、developer machine での標準 CI declaration が導入されました。"
          },
          highlights_by_version: {
            "7.0" => "Cloud CI first",
            "8.0" => "Generated CI workflow",
            "8.1.2" => "config/ci.rb + bin/ci"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        comparison_feature(
          slug: "credentials-fetching",
          title: "Command-line Credentials Fetching",
          summary: "Rails 8.1 では CLI から credentials を取り出す deploy 導線が強化されました。",
          notes_by_version: {
            "7.0" => "credentials は Rails 内で読む前提が強く、deploy 連携は custom scripting に寄りがちでした。",
            "8.0" => "Kamal は近くなりましたが、credentials fetch を前提にした CLI story はまだ薄めでした。",
            "8.1.2" => "rails credentials:fetch が紹介され、Kamal secrets と encrypted credentials をつなぎやすくなりました。"
          },
          highlights_by_version: {
            "7.0" => "Custom secret scripting",
            "8.0" => "Kamal introduced",
            "8.1.2" => "rails credentials:fetch"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        comparison_feature(
          slug: "deprecated-associations",
          title: "Deprecated Associations",
          summary: "Rails 8.1 では association 自体を deprecated として宣言し、利用報告できます。",
          notes_by_version: {
            "7.0" => "association の利用抑制や移行警告は、lint や手製 warning に頼ることが多かったです。",
            "8.0" => "標準の association deprecation reporting はまだありませんでした。",
            "8.1.2" => "has_many :posts, deprecated: true のように関連自体へ deprecation を付けられます。"
          },
          highlights_by_version: {
            "7.0" => "Manual migration warnings",
            "8.0" => "No built-in deprecated associations",
            "8.1.2" => "deprecated: true"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        comparison_feature(
          slug: "propshaft",
          title: "Propshaft",
          summary: "asset pipeline story が Sprockets optional から Propshaft default へどう変わったかを整理します。",
          live_demo_available: false,
          notes_by_version: {
            "7.0" => "Sprockets は optional dependency になりましたが、asset pipeline の比較軸では依然 Sprockets 前提が強く残っていました。",
            "8.0" => "新規 app は Propshaft が前提になり、より薄い asset 管理へ寄りました。",
            "8.1.2" => "Propshaft 前提は継続し、importmap / Hotwire と組み合わせた軽量構成を保ちやすいです。"
          },
          status_by_version: {
            "7.0" => "optional",
            "8.0" => "default",
            "8.1.2" => "default"
          },
          files_by_version: {
            "7.0" => [ "app/assets", "config/importmap.rb" ],
            "8.0" => [ "app/assets", "config/importmap.rb" ],
            "8.1.2" => [ "app/assets", "config/importmap.rb" ]
          },
          upgrade_notes_by_version: {
            "7.0" => [ "asset pipeline の置き換え方を先に決めると移行しやすいです。" ],
            "8.0" => [ "Sprockets 前提の helper や assets 配置を見直すと整理しやすいです。" ],
            "8.1.2" => [ "importmap / Turbo / Propshaft の組み合わせを baseline として扱えます。" ]
          },
          code_examples_by_version: {
            "8.0" => [ "link_to asset_path(\"application.css\")" ],
            "8.1.2" => [ "link_to asset_path(\"application.css\")" ]
          },
          operational_notes_by_version: {
            "8.0" => [ "asset 参照先が変わるので、precompile まわりを確認しておくと安心です。" ],
            "8.1.2" => [ "view 側の asset path が単純化されると、保守しやすいです。" ]
          },
          highlights_by_version: {
            "7.0" => "Sprockets becomes optional",
            "8.0" => "Propshaft default",
            "8.1.2" => "Propshaft continues as baseline"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        comparison_feature(
          slug: "kamal",
          title: "Kamal deployments",
          summary: "Kamal が Rails app の deploy story にどう入ってきたかを比較します。",
          live_demo_available: false,
          notes_by_version: {
            "7.0" => "deploy は Capistrano / custom CI/CD / PaaS 依存になりがちでした。",
            "8.0" => "Kamal が Gemfile / config に入り、self-hosted deploy 導線が app に近づきました。",
            "8.1.2" => "Registry-free Kamal deployments が追加され、最初の deploy story がさらに軽くなりました。"
          },
          status_by_version: {
            "7.0" => "custom",
            "8.0" => "default",
            "8.1.2" => "default"
          },
          files_by_version: {
            "7.0" => [],
            "8.0" => [ "config/deploy.yml", "Dockerfile" ],
            "8.1.2" => [ "config/deploy.yml", "Dockerfile" ]
          },
          upgrade_notes_by_version: {
            "7.0" => [ "既存の deploy pipeline をそのまま残すか、Kamal に寄せるかを決める必要があります。" ],
            "8.0" => [ "deploy.yml と secrets の管理を standardize すると運用しやすいです。" ],
            "8.1.2" => [ "registry-free deploy の導線を使うなら、secret と image 配信の流れを確認してください。" ]
          },
          code_examples_by_version: {
            "8.0" => [ "kamal setup", "kamal deploy" ],
            "8.1.2" => [ "kamal setup", "kamal deploy" ]
          },
          operational_notes_by_version: {
            "8.0" => [ "deploy.yml と `.kamal/secrets` を揃えると、環境差分を追いやすいです。" ],
            "8.1.2" => [ "registry-free 構成では、image の流れと secret 配布を確認しておくと安心です。" ]
          },
          highlights_by_version: {
            "7.0" => "Deploy left to app teams",
            "8.0" => "Kamal integrated",
            "8.1.2" => "Registry-free Kamal deploys"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        ),
        comparison_feature(
          slug: "thruster",
          title: "Thruster / production defaults",
          summary: "reverse proxy / acceleration を含む production story の変化を比較します。",
          notes_by_version: {
            "7.0" => "本番向け reverse proxy / acceleration は app 外で組み立てる前提が強めでした。",
            "8.0" => "Thruster が生成時に入り、本番構成の default story が一段増えました。",
            "8.1.2" => "Thruster を含む production defaults は、Kamal や local CI と並ぶ運用導線の一部として理解しやすくなっています。"
          },
          highlights_by_version: {
            "7.0" => "External production proxy choices",
            "8.0" => "Thruster added",
            "8.1.2" => "Production story stays cohesive"
          },
          source_links_by_version: version_links("7.0", "8.0", "8.1.2")
        )
      ]
    end

    def runtime_demos
      all.select(&:runtime_demo?)
    end

    def comparison_cards
      all.select(&:comparison_card?)
    end

    def fetch!(slug)
      all.find { |feature| feature.slug == slug } || raise(ActionController::RoutingError, "Not Found")
    end

    private
      def runtime_feature(**attributes)
        feature(category: "Runtime Demo", demo_type: :runtime_demo, **attributes)
      end

      def comparison_feature(**attributes)
        feature(category: "Platform / Defaults", demo_type: :comparison_card, **attributes)
      end

      def feature(**attributes)
        CatalogFeature.new(
          supported_versions: VersionCatalog.default_compare_keys,
          **attributes
        )
      end

      def version_links(*keys)
        keys.index_with { |key| VersionCatalog.fetch(key).release_notes_url }
      end
  end
end

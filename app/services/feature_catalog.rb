class FeatureCatalog
  class << self
    def all
      @all ||= [
        feature(
          slug: "authentication-generator",
          title: "Authentication generator",
          category: "Runtime Demo",
          summary: "Rails 8 標準の認証生成機能を、サインアップ・ログイン・保護ページで体験できます。",
          rails_72: "標準認証は未同梱で、Devise など外部依存や手作業が前提になりやすかったです。",
          rails_80: "generate authentication で Users / Sessions / Password reset の土台を素早く作れます。",
          highlight: "標準生成・Current session・rate_limit・normalizes をまとめて確認できます。",
          demo_type: :runtime_demo,
          source_url: "https://guides.rubyonrails.org/8_0_release_notes.html"
        ),
        feature(
          slug: "solid-queue",
          title: "Solid Queue",
          category: "Runtime Demo",
          summary: "Active Job の durable backend を UI から enqueue して、状態変化を確認できます。",
          rails_72: "デフォルトは in-process / non-durable queue で、永続ジョブ基盤は別途選定が必要でした。",
          rails_80: "Rails 8 では production default として Solid Queue が同梱され、DB-backed queue を選びやすくなりました。",
          highlight: "bin/jobs と連携して queue 状態を UI 更新できます。",
          demo_type: :runtime_demo,
          source_url: "https://guides.rubyonrails.org/8_0_release_notes.html"
        ),
        feature(
          slug: "solid-cable",
          title: "Solid Cable",
          category: "Runtime Demo",
          summary: "Turbo Streams を使ったライブ更新を、DB-backed cable 前提の比較付きで確認できます。",
          rails_72: "Action Cable は Redis 構成が一般的で、永続的な DB-backed 構成は標準ではありませんでした。",
          rails_80: "Rails 8 の default stack では Solid Cable を選択肢に取り込みやすくなりました。",
          highlight: "メッセージ投稿で Turbo Stream が即時反映されます。",
          demo_type: :runtime_demo,
          source_url: "https://guides.rubyonrails.org/8_0_release_notes.html"
        ),
        feature(
          slug: "solid-cache",
          title: "Solid Cache",
          category: "Runtime Demo",
          summary: "cache hit / miss と再生成を UI で確認でき、Rails 8 の durable cache への流れを掴めます。",
          rails_72: "memory_store や Redis など環境ごとの選定が前提で、 durable cache は標準同梱ではありませんでした。",
          rails_80: "Solid Cache が標準スタックに入り、DB-backed cache を採用しやすくなりました。",
          highlight: "Rails.cache.fetch の結果と store 名をそのまま確認できます。",
          demo_type: :runtime_demo,
          source_url: "https://guides.rubyonrails.org/8_0_release_notes.html"
        ),
        feature(
          slug: "runtime-stack",
          title: "Runtime stack overview",
          category: "Runtime Demo",
          summary: "queue / cable / cache / auth をひとつの画面で見て、Rails 8 の default stack を横断的に把握できます。",
          rails_72: "複数コンポーネントを app 標準としてまとめて比較しづらく、構成差分が分散しがちでした。",
          rails_80: "生成直後から Docker / Kamal / Thruster / Solid 系の文脈が揃い、全体像を掴みやすくなりました。",
          highlight: "今の app が何を有効化しているかを live facts で一覧できます。",
          demo_type: :runtime_demo,
          source_url: "https://guides.rubyonrails.org/upgrading_ruby_on_rails.html"
        ),
        feature(
          slug: "docker-deploy-orientation",
          title: "Docker / deploy orientation",
          category: "Platform / Defaults",
          summary: "Rails 8 の生成物に Dockerfile や deploy 設定が入ることを比較 UI で確認できます。",
          rails_72: "Docker や deploy まわりは追加セットアップや別テンプレートに頼ることが多かったです。",
          rails_80: "新規 app に Dockerfile や Kamal 用設定が含まれ、 deploy への導線が最初から用意されます。",
          highlight: "このリポジトリ自身の生成物を根拠として表示します。",
          demo_type: :comparison_card,
          source_url: "https://guides.rubyonrails.org/8_0_release_notes.html"
        ),
        feature(
          slug: "propshaft",
          title: "Propshaft",
          category: "Platform / Defaults",
          summary: "Sprockets 前提から Propshaft 中心へ移った asset story を UI で整理します。",
          rails_72: "asset pipeline の中心は Sprockets でした。",
          rails_80: "新規 app では Propshaft が前提となり、より薄い asset 管理に寄ります。",
          highlight: "Gem と asset entrypoint の存在から current app の状態を示します。",
          demo_type: :comparison_card,
          source_url: "https://guides.rubyonrails.org/8_0_release_notes.html"
        ),
        feature(
          slug: "kamal-2",
          title: "Kamal 2 integration",
          category: "Platform / Defaults",
          summary: "Kamal 2 を Rails 8 の標準 deploy 導線として比較表示します。",
          rails_72: "deploy は Capistrano / custom CI/CD / PaaS 依存になりがちでした。",
          rails_80: "Kamal が標準 Gemfile / config に入り、 self-hosted deploy 導線が近くなりました。",
          highlight: "config/deploy.yml と .kamal/secrets を UI から参照できます。",
          demo_type: :comparison_card,
          source_url: "https://guides.rubyonrails.org/8_0_release_notes.html"
        ),
        feature(
          slug: "thruster",
          title: "Thruster / production defaults",
          category: "Platform / Defaults",
          summary: "Rails 8 の production bundle に入る Thruster を比較カードで確認できます。",
          rails_72: "本番向け reverse proxy / asset acceleration は app 外で組み立てる前提が強めでした。",
          rails_80: "Thruster が生成時に入り、本番構成の default story が一段増えました。",
          highlight: "Gem / binstub / Dockerfile 前提の整備を UI に反映します。",
          demo_type: :comparison_card,
          source_url: "https://guides.rubyonrails.org/8_0_release_notes.html"
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
      def feature(**attributes)
        CatalogFeature.new(**attributes)
      end
  end
end

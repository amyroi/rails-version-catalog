import Link from "next/link";
import { FeatureCard } from "@/components/FeatureCard";
import { StatCard } from "@/components/StatCard";
import { VersionChip } from "@/components/VersionChip";
import { fetchFeatures, fetchVersions } from "@/lib/api";
import type { CatalogVersion } from "@/lib/types";

export const dynamic = "force-dynamic";

function catalogVersionHeading(versions: CatalogVersion[]) {
  return versions.map((version) => version.label).join(" / ");
}

export default async function Home() {
  const [versions, features] = await Promise.all([fetchVersions(), fetchFeatures()]);
  const versionHeading = catalogVersionHeading(versions);

  return (
    <div className="space-y-10">
      <section className="grid gap-8 lg:grid-cols-[1.4fr_0.8fr]">
        <div className="rounded-3xl border border-sky-100 bg-gradient-to-br from-white via-sky-50 to-indigo-50 p-8 shadow-sm">
          <p className="mb-3 text-sm uppercase tracking-[0.2em] text-sky-600">Rails version catalog</p>
          <h1 className="break-words text-4xl font-semibold tracking-tight text-slate-900">
            {versionHeading} を UI で比較するカタログ
          </h1>
          <p className="mt-4 max-w-3xl text-base leading-7 text-slate-600">
            この app は単一の before / after 比較ではなく、複数メジャーバージョンを横並びで比較できる構造を目指しています。
            初期対応は {versionHeading} で、将来 9.x を追加しやすいデータ構造に寄せています。
          </p>

          <div className="mt-6 flex flex-wrap gap-2">
            {versions.map((version) => (
              <VersionChip key={version.key} version={version} active={version.status === "latest"} />
            ))}
          </div>

          <div className="mt-8 flex flex-wrap gap-3">
            <Link
              href={`/features?compare=${versions.map((version) => version.key).join(",")}`}
              className="rounded-full bg-slate-900 px-5 py-3 text-sm font-semibold text-white hover:bg-slate-700"
            >
              機能一覧を見る
            </Link>
            <Link
              href={`/features/authentication-generator?compare=${versions.map((version) => version.key).join(",")}`}
              className="rounded-full border border-slate-200 bg-white px-5 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-100"
            >
              Authentication demo
            </Link>
            <Link
              href={`/features/active-job-continuations?compare=${versions.map((version) => version.key).join(",")}`}
              className="rounded-full border border-slate-200 bg-white px-5 py-3 text-sm font-semibold text-slate-700 hover:bg-slate-100"
            >
              Active Job Continuations
            </Link>
          </div>
        </div>

        <aside className="grid gap-4">
          <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
            <p className="text-sm text-slate-500">Catalog coverage</p>
            <dl className="mt-4 space-y-4">
              <StatCard label="Interactive demos" value={features.runtimeDemos.length} />
              <StatCard label="Config differences" value={features.comparisonCards.length} />
              <StatCard label="Supported versions" value={versions.length} />
              {/* TODO: Fetch live Rails demo counts from a dedicated endpoint when demo APIs are migrated. */}
              <StatCard label="Queued examples" value="—" />
              <StatCard label="Live messages" value="—" />
            </dl>
          </div>
        </aside>
      </section>

      <section className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="mb-4 flex items-center justify-between gap-4">
            <div>
              <h2 className="text-xl font-semibold text-slate-900">Interactive demos</h2>
              <p className="mt-1 text-sm text-slate-600">現在の Rails runtime 上で、実際に操作して挙動を確認できるデモです。</p>
            </div>
            <span className="text-sm text-slate-500">{features.runtimeDemos.length} cards</span>
          </div>

          <div className="space-y-4">
            {features.runtimeDemos.map((feature) => (
              <FeatureCard
                key={feature.slug}
                feature={feature}
                versions={versions}
                actionLabel="Open"
                variant="preview"
              />
            ))}
          </div>
        </div>

        <div className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
          <div className="mb-4 flex items-center justify-between gap-4">
            <div>
              <h2 className="text-xl font-semibold text-slate-900">Config / platform differences</h2>
              <p className="mt-1 text-sm text-slate-600">{versionHeading} の設定・標準構成・運用差分を比較するカードです。</p>
            </div>
            <span className="text-sm text-slate-500">{features.comparisonCards.length} cards</span>
          </div>

          <div className="space-y-4">
            {features.comparisonCards.map((feature) => (
              <FeatureCard
                key={feature.slug}
                feature={feature}
                versions={versions}
                actionLabel="Compare"
                variant="preview"
              />
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}

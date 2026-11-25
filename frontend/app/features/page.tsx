import { CompareSelector } from "@/components/CompareSelector";
import { FeatureCard } from "@/components/FeatureCard";
import { fetchFeatures, fetchVersions } from "@/lib/api";

export const dynamic = "force-dynamic";

type FeaturesPageProps = {
  searchParams: Promise<{
    compare?: string;
  }>;
};

function selectedKeysFrom(compare: string | undefined, knownKeys: string[]) {
  const requestedKeys = compare?.split(",").map((key) => key.trim()).filter(Boolean) ?? knownKeys;
  const selectedKeys = requestedKeys.filter((key) => knownKeys.includes(key));
  return selectedKeys.length > 0 ? selectedKeys : knownKeys;
}

export default async function FeaturesPage({ searchParams }: FeaturesPageProps) {
  const { compare } = await searchParams;
  const [versions, features] = await Promise.all([fetchVersions(), fetchFeatures()]);
  const selectedVersionKeys = selectedKeysFrom(
    compare,
    versions.map((version) => version.key),
  );
  const selectedVersionLabels = versions
    .filter((version) => selectedVersionKeys.includes(version.key))
    .map((version) => version.label)
    .join(" / ");

  return (
    <div>
      <div className="mb-8">
        <p className="text-sm uppercase tracking-[0.2em] text-sky-600">Feature Index</p>
        <h1 className="mt-3 break-words text-3xl font-semibold tracking-tight text-slate-900">
          {selectedVersionLabels} の差分をカテゴリ別に一覧表示
        </h1>
        <p className="mt-3 max-w-3xl text-slate-600">
          比較対象バージョンを固定配列ではなく selector で扱い、将来 9.x を追加しやすい構造に寄せています。
        </p>
      </div>

      <CompareSelector versions={versions} selectedVersionKeys={selectedVersionKeys} />

      <section className="grid gap-8 lg:grid-cols-2">
        <div className="space-y-4">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <h2 className="text-xl font-semibold">Interactive demos</h2>
              <p className="mt-1 text-sm text-slate-600">現在の Rails runtime 上で確認できる live demo です。</p>
            </div>
            <span className="text-sm text-slate-500">{features.runtimeDemos.length} entries</span>
          </div>

          {features.runtimeDemos.map((feature) => (
            <FeatureCard
              key={feature.slug}
              feature={feature}
              versions={versions}
              selectedVersionKeys={selectedVersionKeys}
              actionLabel="Open feature"
            />
          ))}
        </div>

        <div className="space-y-4">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <h2 className="text-xl font-semibold">Config / platform differences</h2>
              <p className="mt-1 text-sm text-slate-600">{selectedVersionLabels} の設定・標準構成・運用差分を比較します。</p>
            </div>
            <span className="text-sm text-slate-500">{features.comparisonCards.length} entries</span>
          </div>

          {features.comparisonCards.map((feature) => (
            <FeatureCard
              key={feature.slug}
              feature={feature}
              versions={versions}
              selectedVersionKeys={selectedVersionKeys}
              actionLabel="Open comparison"
            />
          ))}
        </div>
      </section>
    </div>
  );
}

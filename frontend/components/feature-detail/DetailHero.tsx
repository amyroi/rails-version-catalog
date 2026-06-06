import Link from "next/link";
import { FeatureBadge } from "@/components/FeatureBadge";
import { VersionChip } from "@/components/VersionChip";
import type { CatalogFeatureDetail, CatalogVersion } from "@/lib/types";

type DetailHeroProps = {
  feature: CatalogFeatureDetail;
  versions: CatalogVersion[];
  selectedVersionKeys: string[];
};

export function DetailHero({ feature, versions, selectedVersionKeys }: DetailHeroProps) {
  const supportedVersions = versions.filter((version) => feature.supportedVersions.includes(version.key));

  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
      <div className="flex flex-col items-start gap-4 lg:flex-row lg:justify-between">
        <div className="max-w-3xl min-w-0">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">Overview</p>
          <div className="mt-3">
            <FeatureBadge demoType={feature.demoType} category={feature.category} />
          </div>
          <h1 className="mt-4 break-words text-3xl font-semibold tracking-tight text-slate-900">{feature.title}</h1>
          <p className="mt-3 text-base leading-7 text-slate-600">{feature.summary}</p>
          <div className="mt-4 flex flex-wrap gap-2">
            {supportedVersions.map((version) => (
              <Link key={version.key} href={`/features/${feature.slug}?compare=${version.key}`}>
                <VersionChip version={version} active={selectedVersionKeys.includes(version.key)} />
              </Link>
            ))}
            <Link
              href={`/features/${feature.slug}?compare=${feature.supportedVersions.join(",")}`}
              className="rounded-full border border-slate-200 bg-slate-900 px-4 py-2 text-xs font-semibold text-white hover:bg-slate-700"
            >
              Show all
            </Link>
          </div>
        </div>

        <div className="rounded-2xl border border-sky-200 bg-sky-50 px-4 py-3 text-sm text-sky-900">
          <p className="font-semibold">Latest highlight</p>
          <p className="mt-1 max-w-sm text-slate-700">{feature.latestHighlight}</p>
        </div>
      </div>
    </section>
  );
}

import Link from "next/link";
import { FeatureBadge } from "@/components/FeatureBadge";
import { VersionChip } from "@/components/VersionChip";
import type { CatalogFeatureSummary, CatalogVersion } from "@/lib/types";

type FeatureCardProps = {
  feature: CatalogFeatureSummary;
  versions: CatalogVersion[];
  selectedVersionKeys?: string[];
  actionLabel: string;
  variant?: "default" | "preview";
};

export function FeatureCard({
  feature,
  versions,
  selectedVersionKeys = versions.map((version) => version.key),
  actionLabel,
  variant = "default",
}: FeatureCardProps) {
  const selectedVersions = versions.filter(
    (version) => selectedVersionKeys.includes(version.key) && feature.supportedVersions.includes(version.key),
  );
  const compare = selectedVersionKeys.join(",");
  const isPreview = variant === "preview";

  const content = (
    <>
      <FeatureBadge demoType={feature.demoType} category={feature.category} />
      <h3 className={isPreview ? "mt-3 text-lg font-semibold text-slate-900" : "mt-4 text-xl font-semibold text-slate-900"}>
        {feature.title}
      </h3>
      <p className={isPreview ? "mt-2 text-sm leading-6 text-slate-600" : "mt-3 text-sm leading-6 text-slate-600"}>
        {feature.summary}
      </p>
      <div className={isPreview ? "mt-3 flex flex-wrap gap-2" : "mt-4 flex flex-wrap gap-2"}>
        {selectedVersions.length > 0 ? (
          selectedVersions.map((version) => (
            <VersionChip key={version.key} version={version} active={version.status === "latest"} />
          ))
        ) : (
          <span className="rounded-full border border-amber-200 bg-amber-50 px-3 py-1.5 text-xs font-semibold text-amber-700">
            No selected versions
          </span>
        )}
      </div>
    </>
  );

  const action = (
    <Link
      href={`/features/${feature.slug}?compare=${compare}`}
      className={
        isPreview
          ? "rounded-full border border-slate-200 bg-white px-4 py-2 text-sm text-slate-700 hover:bg-slate-100"
          : "mt-5 inline-flex rounded-full border border-slate-200 bg-white px-4 py-2 text-sm text-slate-700 hover:bg-slate-100"
      }
    >
      {actionLabel}
    </Link>
  );

  if (isPreview) {
    return (
      <article className="rounded-2xl border border-slate-200 bg-slate-50 p-5">
        <div className="flex flex-col items-start gap-4 sm:flex-row sm:justify-between">
          <div className="min-w-0">{content}</div>
          {action}
        </div>
      </article>
    );
  }

  return (
    <article className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      {content}
      <p className="mt-4 rounded-2xl border border-sky-100 bg-sky-50 p-4 text-sm text-slate-700">
        <strong className="text-slate-900">Latest focus:</strong> {feature.latestHighlight}
      </p>
      {action}
    </article>
  );
}

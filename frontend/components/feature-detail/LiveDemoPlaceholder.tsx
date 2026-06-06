import type { CatalogFeatureDetail } from "@/lib/types";

type LiveDemoPlaceholderProps = {
  feature: CatalogFeatureDetail;
  compareKeys: string[];
};

const RAILS_APP_URL = process.env.NEXT_PUBLIC_RAILS_URL ?? "http://localhost:3000";

export function LiveDemoPlaceholder({ feature, compareKeys }: LiveDemoPlaceholderProps) {
  if (!feature.liveDemoAvailable) {
    return null;
  }

  const railsFeatureUrl = `${RAILS_APP_URL}/features/${feature.slug}?compare=${compareKeys.join(",")}`;

  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">Live demo</p>
          <h2 className="mt-1 text-xl font-semibold text-slate-900">Open the current Rails runtime demo</h2>
        </div>
        <a href={railsFeatureUrl} className="text-sm text-sky-700 underline underline-offset-4">
          Open Rails demo ↗
        </a>
      </div>
      <p className="max-w-3xl text-sm leading-6 text-slate-600">
        Interactive demos are intentionally kept in the Rails app during this migration phase. Use this link to open the live demo while keeping the Next.js comparison page focused on read-only catalog data.
      </p>
    </section>
  );
}

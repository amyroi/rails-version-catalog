import type { CatalogFeatureDemoType } from "@/lib/types";

type FeatureBadgeProps = {
  demoType: CatalogFeatureDemoType;
  category: string;
};

export function FeatureBadge({ demoType, category }: FeatureBadgeProps) {
  const tone = demoType === "runtime_demo" ? "bg-blue-100 text-blue-700" : "bg-violet-100 text-violet-700";

  return <span className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold ${tone}`}>{category}</span>;
}

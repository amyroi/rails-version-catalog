import { notFound } from "next/navigation";
import { AdoptionReadiness } from "@/components/feature-detail/AdoptionReadiness";
import { CodeConfigDiff } from "@/components/feature-detail/CodeConfigDiff";
import { ComparisonMatrix } from "@/components/feature-detail/ComparisonMatrix";
import { DetailHero } from "@/components/feature-detail/DetailHero";
import { LiveDemoPlaceholder } from "@/components/feature-detail/LiveDemoPlaceholder";
import { UpgradeNotes } from "@/components/feature-detail/UpgradeNotes";
import { fetchFeature, fetchVersions } from "@/lib/api";
import { normalizeCompareKeys } from "@/lib/utils";

export const dynamic = "force-dynamic";

type FeatureDetailPageProps = {
  params: Promise<{
    slug: string;
  }>;
  searchParams: Promise<{
    compare?: string;
  }>;
};

export default async function FeatureDetailPage({ params, searchParams }: FeatureDetailPageProps) {
  const [{ slug }, { compare }] = await Promise.all([params, searchParams]);
  const [versions, feature] = await Promise.all([fetchVersions(), fetchFeature(slug)]);

  if (!feature) {
    notFound();
  }

  const selectedVersionKeys = normalizeCompareKeys(compare, feature.supportedVersions);
  const comparisonVersions = versions.filter((version) => selectedVersionKeys.includes(version.key));

  return (
    <div className="space-y-8">
      <DetailHero feature={feature} versions={versions} selectedVersionKeys={selectedVersionKeys} />
      <ComparisonMatrix feature={feature} versions={comparisonVersions} />
      <AdoptionReadiness feature={feature} />
      <CodeConfigDiff feature={feature} versions={comparisonVersions} />
      <LiveDemoPlaceholder feature={feature} compareKeys={selectedVersionKeys} />
      <UpgradeNotes feature={feature} versions={comparisonVersions} />
    </div>
  );
}

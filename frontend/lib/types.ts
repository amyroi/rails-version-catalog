export type CatalogVersionStatus = "supported" | "latest" | "planned";

export type CatalogFeatureDemoType = "runtime_demo" | "comparison_card";

export interface CatalogVersion {
  key: string;
  label: string;
  releaseDate: string;
  status: CatalogVersionStatus;
  releaseNotesUrl: string;
}

export interface CatalogFeatureSummary {
  slug: string;
  title: string;
  category: string;
  summary: string;
  demoType: CatalogFeatureDemoType;
  liveDemoAvailable: boolean;
  supportedVersions: string[];
  latestVersionKey: string;
  latestHighlight: string;
}

export interface CatalogFeaturesIndex {
  runtimeDemos: CatalogFeatureSummary[];
  comparisonCards: CatalogFeatureSummary[];
}

export interface CatalogFeatureDetail extends CatalogFeatureSummary {
  notesByVersion: Record<string, string>;
  highlightsByVersion: Record<string, string>;
  sourceLinksByVersion: Record<string, string>;
  statusByVersion: Record<string, string>;
  filesByVersion: Record<string, string[]>;
  upgradeNotesByVersion: Record<string, string[]>;
  codeExamplesByVersion: Record<string, string[]>;
  operationalNotesByVersion: Record<string, string[]>;
  adoptionWhen: string[];
  adoptionCautions: string[];
  adoptionAlternatives: string[];
  adoptionRequirements: string[];
}

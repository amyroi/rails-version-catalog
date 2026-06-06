import type {
  CatalogFeatureDetail,
  CatalogFeaturesIndex,
  CatalogVersion,
} from "./types";

const RAILS_API_URL = process.env.RAILS_API_URL ?? "http://localhost:3000";

async function fetchJson<T>(path: string): Promise<T> {
  const response = await fetch(`${RAILS_API_URL}${path}`, { cache: "no-store" });

  if (!response.ok) {
    throw new Error(`Rails API request failed: ${response.status}`);
  }

  return response.json() as Promise<T>;
}

export async function fetchVersions(): Promise<CatalogVersion[]> {
  return fetchJson<CatalogVersion[]>("/api/v1/catalog/versions");
}

export async function fetchFeatures(): Promise<CatalogFeaturesIndex> {
  return fetchJson<CatalogFeaturesIndex>("/api/v1/catalog/features");
}

export async function fetchFeature(slug: string): Promise<CatalogFeatureDetail | null> {
  const response = await fetch(
    `${RAILS_API_URL}/api/v1/catalog/features/${encodeURIComponent(slug)}`,
    { cache: "no-store" },
  );

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    throw new Error(`Rails API request failed: ${response.status}`);
  }

  return response.json() as Promise<CatalogFeatureDetail>;
}

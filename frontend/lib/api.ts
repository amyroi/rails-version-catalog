import type {
  CatalogFeatureDetail,
  CatalogFeaturesIndex,
  CatalogVersion,
} from "./types";

const RAILS_API_URL = process.env.RAILS_API_URL ?? "http://localhost:3000";

async function requestCatalog(path: string): Promise<Response> {
  return fetch(`${RAILS_API_URL}${path}`, { cache: "no-store" });
}

async function fetchJson<T>(path: string): Promise<T> {
  const response = await requestCatalog(path);

  if (!response.ok) {
    throw new Error(`Rails API request failed: ${response.status} ${path}`);
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
  const path = `/api/v1/catalog/features/${encodeURIComponent(slug)}`;
  const response = await requestCatalog(path);

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    throw new Error(`Rails API request failed: ${response.status} ${path}`);
  }

  return response.json() as Promise<CatalogFeatureDetail>;
}

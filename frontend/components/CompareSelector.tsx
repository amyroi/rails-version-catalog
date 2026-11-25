"use client";

import { useRouter } from "next/navigation";
import type { CatalogVersion } from "@/lib/types";
import { VersionChip } from "./VersionChip";

type CompareSelectorProps = {
  versions: CatalogVersion[];
  selectedVersionKeys: string[];
};

export function CompareSelector({ versions, selectedVersionKeys }: CompareSelectorProps) {
  const router = useRouter();

  function pushCompare(keys: string[]) {
    router.push(`/features?compare=${keys.join(",")}`);
  }

  return (
    <div className="mb-8 rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <div className="flex flex-wrap items-center gap-3">
        <span className="text-sm font-semibold text-slate-700">Compare versions:</span>
        {versions.map((version) => (
          <button key={version.key} type="button" onClick={() => pushCompare([version.key])}>
            <VersionChip version={version} active={selectedVersionKeys.includes(version.key)} />
          </button>
        ))}
        <button
          type="button"
          onClick={() => pushCompare(versions.map((version) => version.key))}
          className="rounded-full border border-slate-200 bg-slate-900 px-4 py-2 text-xs font-semibold text-white hover:bg-slate-700"
        >
          Show all
        </button>
      </div>
    </div>
  );
}

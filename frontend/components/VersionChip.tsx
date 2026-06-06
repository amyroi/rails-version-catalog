import type { CatalogVersion } from "@/lib/types";

type VersionChipProps = {
  version: Pick<CatalogVersion, "label" | "status">;
  active?: boolean;
};

export function VersionChip({ version, active = false }: VersionChipProps) {
  const tone = active
    ? version.status === "latest"
      ? "border-sky-300 bg-sky-100 text-sky-800"
      : "border-slate-300 bg-slate-900 text-white"
    : "border-slate-200 bg-white text-slate-600";

  return (
    <span className={`inline-flex items-center rounded-full border px-3 py-1.5 text-xs font-semibold ${tone}`}>
      {version.label}
    </span>
  );
}

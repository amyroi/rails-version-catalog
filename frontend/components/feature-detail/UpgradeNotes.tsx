import type { CatalogFeatureDetail, CatalogVersion } from "@/lib/types";

type UpgradeNotesProps = {
  feature: CatalogFeatureDetail;
  versions: CatalogVersion[];
};

export function UpgradeNotes({ feature, versions }: UpgradeNotesProps) {
  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">Upgrade notes</p>
          <h2 className="mt-1 text-xl font-semibold text-slate-900">What to check before upgrading</h2>
        </div>
        <p className="max-w-2xl text-sm leading-6 text-slate-600">
          This section keeps migration guidance separate from the comparison matrix so the upgrade path is easier to scan.
        </p>
      </div>

      <div className="grid gap-4 [grid-template-columns:repeat(auto-fit,minmax(16rem,1fr))]">
        {versions.map((version) => {
          const notes = feature.upgradeNotesByVersion[version.key] ?? [];
          const summary = feature.notesByVersion[version.key];

          return (
            <article key={version.key} className="rounded-2xl border border-slate-200 bg-slate-50 p-5 shadow-sm">
              <h3 className="text-lg font-semibold text-slate-900">{version.label}</h3>
              {notes.length > 0 ? (
                <ul className="mt-3 list-disc space-y-2 pl-5 text-sm leading-6 text-slate-700">
                  {notes.map((note) => (
                    <li key={note}>{note}</li>
                  ))}
                </ul>
              ) : (
                <p className="mt-3 text-sm text-slate-500">No upgrade notes are configured yet.</p>
              )}
              {summary ? (
                <p className="mt-4 rounded-2xl border border-slate-200 bg-white p-4 text-sm leading-6 text-slate-700">{summary}</p>
              ) : null}
            </article>
          );
        })}
      </div>
    </section>
  );
}

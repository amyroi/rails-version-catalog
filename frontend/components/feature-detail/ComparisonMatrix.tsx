import type { CatalogFeatureDetail, CatalogVersion } from "@/lib/types";

type ComparisonMatrixProps = {
  feature: CatalogFeatureDetail;
  versions: CatalogVersion[];
};

function versionCardClass(version: CatalogVersion) {
  return version.status === "latest" ? "border-sky-200 bg-sky-50" : "border-slate-200 bg-white";
}

function listFor(record: Record<string, string[]>, key: string) {
  return record[key] ?? [];
}

export function ComparisonMatrix({ feature, versions }: ComparisonMatrixProps) {
  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <div className="mb-4 flex items-center justify-between">
        <h2 className="text-xl font-semibold text-slate-900">Version comparison matrix</h2>
        <span className="text-sm text-slate-500">{versions.length} versions selected</span>
      </div>

      <div className="grid gap-4 [grid-template-columns:repeat(auto-fit,minmax(16rem,1fr))]">
        {versions.map((version) => {
          const files = listFor(feature.filesByVersion, version.key);
          const upgradeNotes = listFor(feature.upgradeNotesByVersion, version.key);
          const operationalNotes = listFor(feature.operationalNotesByVersion, version.key);
          const sourceLink = feature.sourceLinksByVersion[version.key];

          return (
            <article key={version.key} className={`rounded-2xl border p-5 shadow-sm ${versionCardClass(version)}`}>
              <div className="flex items-start justify-between gap-3">
                <div>
                  <h3 className="text-lg font-semibold text-slate-900">{version.label}</h3>
                  <p className="mt-1 text-xs text-slate-500">{version.releaseDate}</p>
                </div>
                {version.status === "latest" ? (
                  <span className="rounded-full bg-sky-600 px-2.5 py-1 text-xs font-semibold text-white">Latest</span>
                ) : null}
              </div>

              <div className="mt-4 space-y-4 text-sm text-slate-700">
                {feature.statusByVersion[version.key] ? (
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">Status</p>
                    <p className="mt-1">{feature.statusByVersion[version.key]}</p>
                  </div>
                ) : null}

                <div>
                  <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">Summary</p>
                  <p className="mt-1 leading-7 text-slate-700">{feature.notesByVersion[version.key] ?? "No summary available."}</p>
                </div>

                {feature.highlightsByVersion[version.key] ? (
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">Key changes</p>
                    <p className="mt-1 rounded-2xl border border-sky-100 bg-white/70 p-3 leading-7 text-slate-700">
                      {feature.highlightsByVersion[version.key]}
                    </p>
                  </div>
                ) : null}

                {files.length > 0 ? (
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">Files / config involved</p>
                    <ul className="mt-2 space-y-1">
                      {files.map((file) => (
                        <li key={file} className="rounded-xl border border-slate-200 bg-white px-3 py-2 font-mono text-xs text-slate-600">
                          {file}
                        </li>
                      ))}
                    </ul>
                  </div>
                ) : null}

                {upgradeNotes.length > 0 ? (
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">Upgrade impact</p>
                    <ul className="mt-2 list-disc space-y-1 pl-5 text-slate-600">
                      {upgradeNotes.map((note) => (
                        <li key={note}>{note}</li>
                      ))}
                    </ul>
                  </div>
                ) : null}

                {operationalNotes.length > 0 ? (
                  <div>
                    <p className="text-xs font-semibold uppercase tracking-[0.18em] text-slate-500">Notes</p>
                    <ul className="mt-2 list-disc space-y-1 pl-5 text-slate-600">
                      {operationalNotes.map((note) => (
                        <li key={note}>{note}</li>
                      ))}
                    </ul>
                  </div>
                ) : null}

                {sourceLink ? (
                  <a href={sourceLink} target="_blank" rel="noreferrer" className="inline-flex text-sm text-sky-700 underline underline-offset-4">
                    Official source ↗
                  </a>
                ) : null}
              </div>
            </article>
          );
        })}
      </div>
    </section>
  );
}

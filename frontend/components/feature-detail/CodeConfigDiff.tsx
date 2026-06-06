import type { CatalogFeatureDetail, CatalogVersion } from "@/lib/types";

type CodeConfigDiffProps = {
  feature: CatalogFeatureDetail;
  versions: CatalogVersion[];
};

function listFor(record: Record<string, string[]>, key: string) {
  return record[key] ?? [];
}

export function CodeConfigDiff({ feature, versions }: CodeConfigDiffProps) {
  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">Code / config diff</p>
          <h2 className="mt-1 text-xl font-semibold text-slate-900">What changes in files and examples</h2>
        </div>
        <p className="max-w-2xl text-sm leading-6 text-slate-600">
          This section groups the version-specific files, snippets, and operational notes so the comparison stays separate from the live demo below.
        </p>
      </div>

      <div className="grid gap-4 [grid-template-columns:repeat(auto-fit,minmax(16rem,1fr))]">
        {versions.map((version) => {
          const files = listFor(feature.filesByVersion, version.key);
          const examples = listFor(feature.codeExamplesByVersion, version.key);
          const operationalNotes = listFor(feature.operationalNotesByVersion, version.key);

          return (
            <article key={version.key} className="rounded-2xl border border-slate-200 bg-slate-50 p-5 shadow-sm">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <h3 className="text-lg font-semibold text-slate-900">{version.label}</h3>
                  {feature.statusByVersion[version.key] ? (
                    <p className="mt-1 text-sm text-slate-600">Status: {feature.statusByVersion[version.key]}</p>
                  ) : null}
                </div>
                {feature.highlightsByVersion[version.key] ? (
                  <span className="rounded-full bg-white px-2.5 py-1 text-xs font-semibold text-slate-600">Focused</span>
                ) : null}
              </div>

              <div className="mt-4 space-y-4 text-sm text-slate-700">
                <div>
                  <p className="font-semibold text-slate-900">Files / config involved</p>
                  {files.length > 0 ? (
                    <ul className="mt-2 space-y-1">
                      {files.map((file) => (
                        <li key={file} className="rounded-xl border border-slate-200 bg-white px-3 py-2 font-mono text-xs text-slate-600">
                          {file}
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p className="mt-2 text-slate-500">No version-specific file list yet.</p>
                  )}
                </div>

                <div>
                  <p className="font-semibold text-slate-900">Code examples</p>
                  {examples.length > 0 ? (
                    <ul className="mt-2 space-y-1">
                      {examples.map((example) => (
                        <li key={example} className="rounded-xl border border-slate-200 bg-white px-3 py-2 font-mono text-xs text-slate-600">
                          {example}
                        </li>
                      ))}
                    </ul>
                  ) : (
                    <p className="mt-2 text-slate-500">No code example is configured yet.</p>
                  )}
                </div>

                {operationalNotes.length > 0 ? (
                  <div>
                    <p className="font-semibold text-slate-900">Operational notes</p>
                    <ul className="mt-2 list-disc space-y-1 pl-5 text-slate-600">
                      {operationalNotes.map((note) => (
                        <li key={note}>{note}</li>
                      ))}
                    </ul>
                  </div>
                ) : null}
              </div>
            </article>
          );
        })}
      </div>
    </section>
  );
}

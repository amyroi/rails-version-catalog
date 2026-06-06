import type { CatalogFeatureDetail } from "@/lib/types";

type AdoptionReadinessProps = {
  feature: CatalogFeatureDetail;
};

type ReadinessGroup = {
  heading: string;
  items: string[];
};

export function AdoptionReadiness({ feature }: AdoptionReadinessProps) {
  const groups: ReadinessGroup[] = [
    { heading: "When to consider", items: feature.adoptionWhen },
    { heading: "Cautions", items: feature.adoptionCautions },
    { heading: "Alternatives", items: feature.adoptionAlternatives },
    { heading: "Runtime requirements", items: feature.adoptionRequirements },
  ].filter((group) => group.items.length > 0);

  if (groups.length === 0) {
    return null;
  }

  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">Adoption readiness</p>
          <h2 className="mt-1 text-xl font-semibold text-slate-900">What to consider before adopting</h2>
        </div>
        <p className="max-w-2xl text-sm leading-6 text-slate-600">
          This section keeps feature-level adoption judgment separate from version-specific upgrade and operational notes.
        </p>
      </div>

      <div className="grid gap-4 [grid-template-columns:repeat(auto-fit,minmax(14rem,1fr))]">
        {groups.map((group) => (
          <article key={group.heading} className="rounded-2xl border border-slate-200 bg-slate-50 p-5 shadow-sm">
            <h3 className="text-base font-semibold text-slate-900">{group.heading}</h3>
            <ul className="mt-3 list-disc space-y-2 pl-5 text-sm leading-6 text-slate-700">
              {group.items.map((item) => (
                <li key={item}>{item}</li>
              ))}
            </ul>
          </article>
        ))}
      </div>
    </section>
  );
}

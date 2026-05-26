export default function Home() {
  return (
    <main className="min-h-screen px-6 py-12 sm:px-10 lg:px-16">
      <section className="mx-auto max-w-3xl rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
        <p className="text-sm font-semibold uppercase tracking-wide text-slate-500">
          Next.js Frontend
        </p>
        <h1 className="mt-3 text-3xl font-bold tracking-tight text-slate-950 sm:text-4xl">
          Rails Version Catalog
        </h1>
        <p className="mt-4 text-base leading-7 text-slate-600">
          This is a placeholder home page for the Next.js 15 App Router frontend.
          Rails API integration will be added in a later change.
        </p>
        <div className="mt-6 rounded-lg bg-slate-50 p-4 text-sm text-slate-600">
          Development server: <code className="font-mono text-slate-900">localhost:3001</code>
        </div>
      </section>
    </main>
  );
}

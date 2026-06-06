"use client";

export default function Error({ reset }: { error: Error & { digest?: string }; reset: () => void }) {
  return (
    <section className="rounded-3xl border border-rose-200 bg-rose-50 p-8 shadow-sm">
      <p className="text-sm font-semibold uppercase tracking-[0.2em] text-rose-600">Error</p>
      <h1 className="mt-3 text-2xl font-semibold text-rose-950">Catalog data を読み込めませんでした</h1>
      <p className="mt-3 max-w-2xl text-sm leading-6 text-rose-800">
        Rails API が起動しているか、`RAILS_API_URL` が正しいか確認してください。
      </p>
      <button
        type="button"
        onClick={reset}
        className="mt-6 rounded-full bg-rose-900 px-5 py-3 text-sm font-semibold text-white hover:bg-rose-700"
      >
        再読み込み
      </button>
    </section>
  );
}

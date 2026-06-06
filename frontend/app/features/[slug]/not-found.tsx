import Link from "next/link";

export default function FeatureNotFound() {
  return (
    <section className="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
      <p className="text-sm font-semibold uppercase tracking-[0.2em] text-slate-500">Not found</p>
      <h1 className="mt-3 text-3xl font-semibold tracking-tight text-slate-900">Feature が見つかりません</h1>
      <p className="mt-3 max-w-2xl text-sm leading-6 text-slate-600">
        指定された feature slug は catalog に存在しないか、まだ Next.js 側に公開されていません。
      </p>
      <Link
        href="/features"
        className="mt-6 inline-flex rounded-full bg-slate-900 px-5 py-3 text-sm font-semibold text-white hover:bg-slate-700"
      >
        Feature Index に戻る
      </Link>
    </section>
  );
}

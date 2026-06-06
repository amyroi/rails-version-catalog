import Link from "next/link";
import { NavLink } from "./NavLink";

const DEFAULT_COMPARE_QUERY = "8.0.4,8.1.3";

export function Header() {
  return (
    <header className="border-b border-slate-200 bg-white/95 backdrop-blur">
      <div className="mx-auto flex max-w-7xl flex-col gap-4 px-6 py-4 lg:flex-row lg:items-center lg:justify-between">
        <div className="min-w-0">
          <Link
            href="/"
            className="block break-words text-lg font-semibold tracking-tight text-slate-900"
          >
            Rails Multi-Version Feature Catalog
          </Link>
          <p className="break-words text-sm text-slate-500">
            Rails 7.0 / Rails 8.0 / Rails 8.1.3 を UI で比較し、将来の 9.x
            追加にも備えるカタログです。
          </p>
        </div>

        <nav className="flex flex-wrap items-center gap-3 text-sm" aria-label="Primary navigation">
          <NavLink href="/">Overview</NavLink>
          <NavLink href={`/features?compare=${DEFAULT_COMPARE_QUERY}`}>All Features</NavLink>
          {/* Auth nav: Phase 7 */}
          {/* <NavLink href="/session/new" variant="primary">Sign in</NavLink> */}
          {/* <NavLink href="/users/new">Sign up</NavLink> */}
        </nav>
      </div>
    </header>
  );
}

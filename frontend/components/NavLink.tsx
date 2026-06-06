import Link from "next/link";
import type { ComponentProps } from "react";

type NavLinkProps = ComponentProps<typeof Link> & {
  variant?: "default" | "primary";
};

export function NavLink({ className = "", variant = "default", ...props }: NavLinkProps) {
  const variantClass =
    variant === "primary"
      ? "border-sky-200 bg-sky-50 text-sky-700 hover:bg-sky-100"
      : "border-slate-200 bg-white text-slate-700 hover:bg-slate-100";

  return (
    <Link
      className={`rounded-full border px-4 py-2 transition-colors ${variantClass} ${className}`}
      {...props}
    />
  );
}

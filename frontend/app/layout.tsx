import type { Metadata } from "next";
import { Header } from "@/components/Header";
import "./globals.css";

export const metadata: Metadata = {
  title: "Rails Multi-Version Feature Catalog",
  description: "Next.js frontend for the Rails multi-version feature catalog.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body className="overflow-x-hidden bg-slate-50 text-slate-900">
        <Header />
        <main className="mx-auto max-w-7xl px-6 py-8">{children}</main>
      </body>
    </html>
  );
}

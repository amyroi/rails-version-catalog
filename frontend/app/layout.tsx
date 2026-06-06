import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Rails Version Catalog",
  description: "Frontend placeholder for the Rails multi-version feature catalog.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  );
}

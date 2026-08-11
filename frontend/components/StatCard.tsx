type StatCardProps = {
  label: string;
  value: number | string;
};

export function StatCard({ label, value }: StatCardProps) {
  return (
    <div className="flex items-center justify-between">
      <dt className="text-slate-600">{label}</dt>
      <dd className="text-2xl font-semibold text-slate-900">{value}</dd>
    </div>
  );
}

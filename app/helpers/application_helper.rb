module ApplicationHelper
  def compare_query_value(keys)
    Array(keys).join(",")
  end

  def catalog_version_heading(keys = VersionCatalog.default_compare_keys)
    VersionCatalog.normalize(keys).map { |key| VersionCatalog.fetch(key)&.label }.compact.join(" / ")
  end

  def version_chip_classes(version, active: false)
    base = "inline-flex items-center rounded-full border px-3 py-1.5 text-xs font-semibold transition"
    tone = if active
      version.latest? ? "border-sky-300 bg-sky-100 text-sky-800" : "border-slate-300 bg-slate-900 text-white"
    else
      "border-slate-200 bg-white text-slate-600 hover:bg-slate-100"
    end

    "#{base} #{tone}"
  end

  def version_card_classes(version)
    version.latest? ? "border-sky-200 bg-sky-50" : "border-slate-200 bg-white"
  end

  def feature_badge_classes(feature)
    base = "inline-flex items-center rounded-full px-3 py-1 text-xs font-semibold"
    tone = feature.runtime_demo? ? "bg-blue-100 text-blue-700" : "bg-violet-100 text-violet-700"
    "#{base} #{tone}"
  end

  def queue_status_classes(queue_run)
    base = "inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold"

    tone = case queue_run.status
    when "completed"
      "bg-emerald-100 text-emerald-700"
    when "working"
      "bg-amber-100 text-amber-700"
    when "failed"
      "bg-rose-100 text-rose-700"
    else
      "bg-slate-200 text-slate-700"
    end

    "#{base} #{tone}"
  end

  def cache_state_classes(hit)
    hit ? "bg-emerald-100 text-emerald-700" : "bg-amber-100 text-amber-700"
  end
end

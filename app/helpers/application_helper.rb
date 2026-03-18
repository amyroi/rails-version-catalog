module ApplicationHelper
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

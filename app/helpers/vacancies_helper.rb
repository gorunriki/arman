module VacanciesHelper
  EDUCATION_LEVEL_LABELS = {
    "bachelor" => "Sarjana",
    "diploma" => "Diploma",
    "profession" => "Profesi"
  }.freeze

  def education_level_label(level)
    EDUCATION_LEVEL_LABELS.fetch(level.to_s.downcase, level.to_s.humanize)
  end
end

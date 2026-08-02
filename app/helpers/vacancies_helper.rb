module VacanciesHelper
  EDUCATION_LEVEL_LABELS = {
    "bachelor" => "Sarjana",
    "diploma" => "Diploma",
    "profession" => "Profesi"
  }.freeze

  DAY_LABELS = {
    "monday" => "Senin",
    "tuesday" => "Selasa",
    "wednesday" => "Rabu",
    "thursday" => "Kamis",
    "friday" => "Jumat",
    "saturday" => "Sabtu",
    "sunday" => "Minggu"
  }.freeze

  def education_level_label(level)
    EDUCATION_LEVEL_LABELS.fetch(level.to_s.downcase, level.to_s.humanize)
  end

  def day_label(day)
    DAY_LABELS.fetch(day.to_s.downcase, day.to_s.humanize)
  end
end

module OrganizersHelper
  ORGANIZER_TYPE_LABELS = {
    "government" => "Pemerintah",
    "company" => "Perusahaan"
  }.freeze

  def organizer_type_label(type)
    ORGANIZER_TYPE_LABELS.fetch(type.to_s.downcase, "Penyelenggara")
  end

  def organizer_initials(name)
    name.to_s.scan(/[[:alnum:]]+/).first(2).filter_map { |word| word.first&.upcase }.join.presence || "?"
  end
end

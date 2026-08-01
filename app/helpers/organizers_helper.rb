module OrganizersHelper
  ORGANIZER_TYPE_LABELS = {
    "government" => "Pemerintah",
    "company" => "Perusahaan"
  }.freeze

  def organizer_type_label(type)
    ORGANIZER_TYPE_LABELS.fetch(type.to_s.downcase, "Penyelenggara")
  end
end

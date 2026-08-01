class Organizer < ApplicationRecord
  belongs_to :city, optional: true
  has_many :vacancies, dependent: :destroy
  validates :name, presence: true

  def total_vacancies
    vacancies_count
  end

  # Total vacancy yang sedang aktif
  def total_active_vacancies
    return self[:active_vacancies_count] if has_attribute?(:active_vacancies_count)

    vacancies.active.count
  end
end

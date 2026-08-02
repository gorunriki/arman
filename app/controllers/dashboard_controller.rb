class DashboardController < ApplicationController
  CACHE_KEY = "dashboard/statistics/v2"

  def index
    data = Rails.cache.fetch(CACHE_KEY, expires_in: 1.hour) { dashboard_data }

    @stats = data.fetch(:stats)
    @organizers_by_type = data.fetch(:organizers_by_type)
    @quota_by_type = data.fetch(:quota_by_type)
    @top_cities = data.fetch(:top_cities)
    @top_study_programs = data.fetch(:top_study_programs)
  end

  private

  def dashboard_data
    vacancy_count, requested_quota, approved_quota, applications = Vacancy.pick(
      Arel.sql("COUNT(*)"),
      Arel.sql("COALESCE(SUM(quantity_needed), 0)"),
      Arel.sql("COALESCE(SUM(approved_quantity), 0)"),
      Arel.sql("COALESCE(SUM(total_applications), 0)")
    )

    {
      stats: {
        organizers: Organizer.count,
        vacancies: vacancy_count,
        requested_quota: requested_quota,
        approved_quota: approved_quota,
        applications: applications,
        covered_cities: Vacancy.where.not(city_id: nil).distinct.count(:city_id)
      },
      organizers_by_type: organizers_by_type,
      quota_by_type: quota_by_type,
      top_cities: top_cities,
      top_study_programs: top_study_programs
    }
  end

  def organizers_by_type
    Organizer.group(:organizable_type).count.to_h do |type, count|
      [ organizer_type_name(type), count ]
    end
  end

  def quota_by_type
    rows = Vacancy
      .joins(:organizer)
      .group("organizers.organizable_type")
      .pluck(
        "organizers.organizable_type",
        Arel.sql("SUM(vacancies.quantity_needed)"),
        Arel.sql("SUM(vacancies.approved_quantity)")
      )

    [
      { name: "Diajukan", data: rows.to_h { |type, requested, _approved| [ organizer_type_name(type), requested ] } },
      { name: "Disetujui", data: rows.to_h { |type, _requested, approved| [ organizer_type_name(type), approved ] } }
    ]
  end

  def top_cities
    Vacancy
      .joins(:city)
      .group("cities.name")
      .order(Arel.sql("COUNT(vacancies.id) DESC"))
      .limit(10)
      .count
  end

  def top_study_programs
    StudyProgram
      .joins(:vacancies)
      .group(:name)
      .order(Arel.sql("COUNT(vacancies.id) DESC"))
      .limit(10)
      .count
  end

  def organizer_type_name(type)
    {
      "government" => "Pemerintah",
      "company" => "Perusahaan"
    }.fetch(type.to_s.downcase, "Lainnya")
  end
end

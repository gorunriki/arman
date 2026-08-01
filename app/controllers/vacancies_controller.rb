class VacanciesController < ApplicationController
  EDUCATION_LEVELS = %w[bachelor diploma profession].freeze

  def index
    vacancies = filtered_vacancies
      .preload(:city, :primary_study_program, organizer: :city)
      .order(sort_order)

    @pagy, @vacancies = pagy(vacancies, limit: 12)
    @total_vacancies = Vacancy.active.count
    @cities = City.where(id: Vacancy.active.where.not(city_id: nil).select(:city_id)).order(:name)
    @education_levels = EDUCATION_LEVELS
    @filters_active = search_term.present? || params[:city_id].present? || education_level.present? || params[:sort].present?
  end

  private

  def filtered_vacancies
    scope = Vacancy.active

    if search_term.present?
      pattern = "%#{Vacancy.sanitize_sql_like(search_term)}%"
      scope = scope.joins(:organizer).where(
        "vacancies.position_name ILIKE :pattern OR organizers.name ILIKE :pattern",
        pattern: pattern
      )
    end

    scope = scope.where(city_id: params[:city_id]) if valid_uuid?(params[:city_id])
    scope = scope.where("?::varchar = ANY(vacancies.education_levels)", education_level) if education_level.present?
    scope
  end

  def search_term
    @search_term ||= params[:q].to_s.strip.first(100)
  end

  def education_level
    @education_level ||= EDUCATION_LEVELS.include?(params[:education_level]) ? params[:education_level] : nil
  end

  def sort_order
    {
      "oldest" => { published_at: :asc, position_name: :asc },
      "applications_desc" => { total_applications: :desc, published_at: :desc },
      "quota_desc" => { quantity_needed: :desc, published_at: :desc }
    }.fetch(params[:sort], { published_at: :desc, position_name: :asc })
  end

  def valid_uuid?(value)
    value.to_s.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)
  end
end

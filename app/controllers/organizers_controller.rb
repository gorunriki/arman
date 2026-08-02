class OrganizersController < ApplicationController
  def index
    organizers = filtered_organizers
      .preload(:city)
      .order(sort_order)

    @pagy, @organizers = pagy(organizers, limit: 10)
    @total_organizers = Organizer.count
    @cities = City.where(id: Organizer.where.not(city_id: nil).select(:city_id)).order(:name)
    @organizer_types = Organizer.where.not(organizable_type: [ nil, "" ]).distinct.order(:organizable_type).pluck(:organizable_type)
    @selected_organizer_type = normalized_organizer_type
    @filters_active = search_term.present? || params[:city_id].present? || normalized_organizer_type.present? || params[:sort].present?
  end

  def show
    @organizer = Organizer.preload(:city).find(params[:id])
    vacancies = @organizer.vacancies
      .preload(:city, :primary_study_program)
      .order(published_at: :desc, position_name: :asc)

    @pagy, @vacancies = pagy(vacancies, limit: 12)
  end

  private

  def filtered_organizers
    scope = Organizer.all
    scope = scope.where("organizers.name ILIKE ?", "%#{Organizer.sanitize_sql_like(search_term)}%") if search_term.present?
    scope = scope.where(city_id: params[:city_id]) if valid_uuid?(params[:city_id])
    scope = scope.where(organizable_type: normalized_organizer_type) if normalized_organizer_type.present?
    scope
  end

  def search_term
    @search_term ||= params[:q].to_s.strip.first(100)
  end

  def sort_order
    {
      "name_desc" => { name: :desc },
      "vacancies_desc" => { vacancies_count: :desc, name: :asc },
      "vacancies_asc" => { vacancies_count: :asc, name: :asc }
    }.fetch(params[:sort], { name: :asc })
  end

  def normalized_organizer_type
    @normalized_organizer_type ||= params[:organizer_type].to_s.downcase.presence
  end

  def valid_uuid?(value)
    value.to_s.match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)
  end
end

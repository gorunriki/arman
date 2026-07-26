class OrganizersController < ApplicationController
  def index
    query = Organizer.includes(:city).left_joins(:vacancies).select("organizers.*, COUNT(vacancies.id) AS total_vacancies").group("organizers.id")
    @pagy, @organizers = pagy(query)

    @total_organizers = @pagy.count
  end
end

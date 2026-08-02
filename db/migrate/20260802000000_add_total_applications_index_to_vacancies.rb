class AddTotalApplicationsIndexToVacancies < ActiveRecord::Migration[8.1]
  def change
    add_index :vacancies, :total_applications
  end
end

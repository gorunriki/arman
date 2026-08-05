class AllowNegativeOpportunityScores < ActiveRecord::Migration[8.0]
  def change
    remove_check_constraint :vacancies,
                            name: "opportunity_score_non_negative",
                            if_exists: true
  end
end

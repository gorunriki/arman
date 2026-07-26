class CreateStudyPrograms < ActiveRecord::Migration[8.1]
  def change
    create_table :study_programs, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end

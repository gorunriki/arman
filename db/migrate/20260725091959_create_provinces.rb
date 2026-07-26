class CreateProvinces < ActiveRecord::Migration[8.1]
  def change
    create_table :provinces, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end

class CreateCities < ActiveRecord::Migration[8.1]
  def change
    create_table :cities, id: :uuid do |t|
      t.references :province, type: :uuid, foreign_key: true

      t.string :name
      t.string :city_type
      t.string :postal_code

      t.timestamps
    end
  end
end

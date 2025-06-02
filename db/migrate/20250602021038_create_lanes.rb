class CreateLanes < ActiveRecord::Migration[7.1]
  def change
    create_table :lanes do |t|
      t.references :race, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.integer :lane_number
      t.integer :student_place

      t.timestamps
    end
  end
end

class Lane < ApplicationRecord
  belongs_to :race
  belongs_to :student

  validates :race, presence: true
  validates :student, presence: true
  validates :lane_number, presence: true, numericality: { only_integer: true }
  validates :student_place, numericality: { only_integer: true, allow_nil: true }

  # This validation does not create a uniqueness constraint in the database
  # so a scenario can occur whereby two different database connections create two records with the same value for a column that you intended to be unique.
  validates :student_id, uniqueness: { scope: :race_id, message: "can only be assigned to one lane per race" }
end

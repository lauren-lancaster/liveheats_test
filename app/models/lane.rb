class Lane < ApplicationRecord
  belongs_to :race
  belongs_to :student

  validates :race, presence: true
  validates :student, presence: true
  validates :lane_number, presence: true, numericality: { only_integer: true }
  validates :student_place, numericality: { only_integer: true, allow_nil: true }
end

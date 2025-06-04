class Race < ApplicationRecord
  has_many :lanes, dependent: :destroy # lanes are deleted if the race is deleted
  has_many :students, through: :lanes

  # TODO: move to a constants file
  MINIMUM_CAPACITY = 2
  RACE_STATUS = ["SETUP", "CONFIRMED", "COMPLETE"].freeze # more states can be added such as cancelled

  validates :name, presence: true
  validates :status, inclusion: { in: RACE_STATUS }
  validate :minimum_capacity_achieved, if: -> { status == "CONFIRMED" }

  after_initialize :set_default_status, if: :new_record?

  # Calculates the next available lane number for the current race
  def next_available_lane_number
    (self.lanes.maximum(:lane_number) || 0) + 1
  end

  def available_students_for_registration
    participating_student_ids = self.lanes.pluck(:student_id)
    Student.where.not(id: participating_student_ids).order(:name)
  end

  private

  def set_default_status
    self.status ||= "SETUP" # Set default only if status is nil
  end

  def minimum_capacity_achieved
    unless self.lanes.count >= MINIMUM_CAPACITY # if there are less than 2 participants
      errors.add(:base, "must have at least #{MINIMUM_CAPACITY} participants to be ready.")
    end
  end
end

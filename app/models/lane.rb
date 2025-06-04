class Lane < ApplicationRecord
  belongs_to :race
  belongs_to :student

  validates :race, presence: true
  validates :student, presence: true
  validates :lane_number, presence: true, numericality: { only_integer: true }
  validates :student_place, numericality: { only_integer: true, greater_than: 0, allow_nil: true }

  # This validation does not create a uniqueness constraint in the database
  # so a scenario can occur whereby two different database connections create two records with the same value for a column that you intended to be unique.
  validates :student_id, uniqueness: { scope: :race_id, message: "can only be assigned to one lane per race" }
  validates :lane_number, uniqueness: { scope: :race_id, message: "can only have one student" }

  validate :student_place_order_validation, on: :update, if: :student_place_being_set?

  private

  def student_place_being_set?
    student_place.present? 
  end

  def student_place_order_validation
    return unless race

    new_student_place = self.student_place 
    
    other_lanes_student_places = race.lanes.select do |lane|
      # Exclude self, lanes marked for destruction, and lanes where student_place is not set (nil or blank)
      lane.id != self.id && !lane.marked_for_destruction? && lane.student_place.present?
    end.map(&:student_place)

    all_student_places_for_race = (other_lanes_student_places + [new_student_place]).sort
    
    current_place_index = all_student_places_for_race.index(new_student_place)

    if current_place_index.nil?
      errors.add(:student_place, "could not be found in the race's place list for validation.")
      return
    end

    valid_student_place = false

    if current_place_index == 0
      valid_student_place = (new_student_place == 1) # index + 1
    else
      place_before = all_student_places_for_race[current_place_index - 1]
      
      # Condition A: The new place is equal to the place before it (a tie).
      is_a_tie = (new_student_place == place_before)
      
      # Condition B: The new place is equal to its 0-based index + 1.
      matches_index_plus_one = (new_student_place == current_place_index + 1)
      
      valid_student_place = is_a_tie || matches_index_plus_one
    end

    unless valid_student_place
      error_detail = "Given place #{new_student_place} at sorted index #{current_place_index} (0-based). "
      if current_place_index > 0
        error_detail += "The final places in the race must be entered without gaps, i.e. 1, 2, 4 should not be
                        possible to be entered."
        error_detail += "In the case of a tie, the next available place should skip the number of tied athletes, for
                        example in the case of 2 ties for 1st, the next athlete cannot place 2nd but instead needs
                        to place 3rd (1, 1, 3). In the case of 3 ties for 1st, the next athlete must place 4th (1, 1, 1,4)"
        error_detail += "Given place should be equal to #{place_before} OR #{current_place_index + 1}"
      else
        error_detail += "As the first place, it must be 1."
      end
      errors.add(:student_place, "is not valid. #{error_detail}")
    end
  end
end

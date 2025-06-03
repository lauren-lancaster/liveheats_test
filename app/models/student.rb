class Student < ApplicationRecord
  # TODO: has many: lanes
  # TODO: invalid student error message

  validates :name, presence: true
end

class Student < ApplicationRecord
  # TODO: has many: lanes

  validates :name, presence: true
end

class Race < ApplicationRecord
  # TODO: has_many lanes

  validates :name, presence: true
end

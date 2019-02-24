class Event < ApplicationRecord
  belongs_to :calendar
  has_many :participants
  has_many :users, through: :participants
  enum recurring_type: [:daily, :weekly]
end
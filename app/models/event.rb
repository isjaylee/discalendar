class Event < ApplicationRecord
  belongs_to :user
  belongs_to :calendar
  has_many :participants, dependent: :destroy
  has_many :users, through: :participants
  enum recurring_type: [:daily, :weekly]
end
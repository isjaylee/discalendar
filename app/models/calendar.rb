class Calendar < ApplicationRecord
  belongs_to :user
  has_many :events

  validate :user_has_existing_calendar_name

  private
    def user_has_existing_calendar_name
      if Calendar.where(user: user, name: name).exists?
        errors.add(:name, :calendar_exists, message: "Calendar already exists with that name.")
      end
    end
end
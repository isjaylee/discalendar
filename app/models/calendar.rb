class Calendar < ApplicationRecord
  belongs_to :user
  has_many :events, dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :users, through: :members

  validate :user_has_existing_calendar_name

  after_create :add_owner_as_member

  def add_owner_as_member
    self.users << user
  end

  private
    def user_has_existing_calendar_name
      if Calendar.where(user: user, name: name).exists?
        errors.add(:name, :calendar_exists, message: "Calendar already exists with that name.")
      end
    end
end
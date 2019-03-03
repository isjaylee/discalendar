class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :omniauthable,
         omniauth_providers: [:discord]

  validates :uid, uniqueness: true
  validates :username, length: { in: 2..255, allow_nil: false }
  has_many :calendars
  has_many :participants
  has_many :events, through: :participants
  has_many :members
  has_many :events, through: :members

  def self.from_omniauth(auth)
    username = "#{auth.extra.raw_info.username}#{auth.extra.raw_info.discriminator}"
    return if username.empty?
    user = where(uid: auth.uid).first_or_create

    attributes = {
      username: username,
      email: (auth.info.email if auth.info.email.present?),
      name: auth.info.name,
      password: Devise.friendly_token[0, 20],
      provider: auth.provider
    }

    user.update_attributes(attributes)
    user
  end

  def events
    Event.where(user: self)
  end
end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :omniauthable,
         omniauth_providers: [:discord]

  validates :username, uniqueness: true
  has_many :calendars
  has_many :participants
  has_many :events, through: :participants
  has_many :members
  has_many :events, through: :members

  def self.from_omniauth(auth)
    username = "#{auth.extra.raw_info.username}#{auth.extra.raw_info.discriminator}"
    user = where(uid: auth.uid).first_or_create
    user.update_attributes(
      username: username,
      email: auth.info.email,
      name: auth.info.name,
      password: Devise.friendly_token[0, 20],
      provider: auth.provider
    )
    user
  end
end

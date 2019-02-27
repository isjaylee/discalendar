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
    where(provider: auth.provider, uid: auth.uid, username: auth.extra.raw_info.username).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.image = auth.info.image
    end
  end
end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :omniauthable # :registerable,
         # :recoverable, :rememberable, :trackable, :validatable
 
  has_many :articles, inverse_of: :user

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: true
  validates :screen_name, presence: true
  validates :name, presence: true

  after_destroy do
    Article.where(user: self).delete_all
  end

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil) 
    user = User.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    if user.new_record?
      user.update_attributes!(
        screen_name:auth.info.nickname,
        name:auth.info.name,
        icon_url:auth.info.image,
        provider:auth.provider,
        uid:auth.uid,
        password:Devise.friendly_token[0,20]
      )
    end
    user
  end
end

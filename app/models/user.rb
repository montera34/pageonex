require 'digest/md5'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  has_many :highlighted_areas

	has_many :owned_threads, :class_name => "Threadx",:foreign_key => :owner_id

	has_many :threadx_collaborators
	has_many :coll_threads, :through => :threadx_collaborators, :source => :threadx

  validate :ok_username

  # we want to prevent users from creating certain usernames
  def ok_username
    if ['pageonex', 'admin', 'user', 'thread', 'example', 'blog', 'timeline', 'documentation', 'wiki', 'about', 'frontpage'].include? self.username
      errors.add(:userame, "isn't valid")
    end 
  end

  def hash
    return Digest::MD5.hexdigest(self.email.downcase)
  end

  def self.hashes
    emails = User.select("username, email").all
    result = {}
    hashes = emails.map do |u|
      digest = Digest::MD5.hexdigest(u['email'].downcase)
      result[u['username']] = digest
    end
    return result
  end

end

class Threadx < ActiveRecord::Base

	has_many :media_threadxes
	has_many :media, :through => :media_threadxes

	belongs_to :owner, :class_name => "User"

	has_many :threadx_collaborators
	has_many :users, :through => :threadx_collaborators

	has_many :codes
	has_many :threadx_images
	
end

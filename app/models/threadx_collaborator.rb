class ThreadxCollaborator < ActiveRecord::Base
	belongs_to :threadx
	belongs_to :user
end

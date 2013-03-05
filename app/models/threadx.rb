class Threadx < ActiveRecord::Base

	has_many :media_threadxes
	has_many :media, :through => :media_threadxes

	belongs_to :owner, :class_name => "User"

	has_many :threadx_collaborators
	has_many :users, :through => :threadx_collaborators

	has_many :codes

	has_many :highlighted_areas

	validates :thread_display_name, :start_date, :end_date, :description , :category, :presence => true
	
	# this validation runs when a user create a thread, and checks if the user has a thread with same name or not
	validate :existing_thread, :on => :create

	def existing_thread
		current_user = User.find owner_id
		thread = current_user.owned_threads.find_by_thread_display_name thread_display_name
		existed_thread = ( thread == nil )
		unless existed_thread
			unless thread.thread_name == nil
				errors.add(:thread_display_name, "is already exist")
			end
		end
	end
	
	def images
		Image.by_media(medium_ids).by_date(start_date..end_date)
	end

	def self.url_safe_name display_name
		display_name.parameterize.underscore
	end

end

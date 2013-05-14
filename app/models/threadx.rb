class Threadx < ActiveRecord::Base

	MAX_IMAGES = 500

	self.per_page = 20

	has_many :media_threadxes
	has_many :media, :through => :media_threadxes

	belongs_to :owner, :class_name => "User"

	has_many :threadx_collaborators
	has_many :users, :through => :threadx_collaborators

	has_many :codes
	has_many :highlighted_areas, :through => :codes
	
	has_many :coded_pages

	validates :thread_name, :thread_display_name, :start_date, :end_date, :description , :category, :presence => true
	
	# this validation runs when a user create a thread, and checks if the user has a thread with same name or not
	validate :existing_thread, :on => :create

	validate :not_too_many_images
	
	validate :starts_before_ends

	validates :thread_name, :uniqueness=>true

	before_validation { |t| 
		t.thread_name = t.thread_display_name if t.thread_name.nil? or t.thread_name.empty?
		t.thread_name = t.thread_name.to_url 
	}

	# for now, default to sort by most recent first
	default_scope order('created_at DESC')

	def link_url
		'/'+owner.username.split(' ').join('_')+'/'+thread_name+'/'
	end

  def starts_before_ends
    if end_date < start_date
      errors.add(:end_date, 'must be after start date')
    end 
  end

	# workaround for bug #59
	def not_too_many_images
		media_count = media.length
		days = end_date - start_date
		number_of_images = media_count * days
		if ((media_count * days) > MAX_IMAGES)
			errors.add(:start_date, "This range is too big.  Your number of total images must be below " + MAX_IMAGES.to_s + ". Your thread has now " + number_of_images.to_i.to_s + " images ( "+ days.to_i.to_s + " days * " + media_count.to_s + " newspapers). Make a shorter range or use less newspapers.")
		end
	end

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
	
	# length of threadx in days
	def duration
	 (end_date - start_date).to_i + 1   # plus one is because date range for threadx is inclusive
	end
	
	def images
		Image.by_media(medium_ids).by_date(start_date..end_date)
	end

	def images_by_date
		Image.by_date(start_date..end_date).by_media(medium_ids)
	end

	def highlighted_areas_for_image(image)
		HighlightedArea.by_threadx(self).by_image(image)
	end
	
	def image_coded?(image)
		area_count = HighlightedArea.by_threadx(self).by_image(image).length
		skipped = coded_pages.for_image(image).length
		area_count > 0 or skipped > 0
	end
	
	def get_percent(code, medium, date)
		image = images.by_media(medium.id).by_date(date).first
		if not image.nil?
			parts = image.size.match(/(\d+)x(\d+)/)
			width = parts[1].to_f
			height = parts[2].to_f
			highlighted = highlighted_areas_for_image(image).by_code(code).inject(0) { |area, ha| area + ha.area }
			return highlighted.to_f / (width * height)
		end
		return nil
	end
	
	def results
		# Create an ordered list of newspapers, codes, dates
		res = {
			:media => ['Total'] + media.map {|m| m.display_name},
			:codes => codes.map {|c| c.code_text},
			:dates => start_date .. end_date,
			:data => {}
		}
		# Create a tree: date->media->code->percentage
		(start_date..end_date).each do |date|
			media_code = {}
			# Initialize totals
			code_sum = {}
			code_count = 0.0
			codes.each do |code|
				code_sum[code.code_text] = 0.0
			end
			# Caclulate percentage for each newspaper
			media.each do |m|
				next if images.by_media(m.id).by_date(date).codeable.length == 0
				code_percent = {} 
				codes.each do |code|
					percent = get_percent(code, m, date)
					code_percent[code.code_text] = percent
					code_sum[code.code_text] += percent
				end
				media_code[m.display_name] = code_percent
				code_count += 1.0
			end
			# Calculate totals
			code_percent = {}
			codes.each do |code|
				if code_count > 0
					code_percent[code.code_text] = code_sum[code.code_text] / code_count
				elsif
					code_percent[code.code_text] = 0.0
				end
			end
			media_code['Total'] = code_percent
			res[:data][date] = media_code
		end
		res
	end
	
end

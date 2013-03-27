require 'odf/spreadsheet'

class Threadx < ActiveRecord::Base

	MAX_IMAGES = 500

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

	validates :thread_name, :uniqueness=>true

	before_validation { |t| 
		t.thread_name = t.thread_display_name if t.thread_name.nil? or t.thread_name.empty?
		t.thread_name = t.thread_name.to_url 
	}

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
		res = []
		images.publication_date.each do |date|
			result = {:date => date, :media => []}
			media.each do |m|
				media_result = {:name => m.display_name, :codes => []}
				codes.each do |code|
					code_result = {:name => code.code_text}
					code_result[:percent] = get_percent(code, m, date)
					media_result[:codes] << code_result
				end
				result[:media] << media_result
			end
			res << result
		end
		res
	end
	
	def results_as_ods
		spreadsheet = ODF::Spreadsheet.new
		media.each do |m|
			table = spreadsheet.table m.display_name
			row = table.row
			cell = row.cell 'Date'
			codes.each do |code|
				cell = row.cell code.code_text
			end
			images.by_media(m.id).each do |image|
				row = table.row
				cell = row.cell image.publication_date
				codes.each do |code|
					cell = row.cell get_percent(code, m, image.publication_date)
				end
			end
		end
		# Create a temporary filepath
		file = Tempfile.new(['export', '.ods']);
		path = file.path
		file.close
		file.unlink
		spreadsheet.write_to(path)
		path
	end

end

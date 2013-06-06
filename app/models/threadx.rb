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

	# remove the generated composite images when a thread is changed
	after_save { |t| 
		t.remove_composite_images
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
	
	def width
		return self.size.split('x')[0].to_f
	end

	def height
		return self.size.split('x')[1].to_f
	end

	# return an array of categories
	def category_list
		self.category.split(",")
	end

	def composite_image_map_info
		thread_img_dir = self.composite_img_dir
		return nil unless File.exists? File.join(thread_img_dir,'img_map.json')
		JSON.parse( IO.read(File.join(thread_img_dir,'img_map.json')) )
	end

	def path_to_composite_cover_image
		File.join('threads',self.owner.id.to_s,self.id.to_s,'front_pages.png').to_s
	end

	def path_to_composite_highlighed_area_image code_id
		File.join('threads',self.owner.id.to_s,self.id.to_s,'code_'+code_id.to_s+'.png').to_s
	end

	def remove_composite_images
		FileUtils.rm_r self.composite_img_dir if Dir.exists? self.composite_img_dir
	end

	def scrape_all_images force_redownload=false
		KioskoScraper.create_images(self.start_date, self.end_date, self.media)
		if force_redownload
			self.images.each do |image|
    		image.download
	    	image.save
			end
		end
		remove_composite_images
	end

	# generate combined images of all the front pages and highlighted areas
	# TODO: be smart about caching this (ie. delete and regen when anything is changed)
	def generate_composite_images width=970, force=false, padding=3
		return if not force and Dir.exists? self.composite_img_dir

		self.composite_img_dir true	# create the container dir

		thumb_width = ((width-padding*self.duration).to_f / self.duration.to_f).round
		img_map = {:row_info=>{},:images=>{}} # will hold info page needs to render

		# figure out each row height
		height_by_media = []
		thumbnails = []
		self.media.each_with_index do |media, index|
			media_images = self.images.select { |img| img.media_id==media.id }
			thumbnail_media_heights = media_images.collect do |img| 
				thumb = img.thumbnail thumb_width
				thumb.nil? ? 0 : thumb.rows
			end
			height_by_media[index] = thumbnail_media_heights.max.round
			img_map[:row_info][media.id] = {:height=>thumbnail_media_heights.max.round, :name=>media.name_with_country}
		end
		logger.debug(height_by_media)
		composite_image_dimens = {:width=>thumb_width*self.duration + padding*self.duration, 
															:height=>height_by_media.sum + padding*self.media.count }
		img_map.merge! composite_image_dimens
		thread_img_dir = self.composite_img_dir

		# create the composite images
		results_composite_img = Magick::Image.new(composite_image_dimens[:width], composite_image_dimens[:height])
		results_composite_img.opacity = Magick::MaxRGB
		front_page_composite_img = Magick::Image.new(composite_image_dimens[:width], composite_image_dimens[:height])
		front_page_composite_img.opacity = Magick::MaxRGB
		ha_composite_gcs = []
		self.codes.each do |code| 
			ha_composite_gcs[code.id] = Magick::Draw.new
		end

		# stitch it all together
		(self.start_date..self.end_date).each do |date|	# iterate over days (ie. columns)
			day_images = self.images.select { |img| img.publication_date==date }
			offset = { 
					:x=>(date-self.start_date)*thumb_width + padding*(date-self.start_date),
					:y=>0 
			}
			self.media.each_with_index do |media,index|	# iterate over media sources within that day
				offset[:y] = height_by_media.first(index).sum + padding*index
				# make the thumbnail composite
				media_img_index = day_images.find_index { |img| img.media_id==media.id }
				if media_img_index.nil?
					# TODO: include a note that img is missing?
				else 
					img = day_images[media_img_index]
					if not img.missing
						# add the thumb to the composite images
						thumb = img.thumbnail thumb_width
						if not thumb.nil?
							front_page_composite_img.composite!(thumb,offset[:x],offset[:y], Magick::OverCompositeOp)
							img_map[:images][img.image_name] = { :x1=>offset[:x].round, :y1=>offset[:y].round, 
								:x2=>offset[:x].round+thumb.columns, :y2=>offset[:y].round+thumb.rows }
						end
					end
				end
				# make the coding composites
				scale = thumb_width / img.width.to_f
				self.codes.each do |code|
					gc = ha_composite_gcs[code.id]
					color = (code.color.nil?) ? '#ff0000' : code.color
					gc.fill color
					gc.fill_opacity 0.5
					img_ha_list = self.highlighted_areas.select { |ha| ha.code_id==code.id and ha.image_id==img.id}
					scaled_areas = img_ha_list.collect { |ha| ha.scaled_areas scale }
					scaled_areas.flatten.each do |area|
						gc.rectangle offset[:x]+area.x1, offset[:y]+area.y1, offset[:x]+area.x1+area.height, offset[:y]+area.y1+area.height
					end	
				end
			end
		end

		# write out the image results
		gc = Magick::Draw.new
		gc.fill 'white'
		gc.fill_opacity 0.6
		gc.rectangle 0,0,composite_image_dimens[:width], composite_image_dimens[:height]
		gc.draw front_page_composite_img
		front_page_composite_img.write File.join(thread_img_dir,'front_pages.png')

		results_composite_img.composite!(front_page_composite_img,0,0,Magick::OverCompositeOp)

		self.codes.each do |code| 
			composite_code_topic_img = Magick::Image.new(composite_image_dimens[:width], composite_image_dimens[:height])
			composite_code_topic_img.opacity = Magick::MaxRGB
			ha_composite_gcs[code.id].draw composite_code_topic_img
			composite_code_topic_img.write File.join(thread_img_dir,'code_'+code.id.to_s+'.png')
			results_composite_img.composite! composite_code_topic_img,0,0,Magick::OverCompositeOp
		end
		
		File.open( File.join(thread_img_dir,'img_map.json'), 'w') {|f| f.write(img_map.to_json)}
		results_composite_img.write File.join(thread_img_dir,'results.png')

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
	
	def results(type = :tree)
		# Create an ordered list of newspapers, codes, dates
		res = {
			:media => media.map {|m| m.display_name},
			:codes => codes.map {|c| c.code_text},
			:dates => start_date .. end_date,
			:colors => {},
			:data => {}
		}
		codes.each do |c|
			res[:colors][c.code_text] = c.color
		end
		tree_data = {}
		flat_data = []
		# Create a tree: date->media->code->percentage
		(start_date..end_date).each do |date|
			media_code = {}
			# Initialize totals
			code_sum = {}
			code_count = 0.0
			codes.each do |code|
				code_sum[code.code_text] = 0.0
			end
			image_count = images.by_date(date).codeable.length
			# Caclulate percentage for each newspaper
			media.each do |m|
				next if images.by_media(m.id).by_date(date).codeable.length == 0
				code_percent = {} 
				codes.each do |code|
					percent = get_percent(code, m, date)
					code_percent[code.code_text] = percent
					code_sum[code.code_text] += percent
					flat_data << {
						:id => "#{date}:#{m.display_name}:#{code.code_text}", :date => date, :media => m.display_name, :code => code.code_text, :percent => percent, :image_count => image_count
					}
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
			tree_data[date] = media_code
		end
		if type == :tree
			res[:data] = tree_data
		elsif type == :flat
			res[:data] = flat_data
		end
		return res
	end
	
	def composite_img_dir create_dir=false
	  composite_image_dir = File.join('app','assets','images','threads',self.owner.id.to_s,self.id.to_s)
		if create_dir and not File.directory? composite_image_dir
			FileUtils.mkpath composite_image_dir
		end
		composite_image_dir
	end

end

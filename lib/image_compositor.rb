require 'zip/zip'

# handle stitching together composite images of a thread's highlighted areas and front page images
# yes, there is code duplication, but this is an attempt to optimized for memory use on our hosted servers because
# really big threads are breaking things
class ImageCompositor

	attr_accessor :start_date, :end_date, :image_dir, :width, :height_by_media_id, :uncoded_image_ids

	DEFAULT_CODE_COLOR = '#ff0000'
	JPEG_IMAGE_QUALITY = 90
	MAX_THUMBNAIL_WIDTH = (Threadx::DEFAULT_COMPOSITE_IMAGE_WIDTH/2).floor

	def initialize start_date, end_date
		@start_date = start_date
		@end_date = end_date
		@duration = (@end_date - @start_date).to_i + 1
		@image_map = {:row_info=>{},:images=>{}}
		@height_by_media_id = {}
	end

	# default padding logic
	def padding
		@duration > 10 ? 3 : 8
	end

	def thumb_width
		[ ((@width-self.padding*@duration).to_f / @duration.to_f).floor, 
		  MAX_THUMBNAIL_WIDTH ].min
	end

	def set_media_info id, name, max_image_height
		@image_map[:row_info][id] = {
			:name => name,
			:height => max_image_height + self.padding
		}
		@height_by_media_id[id] = max_image_height
	end

	# only works after self.set_media_info called a bunch of times
	def calculate_image_map_width_height
		@image_map[:width] = self.thumb_width*@duration + self.padding*@duration
		@image_map[:height] = @height_by_media_id.values.sum + self.padding*self.row_count
	end

	# only works after self.set_media_info called a bunch of times
	def row_count
		@height_by_media_id.length
	end

	def code_composite_image_path code_id
		File.join(@image_dir, 'code_'+code_id.to_s+'.png')
	end

	def code_overlay_image_path code_id
		File.join @image_dir, 'code_'+code_id.to_s+'_overlay.png'
	end

	def front_page_composite_image_path
		File.join @image_dir, 'front_pages.jpg' 
	end

	def full_composite_image_path
		File.join(@image_dir, 'results.jpg')
	end

	def generate_front_page_composite images
		# we will write each day's front pages to this image
		front_page_composite_img = Magick::Image.new @image_map[:width], @image_map[:height] 
		front_page_composite_img.opacity = Magick::MaxRGB
		# iterate over days (ie. columns)
		(self.start_date..self.end_date).each_with_index do |date, day_index|
			day_images = images.select { |img| img.publication_date==date }
			offset = { 
				:x=>day_index*self.thumb_width + day_index*self.padding,
				:y=>0 
			}
			# iterate over media sources (ie. rows)
			@height_by_media_id.keys.each_with_index do |media_id, index|
				offset[:y] = @height_by_media_id.values.first(index).sum + self.padding*index
				media_img_index = day_images.find_index { |img| img.media_id==media_id } # find this day's front page image for this media source
				if media_img_index.nil?
					# TODO: include a note that img is missing?
				else 
					img = day_images[media_img_index]
					if not img.missing
						thumb = img.thumbnail self.thumb_width # generates the thumbnail image
						unless thumb.nil?
							front_page_composite_img.composite!(thumb,offset[:x],offset[:y], Magick::OverCompositeOp)
							@image_map[:images][img.id] = { :x1=>offset[:x].round, :y1=>offset[:y].round, 
								:x2=>offset[:x].round+thumb.columns, :y2=>offset[:y].round+thumb.rows,
								:name=>img.image_name }
							# if the front page is not coded, fade it a bit so the coded area colors stand out,
							# if the front page is coded, fade it more so the uncoded ones stand out
							fade_amount = (@uncoded_image_ids.include? img.id) ? 0.4 : 0.85
							white_gc = Magick::Draw.new
							white_gc.fill 'white'
							white_gc.fill_opacity fade_amount
							white_gc.rectangle offset[:x].round, offset[:y].round, 
								offset[:x].round+thumb.columns, offset[:y].round+thumb.rows
							white_gc.draw front_page_composite_img
						end
					else
						# include the link in the image map anyways
						@image_map[:images][img.id] = { :x1=>offset[:x].round, :y1=>offset[:y].round, 
								:x2=>offset[:x].round+self.thumb_width, :y2=>offset[:y].round+@height_by_media_id[media_id],
								:name=>img.image_name }
					end
				end
			end
		end
		front_page_composite_img.write self.front_page_composite_image_path {self.quality=JPEG_IMAGE_QUALITY}
	end

	def generate_code_overlay_composite images, code_hightlighted_areas, code_id, code_color
		gc = Magick::Draw.new
		gc.fill '#ffffff'	# make sure it is transparent even if no highlighted areas coded
		gc.fill_opacity 1.0
		gc.rectangle 0, 0, 5, 5
		# iterate over days (ie. columns)
		(self.start_date..self.end_date).each do |date|
			day_images = images.select { |img| img.publication_date==date }
			offset = { 
				:x=>(date-@start_date)*self.thumb_width + self.padding*(date-@start_date),
				:y=>0 
			}
			# iterate over media sources (ie. rows)
			@height_by_media_id.keys.each_with_index do |media_id, index|
				offset[:y] = @height_by_media_id.values.first(index).sum + self.padding*index
				media_img_index = day_images.find_index { |img| img.media_id==media_id } # find this day's front page image for this media source
				unless media_img_index.nil?
					img = day_images[media_img_index]
					scale = self.thumb_width / img.width.to_f
					color = (code_color.nil?) ? DEFAULT_CODE_COLOR : code_color #safety check in case a color is missing
					gc.fill color
					gc.fill_opacity 0.6
					img_ha_list = code_hightlighted_areas.select { |ha| ha.image_id==img.id}
					scaled_areas = img_ha_list.collect { |ha| ha.scaled_areas scale }
					scaled_areas.flatten.each do |area|
						gc.rectangle offset[:x]+area.x1, offset[:y]+area.y1, offset[:x]+area.x1+area.width, offset[:y]+area.y1+area.height
					end
				end
			end
		end		
		composite_code_topic_img = Magick::Image.new @image_map[:width], @image_map[:height] 
		composite_code_topic_img.opacity = Magick::MaxRGB
		gc.draw composite_code_topic_img
		composite_code_topic_img.write self.code_overlay_image_path(code_id) {self.quality=JPEG_IMAGE_QUALITY}
	end

	def generate_code_composite code_id
		front_page_composite_img = Magick::Image.read(self.front_page_composite_image_path).first
		code_overlay_composite_img = Magick::Image.read(self.code_overlay_image_path(code_id)).first

		composite_img = Magick::Image.new @image_map[:width], @image_map[:height] 
		composite_img.opacity = Magick::MaxRGB
		composite_img.composite! front_page_composite_img, 0, 0, Magick::OverCompositeOp
		composite_img.composite! code_overlay_composite_img, 0, 0, Magick::OverCompositeOp
		composite_img.write code_composite_image_path(code_id) {self.quality=JPEG_IMAGE_QUALITY}
	end

	def generate_full_composite code_id_list
		front_page_composite_img = Magick::Image.read(self.front_page_composite_image_path).first

		composite_img = Magick::Image.new @image_map[:width], @image_map[:height] 
		composite_img.opacity = Magick::MaxRGB
		composite_img.composite! front_page_composite_img, 0, 0, Magick::OverCompositeOp
		code_id_list.each do |code_id|
			code_overlay_composite_img = Magick::Image.read(self.code_overlay_image_path(code_id)).first
			composite_img.composite! code_overlay_composite_img, 0, 0, Magick::OverCompositeOp
		end
		composite_img.write full_composite_image_path  {self.quality=JPEG_IMAGE_QUALITY}
	end

	def generate_image_map
		File.open( File.join(@image_dir, 'image_map.json'), 'w') {|f| f.write(@image_map.to_json)}
	end	

	def generate_image_archive code_id_list
		input_files = [ full_composite_image_path, front_page_composite_image_path ]
		code_id_list.each do |code_id| 
			input_files.push code_composite_image_path code_id
			input_files.push code_overlay_image_path code_id
		end
		Zip::ZipFile.open( File.join(@image_dir, 'results.zip'), Zip::ZipFile::CREATE) do |zipfile|
			input_files.each do |path|
				zipfile.add File.basename(path), path
			end
		end
	end

end

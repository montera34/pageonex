class ThreadsController < ApplicationController
	before_filter :authenticate_user!, :except => :show

	def index
		
	end

	def create
		@thread = Threadx.new
		@thread.update_attributes!(params[:threadx])
		@thread.thread_name = params[:threadx]["thread_display_name"].sub(' ', '_')

		newspapers_names = {}
		number_of_newspapers = params[:media_count].to_i
		number_of_newspapers.downto(1) do |n|
			_media = Media.find(params["media#{n}"])
			@thread.media << _media
			if newspapers_names[_media.city] != nil
				newspapers_names[_media.city] << _media.name 
			else
				newspapers_names[_media.city] = []
				newspapers_names[_media.city] << _media.name
			end

		end

		number_of_topics = params[:topic_count].to_i
		number_of_topics.downto(1) do |n|
			Code.create!({:code_text => params["topic_name_#{n}"], :code_description => params["topic_description_#{n}"],:color => params["topic_color_#{n}"],:threadx_id => @thread.id})
		end

		images = []

		newspapers_images = Scraper.get_issues(@thread.start_date.year,@thread.start_date.month,@thread.start_date.day,@thread.end_date.day, newspapers_names)

		newspapers_images.each do |image_name, image_info|
			if ( (image = Image.find_by_image_name image_name) == nil)
				image_info["image_name"] = image_name
				media = Media.find_by_name(image_info[:media])

				image = Image.create!({ image_name: image_info["image_name"],publication_date: image_info[:publication_date], local_path: image_info[:local_path], media_id: media.id})
				
				images << image
			else
				image = Image.find_by_image_name(image_name)
				images << image
			end
		end

		@thread.images << images
		@thread.owner_id = current_user.id
		# @thread.status = "open"
		# @thread.category = "uncategorized"
		@thread.save!

		redirect_to "/threads/#{@thread.thread_name}/coding"
	end

	def new
		@media = []
		@thread = Threadx.new
		Media.all.each do |newspaper|
			newspaper.name = "#{newspaper.country} - #{newspaper.display_name}"
			@media << newspaper
		end
		
	end

	def edit
		
	end

	def update
		
	end

	def show
		render :text => params[:id]
	end

end

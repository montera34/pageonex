class ThreadsController < ApplicationController
	before_filter :authenticate_user!, :except => :show

	def index
		
	end

	def create
		# render :json => params.to_json
		
		@thread = Threadx.new
		@thread.update_attributes!(params[:threadx])
		
		number_of_newspapers = params[:media_count].to_i
		number_of_newspapers.downto(1) do |n|
			@thread.media << Media.find(params["media#{n}"])
		end

		number_of_topics = params[:topic_count].to_i
		number_of_topics.downto(1) do |n|
			Code.create!({:code_text => params["topic_name_#{n}"], :code_description => params["topic_description_#{n}"],:color => params["topic_color_#{n}"],:threadx_id => @thread.id})
		end

		@thread.save!

		thread_name = params[:threadx][:thread_name].sub(' ', '_')
		redirect_to "/threads/#{thread_name}/coding"
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

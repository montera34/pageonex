class CodingController < ApplicationController
	before_filter :authenticate_user!

	def process_images
		@thread = Threadx.find_by_thread_name params[:thread_name]		
	end

	def display
		@thread = Threadx.find_by_thread_name params[:thread_name]	
		#render :json => params.to_json
	end
end

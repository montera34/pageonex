class CodingController < ApplicationController
	before_filter :authenticate_user!

	def process_images
		@thread = Threadx.find_by_thread_name params[:thread_name]		
		@images = @thread.images
		@image_counter = @thread.images.length
	end

	def display
		@thread = Threadx.find_by_thread_name params[:thread_name]	
		@images = @thread.images
		@image_counter = @thread.images.length
		@image_counter.downto(0) do |c|
				2.downto(1) do |hc|
					highlighted_area = HighlightedArea.create({:image_id => @images[c], user_id: @current_user})
					if params["image#{c}_ha#{hc}"] == "1"
						Area.create!({x1: params["image#{c}_ha#{hc}_x1"].to_i, y1: params["image#{c}_ha#{hc}_y1"].to_i, x2: params["image#{c}_ha#{hc}_x2"].to_i, y2: params["image#{c}_ha#{hc}_y2"].to_i, width: params["image#{c}_ha#{hc}_width"].to_i, height: params["image#{c}_ha#{hc}_height"].to_i, highlighted_area_id: highlighted_area})
					end

				end	
		end

	end
end

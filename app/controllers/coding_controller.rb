class CodingController < ApplicationController
	before_filter :authenticate_user!

	def process_images
		@thread = Threadx.find_by_thread_name params[:thread_name]		
	end

	def display
		@thread = Threadx.find_by_thread_name params[:thread_name]	
		# image_counter = params["image_counter"]
		3.downto(1) do |c|
				2.downto(1) do |hc|
					highlighted_area = HighlightedArea.create({:image_id=>1})

					if params["image#{c}_ha#{hc}"] == "1"
						Area.create!({x1: params["image#{c}_ha#{hc}_x1"].to_i, y1: params["image#{c}_ha#{hc}_y1"].to_i, x2: params["image#{c}_ha#{hc}_x2"].to_i, y2: params["image#{c}_ha#{hc}_y2"].to_i, width: params["image#{c}_ha#{hc}_width"].to_i, height: params["image#{c}_ha#{hc}_height"].to_i, highlighted_area_id: highlighted_area})
					end
				end	
		end
	end
end

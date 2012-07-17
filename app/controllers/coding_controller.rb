class CodingController < ApplicationController
  before_filter :authenticate_user!

  def process_images
    @thread = Threadx.find_by_thread_name params[:thread_name]
    @images = @thread.images
    @image_counter = @thread.images.length
    @highlighted_areas = []

    # get the highlighted areas from the thread object directly
    # @thread.codes.each do |code|
    #   code.highlighted_areas.each do |high_area|
    #     @highlighted_areas << high_area
    #   end
    # end
    @highlighted_areas = @thread.highlighted_areas
  end

  def process_highlighted_areas
    @thread = Threadx.find_by_thread_name params[:thread_name]
    @images = @thread.images
    @image_counter = @thread.images.length

    # check for the number of highlighted areas, if it more than 0 that's mean, the user trying to modify, existing highlighted areas
    no_highlighted_area = 0
    @image_counter.downto(1) do |c|
      2.downto(1) do |hc|
        if params["image#{c}_ha#{hc}"] == "1"
          no_highlighted_area += params["image#{c}_ha#{hc}"].to_i
        end
      end
    end

    # get the highlighted areas from the thread object directly
    if (no_highlighted_area != 0)
      @highlighted_areas = []
      @thread.codes.each do |code|
        code.highlighted_areas.each do |high_area|
          high_area.areas[0].destroy
          high_area.destroy
        end
      end
    end

    # if (@thread.status == "opened")

      @image_counter.downto(1) do |c|
        2.downto(1) do |hc|
          if params["image#{c}_ha#{hc}"] == "1"

            highlighted_area = HighlightedArea.create!({:name => "image#{c}_ha#{hc}" ,:image => @images[c-1], user: current_user, code_id: params["image#{c}_ha#{hc}_code_id"].to_i, threadx: @thread })

            Area.create!({x1: params["image#{c}_ha#{hc}_x1"].to_i, y1: params["image#{c}_ha#{hc}_y1"].to_i, x2: params["image#{c}_ha#{hc}_x2"].to_i, y2: params["image#{c}_ha#{hc}_y2"].to_i, width: params["image#{c}_ha#{hc}_width"].to_i, height: params["image#{c}_ha#{hc}_height"].to_i, highlighted_area: highlighted_area})
          end
        end	# ends of [2.downto(1)]

      end # ends of [@image_counter.downto(1)] block
    # else
      # notifiy the user that he cannot modifiy highlighted areas
    # end

    redirect_to "/threads/#{@thread.thread_name}/display"
  end

  def display
    @thread = Threadx.find_by_thread_name params[:thread_name]
    @images = @thread.images
    @image_counter = @thread.images.length
    @highlighted_areas = []

    @highlighted_areas = []
    # get the highlighted areas from the thread object directly
    # @thread.codes.each do |code|
    #   code.highlighted_areas.each do |high_area|
    #     @highlighted_areas << high_area
    #   end
    # end

    @highlighted_areas = @thread.highlighted_areas

    @ratios =  [ { x: 0, y: 60 }, { x: 1, y: 49 }, { x: 2, y: 100 }, { x: 3, y: 42 } ]

    # @highlighted_areas.sort! do |ha1,ha2|
    # 	ha1.name.split('_')[0][5..100].to_i <=> ha2.name.split('_')[0][5..100].to_i
    # end

    # @c_ratios = {}

    # images_per_row = @thread.images.length / @thread.media.length

    # total_counter = @thread.images.length * @thread.media.length

    # 1.upto(images_per_row) do |c|
    # 	@c_ratios["c#{c}"] = []
    # end

    # current_c = 0
    # @c_ratios.each do |c,c_ha|
    # 	1.upto(4) do |ha|
    # 		c_ha << @highlighted_areas[ha+current_c-1]
    # 		current_c += 3
    # 	end
    # end

    # render text: @thread.images.length / @thread.media.length

    # render json: @highlighted_areas.to_json

    # render json: @c_ratios.to_json

  end
end

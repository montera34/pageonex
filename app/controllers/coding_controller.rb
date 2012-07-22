class CodingController < ApplicationController
  before_filter :authenticate_user!

  def process_images
    @thread = Threadx.find_by_thread_name params[:thread_name]
    @images = @thread.images
    @image_counter = @thread.images.length
    @highlighted_areas = []

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

    if (no_highlighted_area != 0)
      @thread.highlighted_areas.each do |high_area|
        high_area.areas[0].destroy
        high_area.destroy
      end
    end
    @image_counter.downto(1) do |c|
      2.downto(1) do |hc|
        if params["image#{c}_ha#{hc}"] == "1"

          highlighted_area = HighlightedArea.create!({:name => "image#{c}_ha#{hc}" ,:image => @images[c-1], user: current_user, code_id: params["image#{c}_ha#{hc}_code_id"].to_i, threadx: @thread })

          Area.create!({x1: params["image#{c}_ha#{hc}_x1"].to_i, y1: params["image#{c}_ha#{hc}_y1"].to_i, x2: params["image#{c}_ha#{hc}_x2"].to_i, y2: params["image#{c}_ha#{hc}_y2"].to_i, width: params["image#{c}_ha#{hc}_width"].to_i, height: params["image#{c}_ha#{hc}_height"].to_i, highlighted_area: highlighted_area})
        end
      end	# ends of [2.downto(1)]

    end # ends of [@image_counter.downto(1)] block


    redirect_to "/threads/#{@thread.thread_name}/display"
  end

  def display
    @thread = Threadx.find_by_thread_name params[:thread_name]
    @images = @thread.images
    @image_counter = @thread.images.length
    @codes = @thread.codes
    @highlighted_areas = @thread.highlighted_areas

    # @ratios =  [ { x: 0, y: 60 }, { x: 1, y: 49 }, { x: 2, y: 100 }, { x: 3, y: 42 } ]

    @highlighted_areas.sort! do |ha1,ha2|
    	ha1.name.split('_')[0][5..100].to_i <=> ha2.name.split('_')[0][5..100].to_i
    end

    @i_ratios = {}

    @h_ratios = {}
    
    @ratios = {}

    images_per_row = @thread.images.length / @thread.media.length

    1.upto(images_per_row) do |c|
    	@i_ratios["c#{c}"] = []
    end

    1.upto(images_per_row) do |c|
      @h_ratios["c#{c}"] = []
    end

    1.upto(images_per_row) do |c|
      @ratios["#{c}"] = 0
    end

    @r_images = @images.sort do |img1, img2|
      img1.publication_date <=> img2.publication_date
    end

    cr = 1
    d = @r_images.first.publication_date.day
    @r_images.each do |img|
      if img.publication_date.day == d
        @i_ratios["c#{cr}"] << img
      else
        d = img.publication_date.day
        cr += 1
        @i_ratios["c#{cr}"] << img
      end
    end

    @i_ratios.each do |cr,imgs|
      
      imgs.each do |img|
        
        img.highlighted_areas.each do |ha|
          if @codes.include? ha.code
            highlighted_area = ha.areas[0]["height"].to_f * ha.areas[0]["width"].to_f
            image_area = ha.image.size.split("x")[0].to_f * ha.image.size.split("x")[1].to_f
            ratio = (highlighted_area / image_area) * 100
            @h_ratios[cr] << ratio.ceil
          end
        end

      end

    end

    c = 0
    @h_ratios.each do |cr,rs|
      rs.each do |r|
        c += r.to_i
      end
      @ratios[cr[1..cr.length]] = c
      c = 0
    end

    # render json: @ratios.to_json

  end
end

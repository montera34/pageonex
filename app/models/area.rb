class Area < ActiveRecord::Base
	belongs_to :highlighted_area

  # return a scaled down copy of the area
  def scaled_copy scale
    return Area.new(
      :x1=>(self.x1.to_f * scale).round,
      :x2=>(self.x2.to_f * scale).round,
      :y1=>(self.y1.to_f * scale).round,
      :y2=>(self.y2.to_f * scale).round,
      :width=>(self.width.to_f * scale).round,
      :height=>(self.height.to_f * scale).round,
      :highlighted_area_id=>self.highlighted_area_id,
    )
  end

end

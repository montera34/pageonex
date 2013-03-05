class Media < ActiveRecord::Base
	has_many :images
	has_many :media_threadxes
	has_many :threadxes, :through => :media_threadxes

  def name_with_country
    self.country + " - " + self.display_name
  end

end

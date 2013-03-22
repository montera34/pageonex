class Media < ActiveRecord::Base
	has_many :images
	has_many :media_threadxes
	has_many :threadxes, :through => :media_threadxes

  def name_with_country
    self.country + " - " + self.display_name
  end

  def self.get_names_from_list media_list
    newspapers_names = {}
    media_list.each do |m|
      # for each media country_code(code like  {"es", "de", ...}) it appends the newspapers
      if newspapers_names[m.country_code] != nil
        newspapers_names[m.country_code] << m.name 
      # but if the country_code array is empty, it will create a new array
      else
        newspapers_names[m.country_code] = []
        newspapers_names[m.country_code] << m.name
      end
    end
    newspapers_names
  end

end

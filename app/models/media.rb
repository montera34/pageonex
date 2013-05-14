class Media < ActiveRecord::Base
	has_many :images
	has_many :media_threadxes
	has_many :threadxes, :through => :media_threadxes

  default_scope where(:working=>true)

  scope :by_country_and_display_name, order("country, display_name") 

  def name_with_country
    self.country + " - " + self.display_name
  end

  def create_image_directory
    return false if not Pageonex::Application.config.use_local_images
    local_image_dir = File.join(KioskoScraper.local_image_dir, name)
    FileUtils.mkdir local_image_dir unless File.directory? local_image_dir
    true
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

  def self.from_csv_row row
    m = Media.new
    m.country = row[0]
    m.country_code = row[1]
    m.display_name = row[2]
    m.name = row[3]
    m.url = row[4]
    m
  end

  def to_csv_row
    [ self.country, self.country_code, self.display_name, self.name, self.url ]
  end

end

require 'csv'
require 'open-uri'
require 'nokogiri'
require 'kiosko_scraper'

namespace :scraping do
	
	# rake scraping:scrape_media
	desc "Scrape Kiosko and generate a CSV of media sources"
	task :scrape_media => :environment do
		KioskoScraper::scrape_media_to_csv
	end

	# rake scraping:update_media
	desc "Import/update media into the database from a CSV of media sources"
	task :update_media => :environment do |t, args|
		KioskoScraper::update_media_from_csv
	end
	
	# rake scraping:scrape_day
	desc "Scrape images for the current day"
	task :scrape_day => :environment do
    	day = Date.today - 1
    	KioskoScraper::create_images(day, day, Media.all)
	end

	# rake scraping:migrate_media_folders_to_include_country_codes
	desc "One time-fix to migrate media folders to include country codes"
	task :migrate_media_folders_to_include_country_codes => :environment do
		KioskoScraper::migrate_media_folders_to_include_country_codes 
	end

end

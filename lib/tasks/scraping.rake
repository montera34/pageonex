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

end

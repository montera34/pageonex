require 'csv'
require 'open-uri'
require 'nokogiri'
require 'scraper'

namespace :scraping do
	
	# rake scraping:scrape_media
	desc "Scrape Kiosko and generate a CSV of media sources"
	task :scrape_media => :environment do
		KioskoScraper::scrape_media_to_csv
	end

	# rake scraping:update_media['public/kiosko_scraped.csv']
	desc "Import/update media into the database from a CSV of media sources"
	task :update_media, [:csv_file] => :environment do |t, args|
		KioskoScraper::update_media_from_csv args.csv_file
	end

end

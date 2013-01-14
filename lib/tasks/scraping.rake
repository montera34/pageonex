require 'csv'
require 'open-uri'
require 'nokogiri'

namespace :scraping do
	
	# The csv file is scraped by the the following script which wrote by "rporres" (https://metacpan.org/author/RPORRES) 
	# https://gist.github.com/2970558
	desc "Load kiosko newspapers names from kiosko.csv file"
	task :kiosko_names_csv => :environment do
		csv_file = File.read("public/kiosko.csv")
		csv = CSV.parse(csv_file,:headers=>true)

		csv.each do |row|
			row = row.to_hash.with_indifferent_access
			puts row.to_hash 
  			Media.create!(row.to_hash.symbolize_keys)		
		end
	end

	# This task is not complete, and the remaining part is the formatting the output, and in the public/k_names file the output of the current script
	desc "'NOT WORKING' - Load kiosko newspapers names from kiosko.net directly"
	task :kiosko_names => :environment do
		home_page = Nokogiri::HTML(open('http://en.kiosko.net/'))

		countries = {}

		cities = {}

		newspapers = []

		home_page.css("#menu a").each do |a| 
		  puts countries[a.content] = "http://en.kiosko.net" + a.attributes["href"].value
		  #links << a.attributes["href"].value 
		end
		countries_newspapaer = {}

		countries.each do |value, key| 
		  country_page = Nokogiri::HTML(open(key))
		  country_page.css(".line li a img").each do |img|
		    puts img.attributes["alt"].value
		    countries_newspapaer[value] = img.attributes["alt"].value
		  end
		end

	end

end

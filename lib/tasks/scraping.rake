require 'csv'

namespace :scraping do
	
	desc "Load kiosko newspapers names from kiosko.cvs file"
	task :kiosko_names => :environment do
		csv_file = File.read("public/kiosko.csv")
		csv = CSV.parse(csv_file,:headers=>true)

		csv.each do |row|
			row = row.to_hash.with_indifferent_access
			puts row.to_hash 
  			Media.create!(row.to_hash.symbolize_keys)		
		end
	end

end
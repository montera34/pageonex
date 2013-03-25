# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Pageonex::Application.initialize!

Mime::Type.register "application/x-vnd.oasis.opendocument.spreadsheet", :ods
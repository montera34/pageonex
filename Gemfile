source 'https://rubygems.org'

# specify a ruby version! (rvm respects this)
ruby "1.9.3"

gem 'rails', '3.2.13'

# HACK: this group holds gems we need for heroku
group :heroku do
  gem 'pg'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
end

# GUI support libraries
gem 'therubyracer', '~> 0.12.3' # See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'less-rails'
gem "twitter-bootstrap-rails"
gem "jquery-rails"
gem "jquery-ui-rails"

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'debugger'
end

group :test do
  gem 'faker'
  gem 'capybara'
  gem 'guard-rspec'
  gem 'launchy'
end

gem 'mysql2'

# ODF generation for exporting results
gem 'rodf'

# save image size while scraping kiosko.net
gem "imagesize"

# for thumbnails, because integrating paperclip gem at this point is too hard
gem 'rmagick'

# full management of user accounts
gem 'devise'

# smart generation of slugs for theadx objects
gem 'stringex'

# pagination support
gem 'will_paginate', '~> 3.0'
gem 'bootstrap-will_paginate'

# web analytics
gem 'piwik_analytics'

# for downloading zipped archives
gem 'rubyzip'

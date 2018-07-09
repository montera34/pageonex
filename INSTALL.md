Install PageOneX locally
==========================
Download the files from https://github.com/numeroteca/pageonex

### Needs
PageOnex runs in Ruby on Rails, so you'll ned to install:
+ [Ruby v1.9.3](http://www.ruby-lang.org/en/downloads/) - We highly recommend using [RVM](http://rvm.io/) and gemsets to mange ruby (ie. `rvm use 1.9.3@pageonex`)
+ [RubyGems](http://docs.rubygems.org/)
+ [Rails](http://rubyonrails.org/download) (you might also want to install [RVM (Ruby Version Manager)](https://rvm.io/)

Process
-------
You might want to clone the repository with git:
```
git clone git@github.com:numeroteca/pageonex.git
```

Or download the .zip file from https://github.com/numeroteca/pageonex/archive/master.zip

Go to the directory
```
cd pageonex
```

Setup a database and then edit the `config/database.yml` file to give the app access to that database (we use MySQL).

Install the gems
```
bundle install
```

Run the migration (this will create the database with its tables):
```
rake db:migrate
```

Create a PageOneX admin user like this:
```
rails console
User.create(:username=>'admin-user',:email=>'admin-user@admin.admin',:password=>'hola1234',:password_confirmation=>'hola1234')
me = User.first
me.admin = true
me.save
```

Load the list of newspapers into the data base:
```
rake scraping:update_media
```

Run the server:
```
rails server
```

You can now navigate the app at `http://localhost:3000/` or `http://0.0.0.0:3000/`

### Options
If you have problems with the dependencies of the gems check this tricks.

**Problems with dependencies**

Run the same commands with 'bundle exec' like
```
bundle exec rake db:migrate
```

If you have problems with the pg gem, needed for the "heroku" version, you can run:
```
bundle install --without heroku
```



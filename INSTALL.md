Install PageOneX locally
==========================
Download the files from https://github.com/numeroteca/pageonex

### Needs
Install:
-ruby
-rails

Process
-------------------------
You might want to clone the repository with git:
> git clone git@github.com:numeroteca/pageonex.git

Or download the .zip file from https://github.com/numeroteca/pageonex/archive/master.zip

Go to the directory
> cd pageonex

Install the gems
> bundle install

Run the migration:
> rake db:migrate

Load the list of newspapers in the data base:
> rake scraping:kiosko_names_csv

Run the server:
> rails server

You can now navigate the app at:
> http://localhost:3000/ 

or 
> http://0.0.0.0:3000/

### Options
When you have some problem with the dependencies of the gems there are some tricks.

**pg gem**

The postgres gem is there for the production development. If you are not able to install it, you an run
>bundle install --without production

**problems with dependencies**

Run the same commands with 'bundle exec' like
>bundle exec rake db:migrate

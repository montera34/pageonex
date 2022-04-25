PageOneX in Ruby on Rails
=========================

*PageOneX is an open source tool to code, analyze and visualize the evolution of stories on newspaper front pages.* PageOneX is an free software/open source software tool designed to aid the coding, analysis, and visualization of front page newspaper coverage of major stories and media events. Newsrooms spend massive time and effort deciding what stories make it to the front page.
In the past, this approach involved obtaining copies of newspapers, measurement by hand (with a physical ruler), and manual input of measurements into a spreadsheet or database, followed by calculation and analysis. Some of these steps can now be automated, while others can be simplified; some can be easily shared by distributed teams of investigators working with a common dataset hosted online.

*How is your project different from what already exists?* Communication scholars have long used column-inches of print newspaper coverage as an important indicator of mass media attention. PageOneX simplifies, digitizes, and distributes the process across the net.

More Info
---------

You can find more information and examples at http://pageonex.com or at [the blog](http://montera34.org/pageonex/)

Running pageonex
----------------

Pageonex is a Free/Libre and Open Source Software (F/LOSS) project. If you don't want to use the hosted version of pageonex at http://pageonex.com you have a few options to run it yourself. We've prepared a set of soltuions that use [docker](http://docker.com/), a containerized version of the tools that allows you to use the tool without the need to handle all the dependencies of Ruby on Rails.

1. For any of the following options with you need to download or clone [this repository](https://github.com/montera34/pageonex). If you are familiar with git you can clone it git clone with `git clone https://github.com/montera34/pageonex.git`. Otherwise you can [download the entire code in a .zip](https://github.com/montera34/pageonex/archive/refs/heads/master.zip).
2. [Install Docker](https://www.docker.com/get-started).

You have various options:

* [You can run pageonex locally using docker-compose and our generated images](doc/docker/running-pageonex-locally-with-docker-compose.md). This is the easiest way.
* [You can run pageonex locally using docker-compose and building locally the docker images](doc/docker/development-with-docker-compose.md). This is recommended if you want to do some development.
* [You can install pageonex locally compiling in your system all the needed files](doc/local-install.md). This option is more advanced and it is only recommended if you're doing heavy development.
* [You can use our Docker images to deploy pageonex against your mysql database](doc/docker/running-pageonex-in-your-environment.md). This is an advanced setup that it is useful if you're planning to maintain your own pageonex production environment. YOu can read this tutorial as well: [How to install Pageonex with Docker against and external database](https://github.com/montera34/pageonex/wiki/How-to-install-Pageonex-with-Docker-against-and-external-database)


If you want to install it from scratch, please use the manual in the wiki: https://github.com/montera34/pageonex/wiki#pageonex-for-developers


Collaborators
-------------

The project has many collaborators. The coders have been/are [Ahmd Refat](https://github.com/ahmdrefat), [Edward L Platt](https://github.com/elplatt), [Rahul Bhargava](https://github.com/rahulbot), [Rafael Porres](https://github.com/rporres) and [Pablo Rey Mazón](https://github.com/numeroteca). Sasha Costanza-Chock is giving advice and support from the Center for Civic Media; [Alfonso Sánchez Uzábal](http://skotperez.net/) is providing technical support and [Montera34](http://montera34.com/) the server. Thanks to Jeff Warren for his advice and Rogelio López for his testing.


Join the project
----------------

Join the [mailing list for developers](http://mailman.mit.edu/mailman/listinfo/pageonexdev), [for users](https://groups.google.com/forum/?fromgroups#!forum/pageonex) or [subscribe to the newsletter](http://montera34.org/pageonex/newsletter/) to get the last updates.


Background
----------

The project has gone through different phases. 
[Initially](http://civic.mit.edu/blog/pablo/analyzing-newspapers-front-pages), this type of data visualization was made through a ***‘manual’ process***: images of newspaper front pages were downloaded from the web and reorganized in a vector graphics program to draw rectangles on top of them to highlight certain stories.

The first version of an ***automated tool*** was a [script written in Processing](https://github.com/numeroteca/pageonex-processing)</a>, that downloaded newspapers front pages and generated an organized array of images ordered by date. 

The ***second version*** is [this tool written in Ruby on Rails that you are using](https://github.com/numeroteca/pageonex). It is developed to be a web platform to provide a ready to use front page analysis tool for anyone with a connection to the Internet. The platform automates the process of newspaper selection, download, thread coding, and data visualization. The alpha version was developed by [Pablo Rey Mazón](https://github.com/numeroteca) with [Ahmd Refat](https://github.com/ahmdrefat), thanks to Google Summer of Code program 2012 (GSOC) and the Berkman Center as host institution in Summer 2012.

In Winter-Spring 2013, at the [MIT Center for Civic Media](http://civic.mit.edu/) at [MIT Media Lab](http://media.mit.edu), we developed with [rahulbot](https://github.com/rahulbot) and [elplatt](https://github.com/elplatt) the first beta version and preparing a stable deployment. [rporres](https://github.com/rporres) developed a web crawler for kiosko.net front pages.

The beta version can be used at [PageOneX.com](http://pageonex.com/).

Check the documentation of the project at the [wiki hosted in this same repository](https://github.com/numeroteca/pageonex/wiki).

In 2016 Sasha Costanza-Chock and Pablo Rey-Mazón published [PageOneX: New Approaches to Newspaper Front Page Analysis](http://ijoc.org/index.php/ijoc/article/view/4442), we hope it provides an useful guide and resource to the field of the newspapers front page analysis and to clarify the different possible uses of PageOneX.

In the summer of 2018 we developed [a bunch of new of great features](https://blog.pageonex.com/2019/05/14/brand-new-features-edit-areas-fork-threads-multi-taxonomy/):

+ [Rafa](https://github.com/rporres) made containerized versions to allow easy local install of the project and easy upgrade in the MIT server. [An automatized process](https://github.com/montera34/pageonex/issues/230#issuecomment-492608930) was developed with Travis and webHooks to create new container images and make deployment easier. 
+ [Xuanxu](https://github.com/xuanxu) developed great enhancements that allow the use of multiple taxonomies, edit and remove areas, fork a thread and export data in “raw format” ([That allows analysis in R](https://code.montera34.com/numeroteca/pageonexR), for example), among other stuff. 


Now: Main problems to solve. 2021
------------------------

There are currently 3 main problems are:

+ The version of Ruby on Rails (RoR) that Pageonex uses is very old (it usees ruby 1.9.3. where current is 3.0.1). The gems it uses are also out of date and there are potential security vulnerabilities (view security risks).
+ The use of an old version of RoR has made the containerization and deployment process more difficult, even blocked it. 
+ [Sometimes the web app crashes](https://github.com/montera34/pageonex/issues/235).


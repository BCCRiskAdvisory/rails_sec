# Rails Secure Coding

This Ruby on Rails application is both a testbed for certain vulnerabilities
that affect Rails specifically, and also generic web application
vulnerabilities.

To install, you must have ruby, gem, and bundler installed. Run the following
command to install dependencies:

    bundle install

To get the SQL injection stuff working, you will have to perform a few
additional steps. If you want to use MySQL, then you will have to edit the
`config/database.yml` file. Specify the adapter as `mysql2` and then set the
username, password, database, and host properties as appropriate.

In any case, you must run the following tasks to create/migrate the database.

    bundle exec rake db:create
    bundle exec rake db:schema:load

To create some data to populate the database, run `rails console`, and use the
following command

    User.create(:name => 'Name', :email => 'me@me.com', :points => 1000, :password_hash => 'fff')

You can change the attributes appropriately and run the command multiple times.

To run the application, simply run

    bundle exec rails server

The bundle exec can be omitted if you are using some sort of ruby environment
manager like RVM. (https://rvm.io)

# RailsLite
  A barebones web framework. Created to demonstrate metaprogramming techniques.
  It duplicates some of the features of Rails and ActiveRecord. If you use this
  for production data, please have your head examined.

### Features
  - ActiveRecordLite Object-Relational-Mapping system included for easy DB access
  - Router class for easy definition of resource routes.
  - Strong params support
  - Flash message support
  - CSRF Protection
  - Built-in web server with WEBrick, Built-in database with SQLite3
  - Cats!

### Setup (demo app)
  - bundle install
  - ruby ./bin/start.rb

### Creating your own app
  - Set up .sql file to create database
  - Change constants in ./lib/db_connection.rb to point to your database
  - Write model classes according to example in ./bin/models.rb
  - Write controller classes according to example in ./bin/controllers.rb
  - Define routes according to example in ./bin/routes.rb
  - Start server by running ./bin/start.rb

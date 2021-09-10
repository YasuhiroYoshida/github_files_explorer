source "https://rubygems.org"

ruby "3.0.2"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "rails", "~> 6.1.4"

gem "puma", "~> 5.4"

gem "jquery-rails"
gem "sass-rails", "~> 5.0"
gem "bootstrap", "~> 4"
gem "coffee-rails", "~> 4.2"
gem "uglifier", ">= 1.3.0"
gem "turbolinks", "~> 5"

gem "responders"

gem "will_paginate", "~> 3.3", ">= 3.3.1"
gem "bootstrap-will_paginate", "~> 1.0"
gem "faraday"

group :development, :test do
  gem "sqlite3"

  gem "pry-byebug"
  gem "pry-rails"

  gem "capybara", "~> 2.13"
  gem "selenium-webdriver"
  gem "rspec-rails"
  gem "rails-controller-testing"
  gem "shoulda-matchers"
  gem "rubocop"
end

group :development do
  gem "web-console", ">= 3.3.0"
  gem "listen"

  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :production do
  gem "pg"
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end
ruby '2.7.6'

gem 'rails', '~> 5.2.3'

gem 'puma', '~> 3.7'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'simple_form'
gem 'bootstrap', '~> 4.0.0'
gem 'jquery-rails'
gem 'mini_magick'
gem 'font_awesome5_rails'
gem 'devise'
gem 'fullcalendar-rails'
gem 'momentjs-rails'
gem 'jquery-ui-rails'
gem 'rails_sortable'
gem 'rails-jquery-autocomplete'
gem 'select2-rails'
gem 'pagy'
gem 'filterrific'
gem 'seed_dump'
gem 'crono'
gem 'nationality', '~> 1.0.7'
gem 'carrierwave-base64'
## For toggle the switch
gem 'bootstrap-toggle-rails'
# gem 'active_storage_validations'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem 'libreconv' # to preview dox and xlsx files on server
gem 'rmagick'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'rack-mini-profiler'
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'faker'
  gem 'mysql2'
  gem 'shoulda-context'
  gem 'rails-controller-testing'
  gem 'timecop'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'letter_opener'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'carrierwave', '~> 2.0'
gem 'fog-aws'
gem 'mime-types'
gem "cocoon"
gem 'rails_12factor', group: :production
gem 'select_all-rails'
gem 'prawn'
gem 'prawn-table', '~> 0.2.2'
gem 'prawn-icon', '~> 3.0'
gem 'combine_pdf'
gem 'amoeba'

source 'https://rubygems.org'


gem 'nokogiri', '1.5.9'
gem 'feedzirra'
gem 'ruby-readability'
gem 'link_thumbnailer'
gem 'mini_magick'
gem 'rails', '3.2.11'
gem 'mysql2'
gem 'node'
gem 'fastimage'
gem 'whenever', :require => false
gem 'socksify'
gem 'rmagick'
gem 'haml'
gem 'aws-sdk'
gem 'dalli'
gem 'www-favicon'
gem 'httparty'



#activeadmin requirements
gem 'activeadmin'
gem "meta_search",    '>= 1.1.0.pre'


group :production, :staging do
  gem 'unicorn'
end

group :development do
  gem 'debugger'

  # Code Metric Gems
  gem 'rails_best_practices', '~> 1.14.4'
  gem 'rubocop', '~> 0.18.1'
  gem 'metric_fu', '~> 4.6.0'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem "jquery-rails", "2.3.0"
gem 'rake'

# Deploy with Capistrano
gem 'capistrano-ext'

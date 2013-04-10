set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "cloudspace_rss"
set :user, "root"
set :group, "root"

set :scm, :git
set :repository, "git@github.com:cloudspace/cloudspace_rss.git"
set :deploy_to, "/srv/www/#{application}"
set :deploy_via, :remote_cache
set :rails_env, 'production'
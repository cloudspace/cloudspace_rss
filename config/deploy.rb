set :stages, %w(production staging)
set :default_stage, "staging"

require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :application, "rss.cloudspace.com"
set :user, "root"
set :group, "root"
set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true
set :scm, :git
set :repository, "git@github.com:cloudspace/cloudspace_rss.git"
set :deploy_to, "/srv/www/#{application}"
set :deploy_via, :remote_cache
set :rails_env, 'production'
set :bundle_flags, "--deployment --quiet --binstubs=sbin"

namespace :deploy do
  task :start do
    run "cd #{current_release} && bundle exec unicorn -E #{rails_env} -c /etc/unicorn/#{application}.rb -D"
  end

  task :stop do
    run "kill -QUIT $(cat /var/run/#{application}_unicorn.pid)"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    run "kill -USR2 $(cat /var/run/#{application}_unicorn.pid)"
  end

  namespace :db do
    task :drop do
      run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake db:drop"
    end
    
    task :create do
      run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake db:create"
    end
    
    task :migrate do
      run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
    end
    
    task :seed do
      run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake db:seed"
    end
  end
end

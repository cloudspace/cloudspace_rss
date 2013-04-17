set :stages, %w(production staging)
set :default_stage, "staging"

require 'bundler/capistrano'
require 'capistrano/ext/multistage'

set :application, "rss.cloudspace.com"
set :user, "root"
set :group, "root"
set :scm, :git
set :repository, "git@github.com:cloudspace/cloudspace_rss.git"
set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true
set :deploy_to, "/srv/www/#{application}"
#set :deploy_via, :remote_cache
set :rails_env, 'production'
#set :bundle_flags, "--deployment --quiet --binstubs=sbin"
set :bundle_flags, "--without deployment"

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


namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(release_path, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end

  task :install, :roles => :app do
    run "cd #{release_path} && bundle install --binstubs "

    on_rollback do
      system "say \" something messed up rolling back\""
      if previous_release
        run "cd #{previous_release} && sudo bundle install --binstubs "
      else
        logger.important "no previous release to rollback to, rollback of bundler:install skipped"
      end
    end
  end

  task :bundle_new_release, :roles => :db do
    bundler.create_symlink
    bundler.install
  end
end


after "deploy:rollback:revision", "bundler:install"
after "deploy:update_code", "bundler:bundle_new_release"
after "deploy:update_code", "deploy:db:migrate"
after "deploy:update_code", "deploy:db:seed"
after "deploy", "deploy:cleanup"
# after "deploy:stop",    "delayed_job:stop"
# after "deploy:start",   "delayed_job:start"

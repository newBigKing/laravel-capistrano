# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "laravel-capistrano"
set :repo_url, "git@github.com:newBigKing/laravel-capistrano.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, "develop"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/html"
set :laravel_dotenv_file, '/var/www/secrets/.env'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

append :linked_dirs,
    'storage/app',
    'storage/framework/cache',
    'storage/framework/sessions',
    'storage/framework/views',
    'storage/logs'

namespace :composer do
    desc "Running Composer Install"
    task :install do
        on roles(:composer) do
            within release_path do
                #execute :composer, "install --no-dev --quiet --prefer-dist --optimize-autoloader"
                execute :composer, "install --prefer-dist --no-dev --optimize-autoloader"
            end
        end
    end
end
namespace :laravel do
    task :fix_permission do
        on roles(:laravel) do
            execute :chmod, "-R ug+rwx #{shared_path}/storage/ #{release_path}/bootstrap/cache/"
            execute :chgrp, "-R www-data #{shared_path}/storage/ #{release_path}/bootstrap/cache/"
        end
    end
    task :configure_dot_env do
    dotenv_file = fetch(:laravel_dotenv_file)
        on roles (:laravel) do
        execute :cp, "#{dotenv_file} #{release_path}/.env"
        end
    end
    task :migrate do
        on roles(:laravel) do
            within release_path do
            execute :php, "artisan migrate --no-interaction --force"
            end
        end
    end
    task :storage do
            on roles(:laravel) do
                within release_path do
                execute :php, "artisan storage:link"
                end
            end
        end
    task :restart_php_fpm do
        on roles(:laravel) do
            within release_path do
            execute :sudo, :service, "php7.2-fpm restart"
            end
        end
    end
end

namespace :deploy do
    after :updated, "composer:install"
    after :updated, "laravel:fix_permission"
    after :updated, "laravel:configure_dot_env"
    after :updated, "laravel:migrate"
    after :updated, "laravel:storage"
    after :updated, "laravel:restart_php_fpm"
end
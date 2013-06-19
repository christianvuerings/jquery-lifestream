#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'torquebox-rake-support'

Calcentral::Application.load_tasks

# Rails.logger might not be initialized for certain rake tasks, see calcentral_config.rb
Rails.logger ||= Logger.new(STDOUT)

task :default => ['travis']

#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'

dir = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
 
daemon_options = {
  :multiple   => false,
  :dir_mode   => :normal,
  :dir        => File.join(dir, 'tmp', 'pids'),
  :backtrace  => true
}
 
Daemons.run_proc('job_runner', daemon_options) do
  if ARGV.include?('--')
    ARGV.slice! 0..ARGV.index('--')
  else
    ARGV.clear
  end
  
  Dir.chdir dir
  RAILS_ENV = ARGV.first || ENV['RAILS_ENV'] || 'development'
  require File.join('config', 'environment')
  
  Delayed::Worker.new.start
end

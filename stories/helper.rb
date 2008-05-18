

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails/story_adapter'

dir = File.dirname(__FILE__)
Dir[File.expand_path("#{dir}/steps/*.rb")].uniq.each do |file|
  require file
end

def run_local_story(filename, options={})
  run filename, options
end

def get_user(actor)
  actor = non_possessive(actor)
  @last_actor = is_indefinite?(actor) ? @last_actor : instance_variable_get("@#{actor}")
  @last_actor.reload unless @last_actor.nil? || @last_actor.new_record?
  @last_actor
end

def is_indefinite?(actor)
  ['he', 'his', 'she', 'her', 'it', 'its'].include?(actor.downcase)
end

def non_possessive(str)
  str.gsub(/'s?$/){}
end
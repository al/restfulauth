

require File.dirname(__FILE__) + '/../../helper'

with_steps_for(:account, :email, :see, :webrat) do
  run_local_story File.join(File.dirname(__FILE__), 'story'), :type => RailsStory
end
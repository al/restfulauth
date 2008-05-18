

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /users/index.html.erb' do
  before(:each) do
    assigns[:users] = ['user 1', 'user 2']
    template.stub!(:render)
  end

  it 'should render the user partial for each user' do
    template.should_receive(:render).with(:partial => 'user', :collection => assigns[:users])
    render '/users/index.html.erb'
  end
end


require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /users/show.html.erb' do
  before(:each) do
    assigns[:user] = mock_model(User, :login => 'login', :created_at => 'created at')
    template.stub!(:render)
  end

  it 'should render the user\'s join date' do
    render '/users/show.html.erb'
    response.should have_text(/created at/) do
    end
  end
end
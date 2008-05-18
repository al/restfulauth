

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /user_mailer/forgot_password.text.html.erb' do
  before :each do
    assigns[:user] = mock_model(User, :login => 'login')
    assigns[:reset_url] = 'reset url'
  end
  
  it 'should contain the correct url' do
    render '/user_mailer/forgot_password.text.html.erb'
    response.should have_text(/reset url/)
  end
end
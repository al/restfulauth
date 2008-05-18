

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /user_mailer/signup_notification.text.plain.erb' do
  before :each do
    assigns[:user] = mock_model(User, :login => 'login')
    assigns[:activate_url] = 'activate url'
  end
  
  it 'should contain the correct url' do
    render '/user_mailer/signup_notification.text.plain.erb'
    response.should have_text(/activate url/)
  end
end
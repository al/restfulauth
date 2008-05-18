

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /user_mailer/activation.text.plain.erb' do
  before :each do
    assigns[:user] = mock_model(User, :login => 'login')
    assigns[:login_url] = 'login url'
  end
  
  it 'should contain the correct url' do
    render '/user_mailer/activation.text.plain.erb'
    response.should have_text(/login url/)
  end
end
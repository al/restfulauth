

require File.dirname(__FILE__) + '/../spec_helper'

describe 'all email', :shared => true do
  before :each do
    @user = mock_model(User, :login => 'login', :email => 'someone@domain.tld', :activation_code => 'activation code', :password_reset_code => 'password reset code')
  end
    
  it 'should send the email' do
    do_deliver
    ActionMailer::Base.deliveries.size.should == 1
  end

  it 'should send the email to the correct address' do
    do_deliver
    email = ActionMailer::Base.deliveries[0]
    email.to.should == [@user.email]
  end
    
  it 'should send the email with the correct subject' do
    do_deliver
    email = ActionMailer::Base.deliveries[0]
    email.subject.should == @subject
  end
end

describe UserMailer do
  before :each do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  
  describe 'sending sign up notification' do
    before :each do
      @subject = 'Account Activation'
    end
    
    def do_deliver
      UserMailer.deliver_signup_notification(@user)
    end
    
    it_should_behave_like 'all email'
    
    it 'should include the correct link in the body' do
      do_deliver
      email = ActionMailer::Base.deliveries[0]
      email.body.should include('http://localhost:3001/activate/activation code')
    end
  end
  
  describe 'sending activation notification' do
    before :each do
      @subject = 'Your Account has been Activated!'
    end
    
    def do_deliver
      UserMailer.deliver_activation(@user)
    end
    
    it_should_behave_like 'all email'
    
    it 'should include the correct link in the body' do
      do_deliver
      email = ActionMailer::Base.deliveries[0]
      email.body.should include('http://localhost:3001')
    end
  end
  
  describe 'sending forgot password notification' do
    before :each do
      @subject = 'Reset your Password?'
    end
    
    def do_deliver
      UserMailer.deliver_forgot_password(@user)
    end
    
    it_should_behave_like 'all email'
    
    it 'should include the correct link in the body' do
      do_deliver
      email = ActionMailer::Base.deliveries[0]
      email.body.should include('http://localhost:3001/reset_password/password reset code')
    end
  end
  describe 'sending reset password notification' do
    before :each do
      @subject = 'Your Password has been Reset'
    end
    
    def do_deliver
      UserMailer.deliver_reset_password(@user)
    end
    
    it_should_behave_like 'all email'
  end
end
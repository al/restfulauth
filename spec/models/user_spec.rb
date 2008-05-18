

require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before :each do
    User.destroy_all
  end
  
  def valid_attributes
    {
      :login => 'login',
      :password => 'password',
      :password_confirmation => 'password',
      :email => 'someone@domain.tld'
    }
  end
  
  describe 'instantiation' do
    def new_should_fail_with_attributes(attributes)
      @user = User.new(attributes)
      @user.save.should be_false
    end
    
    it 'with valid attributes' do
      User.new(valid_attributes).should be_valid
    end
    
    it 'without login should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:login))
    end
    
    it 'without password should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:password))
    end
    
    it 'without password confirmation should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:password_confirmation))
    end
    
    it 'without email should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:email))
    end
    
    it 'with short password should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:password, :password_confirmation).merge({ :password => 'a' * 7, :password_confirmation => 'a' * 7 }))
    end
    
    it 'with long password should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:password, :password_confirmation).merge({ :password => 'a' * 41, :password_confirmation => 'a' * 41 }))
    end
    
    it 'with mismatching passwords should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:password_confirmation).merge({ :password_confirmation => 'wrong password' }))
    end
    
    it 'with short login should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:login).merge({ :login => 'a' * 2 }))
    end
    
    it 'with long login should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:login).merge({ :login => 'a' * 41 }))
    end
    
    it 'with short email should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:email).merge({ :email => 'a' * 5 }))
    end
    
    it 'with long email should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:email).merge({ :email => 'a' * 101 }))
    end
    
    it 'with invalid email should fail' do
      new_should_fail_with_attributes(valid_attributes.except(:email).merge({ :email => 'someone @domain.tld' }))
    end
    
    it 'with preexsiting login should fail' do
      User.new(valid_attributes).save!
      new_should_fail_with_attributes(valid_attributes.except(:email).merge({ :email => 'someoneelse@domain.tld' }))
    end
    
    it 'with preexsiting email should fail' do
      User.new(valid_attributes).save!
      new_should_fail_with_attributes(valid_attributes.except(:login).merge({ :login => 'different login' }))
    end
  
    it 'should create activation code' do
      Digest::SHA1.stub!(:hexdigest).and_return('activation code')
      @user = User.new(valid_attributes)
      lambda { @user.save }.should change(@user, :activation_code).from(nil).to('activation code')
    end
    
    it 'should create salt' do
      Digest::SHA1.stub!(:hexdigest).and_return('salt')
      @user = User.new(valid_attributes)
      lambda { @user.save! }.should change(@user, :salt).from(nil).to('salt')
    end
    
    it 'should created encrypted password' do
      Digest::SHA1.stub!(:hexdigest).and_return('encrypted password')
      @user = User.new(valid_attributes)
      lambda { @user.save! }.should change(@user, :crypted_password).from(nil).to('encrypted password')
    end
    
    it 'should email a sign up notification to the user' do
      @user = User.new(valid_attributes)
      UserMailer.should_receive(:deliver_signup_notification).with(@user)
      @user.save!
    end
  end
  
  describe 'updating attributes' do
    before :each do
      Digest::SHA1.stub!(:hexdigest).and_return('old encrypted password')
      @user = User.new(valid_attributes)
      @user.save!
      @user = User.find(@user.id)
      Digest::SHA1.stub!(:hexdigest).and_return('new encrypted password')
    end
    
    it 'with password should update encrypted password' do
      lambda {
        @user.update_attributes!(:password => 'new password', :password_confirmation => 'new password')
      }.should change(@user, :crypted_password).from('old encrypted password').to('new encrypted password')
    end
    
    it 'without password should not update encrypted password' do
      lambda {
        @user.update_attributes!(:login => 'new login')
      }.should_not change(@user, :crypted_password)
    end
  end
  
  describe 'authentication' do
    before :each do
      @user = User.new(valid_attributes)
      @user.save!
    end
    
    it 'should return the correct user' do
      User.authenticate('login', 'password').should == @user
    end
    
    it 'should return nil if login is incorrect' do
      User.authenticate('incorrect login', 'password').should be_nil
    end
    
    it 'should return nil if password is incorrect' do
      User.authenticate('login', 'incorrect password').should be_nil
    end
  end

  describe do
    before :each do
      @user = User.new(valid_attributes)
      @user.stub!(:encrypt).and_return('token')
      @now = Time.now
      Time.stub!(:now).and_return(@now)
    end
    
    describe 'remembering authentication until *' do
      it 'should update expiration time' do
        three_weeks = Time.now + 3.weeks
        @user.should_receive(:save)
        lambda { @user.remember_me_until(three_weeks) }.should change(@user, :remember_token_expires_at).from(nil).to(three_weeks)
      end
      
      it 'should update token' do
        @user.should_receive(:save)
        lambda { @user.remember_me_until(Time.now + 3.weeks) }.should change(@user, :remember_token).from(nil).to('token')
      end
    end
    
    describe 'remembering authentication for *' do
      it 'should update expiration time' do
        @user.should_receive(:save)
        lambda { @user.remember_me_for(3.weeks) }.should change(@user, :remember_token_expires_at).from(nil).to(Time.now.utc + 3.weeks)
      end
      
      it 'should update token' do
        @user.should_receive(:save)
        lambda { @user.remember_me_for(3.weeks) }.should change(@user, :remember_token).from(nil).to('token')
      end
    end
    
    describe 'remembering authentication' do
      it 'should update expiration time' do
        @user.should_receive(:save)
        lambda { @user.remember_me }.should change(@user, :remember_token_expires_at).from(nil).to(Time.now + 2.weeks)
      end
      
      it 'should update token' do
        @user.should_receive(:save)
        lambda { @user.remember_me }.should change(@user, :remember_token).from(nil).to('token')
      end
    end
    
    describe 'forgetting authentication' do
      before :each do
        @user.remember_token_expires_at = Time.now
        @user.remember_token = 1
      end
    
      it 'should reset expiration time' do
        @user.should_receive(:save)
        lambda { @user.forget_me }.should change(@user, :remember_token_expires_at).from(Time.now).to(nil)
      end
      
      it 'should reset token' do
        @user.should_receive(:save)
        lambda { @user.forget_me }.should change(@user, :remember_token).from(1).to(nil)
      end
    end
  end
  
  describe 'activation' do
    before :each do
      @user = User.new(valid_attributes)
      @user.save
      User.stub!(:find_by_activation_code).with('activation code').and_return(@user)
      @now = Time.now
      Time.stub!(:now).and_return(@now)
    end
    
    it 'should raise an exception if no activation code is supplied' do
      lambda { User.find_and_activate!(nil) }.should raise_error(ArgumentError)
    end
    
    it 'should raise an exception if an invalid activation code is supplied' do
      lambda { User.find_and_activate!('invalid activation code') }.should raise_error(User::ActivationCodeNotFound)
    end
    
    it 'should raise an exception if the user is already active' do
      @user.stub!(:active?).and_return(true)
      lambda { User.find_and_activate!('activation code') }.should raise_error(User::AlreadyActivated)
    end
  
    it 'should update the activation time' do
      lambda { User.find_and_activate!('activation code') }.should change(@user, :activated_at).from(nil).to(Time.now.utc)
    end
  
    it 'should make the user\'s status \'pending\'' do
      lambda { User.find_and_activate!('activation code') }.should change(@user, :pending?).from(nil).to(true)
    end
  
    it 'should make the user\'s status \'active\'' do
      lambda { User.find_and_activate!('activation code') }.should change(@user, :active?).from(nil).to(true)
    end
    
    it 'should email an activation notification to the user' do
      UserMailer.should_receive(:deliver_activation).with(@user)
      User.find_and_activate!('activation code')
    end
  end
  
  describe 'forgetting password' do
    before :each do
      @user = User.new(valid_attributes)
      @user.save
      Digest::SHA1.stub!(:hexdigest).and_return('password reset code')
    end
    
    it 'should make the user\'s status \'recently forgot password\'' do
      lambda { @user.forgot_password }.should change(@user, :recently_forgot_password?).from(nil).to(true)
    end
    
    it 'should update the user\'s password reset code' do
      lambda { @user.forgot_password }.should change(@user, :password_reset_code).from(nil).to('password reset code')
    end
    
    it 'should email a password reset link to the user' do
      UserMailer.should_receive(:deliver_forgot_password).with(@user)
      @user.forgot_password
    end
  end
  
  describe 'resetting password' do
    before :each do
      @user = User.new(valid_attributes)
      @user.save
      Digest::SHA1.stub!(:hexdigest).and_return('password reset code')
      @user.forgot_password
    end  
    
    it 'should make the user\'s status \'recently reset password\'' do
      lambda { @user.reset_password }.should change(@user, :recently_reset_password?).from(nil).to(true)
    end
    
    it 'should reset the user\'s password reset code' do
      lambda { @user.reset_password }.should change(@user, :password_reset_code).from('password reset code').to(nil)
    end
    
    it 'should email a password reset notification to the user' do
      UserMailer.should_receive(:deliver_reset_password).with(@user)
      @user.reset_password
    end
  end
  
  describe 'testing role' do
    before :each do
      @user = User.new(valid_attributes)
      @user.save
      @user.roles.stub!(:find_by_rolename).with('a real role').and_return(true)
      @user.roles.stub!(:find_by_rolename).with('a fake role').and_return(nil)
    end
    
    it 'should return true if the user has the role' do
      @user.has_role?('a real role').should be_true
    end
    
    it 'should return false if the user does not have the role' do
      @user.has_role?('a fake role').should be_false
    end
  end
end
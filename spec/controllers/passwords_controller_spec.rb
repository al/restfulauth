

require File.dirname(__FILE__) + '/../spec_helper'

describe PasswordsController do
  describe 'handling GET /passwords/new' do
    def do_get
      get :new
    end
    
    it 'should render the new template' do
      do_get
      response.should render_template('new')
    end
      
    it 'should be successful' do
      do_get
      response.should be_success
    end
    
    describe 'when already logged in' do
      before :each do
        simulate_logged_in
      end
      
      it 'should redirect instead' do
        controller.should_not_receive(:new)
        do_get
        response.should be_redirect
      end
    end
  end
  
  describe 'handling POST /passwords' do
    before :each do
      @user = mock_model(User, :forgot_password => true, :save => true)
      User.stub!(:find_for_forget).and_return(@user)
    end
    
    def do_post
      post :create, :email => 'someone@domain.tld'
    end
    
    it 'should find the user by the email address' do
      User.should_receive(:find_for_forget).with('someone@domain.tld').and_return(@user)
      do_post
    end
    
    it 'should initiate the reset process for the user\'s password' do
      @user.should_receive(:forgot_password)
      do_post
    end
    
    describe 'when the reset request cannot be saved' do
      before :each do
        @user.stub!(:forgot_password).and_return(false)
      end
      
      it 'should render new template' do
        do_post
        response.should render_template('new')
      end
    end
    
    describe 'when the supplied email isn\'t registered' do
      before :each do
        User.stub!(:find_for_forget).and_return(nil)
      end
      
      it 'should render new template' do
        do_post
        response.should render_template('new')
      end
    end
    
    describe 'when already logged in' do
      before :each do
        simulate_logged_in
      end
      
      it 'should not attempt to reset the password and redirect instead' do
        controller.should_not_receive(:create)
        do_post
        response.should be_redirect
      end
    end
  end
  
  describe 'handling GET /passwords/edit' do
    before :each do
      @user = mock_model(User)
      User.stub!(:find_by_password_reset_code).with('password reset code').and_return(@user)
    end
    
    def do_get(id = 'password reset code')
      get :edit, :id => id
    end
    
    it 'should assign the user to the view' do
      do_get
      assigns[:user].should == @user
    end
      
    it 'should render the edit template' do
      do_get
      response.should render_template('edit')
    end
      
    it 'should be successful' do
      do_get
      response.should be_success
    end
    
    describe 'when an invalid password reset code is supplied' do
      before :each do
        User.stub!(:find_by_password_reset_code).and_return(nil)
      end
      
      it 'should redirect to the new account page' do
        do_get
        response.should redirect_to(new_user_url)
      end
    end
    
    describe 'when no password reset code is supplied' do
      it 'should render the new template' do
        do_get(nil)
        response.should render_template('new')
      end
    end
  end
  
  describe 'handling PUT /passwords/:id' do
    before :each do
      @user = mock_model(User, :password= => true, :password_confirmation= => true, :save => true, :reset_password => true)
      User.stub!(:find_by_password_reset_code).with('password reset code').and_return(@user)
    end
    
    def do_put(password = 'new password', password_confirmation = 'new password', password_reset_code = 'password reset code')
      put :update, :id => password_reset_code, :password => password, :password_confirmation => password_confirmation
    end
    
    it 'should update the user\'s password and password confirmation' do
      @user.should_receive(:password=).with('new password')
      @user.should_receive(:password_confirmation=).with('new password')
      @user.should_receive(:save)
      do_put
    end
    
    it 'should update remove the password reset request' do
      @user.should_receive(:reset_password)
      do_put
    end
      
    describe 'when saving fails' do
      before :each do
        @user.stub!(:save).and_return(false)
      end
      
      it 'should render the edit template' do
        do_put
        response.should redirect_to(login_url)
      end
    end
    
    describe 'when an invalid password reset code is supplied' do
      before :each do
        User.stub!(:find_by_password_reset_code).and_return(nil)
      end
      
      it 'should redirect to the new account page' do
        do_put
        response.should redirect_to(new_user_url)
      end
    end
      
    describe 'when new passwords don\'t match' do
      it 'should render the edit template' do
        controller.expect_render(:action => 'edit', :id => 'password reset code')
        do_put('foo', 'bar')
      end
    end
      
    describe 'when new passwords are empty' do
      it 'should render the edit template' do
        controller.expect_render(:action => 'edit', :id => 'password reset code')
        do_put('', '')
      end
    end
    
    describe 'when no password reset code is supplied' do
      it 'should render the new template' do
        do_put('', '', nil)
        response.should render_template('new')
      end
    end
  end
end
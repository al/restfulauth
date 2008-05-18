

require File.dirname(__FILE__) + '/../spec_helper'

describe AccountsController do
  describe 'handling GET /users/:user_id/account' do
    before :each do
      User.stub!(:find_and_activate!)
    end
    
    def do_get
      get :show, :user_id => 'anything', :id => 'activation code'
    end
    
    it 'should activate the user' do
      User.should_receive(:find_and_activate!).with('activation code')
      do_get
    end
      
    it 'should be successful' do
      do_get
      response.should redirect_to(login_url)
    end
    
    describe 'when user or activation code not found' do
      it 'should redirect to the account creation page' do
        User.stub!(:find_and_activate!).and_raise(User::ArgumentError)
        do_get
        response.should redirect_to(new_user_url)
        User.stub!(:find_and_activate!).and_raise(User::ActivationCodeNotFound)
        do_get
        response.should redirect_to(new_user_url)
      end
    end
    
    describe 'when user already activated' do
      before :each do
        User.stub!(:find_and_activate!).and_raise(User::AlreadyActivated.new(@user))
      end
      
      it 'should redirect to the login page' do
        do_get
        response.should redirect_to(login_path)
      end
    end
    
    describe 'when already logged in' do
      before :each do
        simulate_logged_in
      end
      
      it 'should not activate the user and redirect instead' do
        controller.should_not_receive(:show)
        do_get
        response.should be_redirect
      end
    end
  end
  
  describe 'handling GET /users/:user_id/account/edit' do
    def do_get
      get :edit, :user_id => 'anything'
    end
    
    describe 'when user is logged in' do
      before :each do
        simulate_logged_in
      end
      
      it 'should render the edit template' do
        do_get
        response.should render_template('edit')
      end
        
      it 'should be successful' do
        do_get
        response.should be_success
      end
    end
    
    describe 'when user is not logged in' do
      before :each do
        simulate_not_logged_in
      end
      
      it 'should redirect' do
        controller.should_not_receive(:edit)
        do_get
        response.should be_redirect
      end
    end
  end
  
  describe 'handling PUT /users/:user_id/account' do
    before :each do
      @user = mock_model(User, :login => true, :password= => true, :password_confirmation= => true, :save => true)
    end
    
    def do_put(password = 'new password', password_confirmation = 'new password')
      put :update, :user_id => @user.id, :old_password => 'old password', :password => password, :password_confirmation => password_confirmation
    end
    
    describe 'when user is logged in' do
      before :each do
        simulate_logged_in(@user)
        User.stub!(:authenticate).and_return(true)
      end
      
      it 'should update the user\'s password and password confirmation' do
        @user.should_receive(:password=).with('new password')
        @user.should_receive(:password_confirmation=).with('new password')
        @user.should_receive(:save)
        do_put
      end
      
      describe 'when saving fails' do
        before :each do
          @user.stub!(:save).and_return(false)
        end
        
        it 'should render the edit template' do
          do_put
          response.should render_template('edit')
        end
      end
      
      describe 'when new passwords don\'t match or are empty' do
        it 'should render the edit template' do
          do_put('foo', 'bar')
          response.should render_template('edit')
          do_put('', '')
          response.should render_template('edit')
        end
        
        it 'should assign the old password to the view' do
          do_put('foo', 'bar')
          assigns[:old_password].should == 'old password'
          do_put('', '')
          assigns[:old_password].should == 'old password'
        end
      end
      
      describe 'when old password is not correct' do
        before :each do
          User.stub!(:authenticate).and_return(false)
        end
        
        it 'should render the edit template' do
          do_put
          response.should render_template('edit')
        end
      end
    end
  
    describe 'when user is not logged in' do
      before :each do
        simulate_not_logged_in
      end
      
      it 'should not attempt to update the password and redirect instead' do
        controller.should_not_receive(:update)
        do_put
        response.should be_redirect
      end
    end
  end
end
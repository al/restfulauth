

require File.dirname(__FILE__) + '/../spec_helper'

describe SessionsController do
  describe 'handling GET /sessions/new' do
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
  
  describe 'handling POST /sessions' do
    before :each do
      @user = mock_model(User)
    end
    
    def do_post(params = {})
      post :create, { :login => 'Jim', :password => 'password' }.merge(params)
    end
    
    describe 'with valid username and password' do
      before :each do
        User.stub!(:authenticate).and_return(@user)
      end
      
      describe 'when the user has activated the account' do
        before :each do
          @user.stub!(:activated_at).and_return(true)
        end
        
        describe 'and the account is enabled' do
          before :each do
            @user.stub!(:enabled).and_return(true)
            @cookies = mock('cookies')
            @cookies.stub!(:[])
            @cookies.stub!(:[]=)
            controller.stub!(:cookies).and_return(@cookies)
          end
          
          it 'should assign the user to the view' do
            do_post
            assigns[:current_user].should == @user
          end
          
          it 'should not create an authentication cookie' do
            do_post({ :remember_me => 0 })
            @cookies.should_not_receive(:[]=)
          end
          
          describe 'and params[:remember_me] == 1' do
            before :each do
              @user.stub!(:remember_me).and_return(true)
              @user.stub!(:remember_token).and_return('auth_token value')
              @user.stub!(:remember_token_expires_at).and_return('auth_token expires')
            end
            
            it 'should create an authentication cookie' do
              @cookies.should_receive(:[]=).with(:auth_token, { :value => 'auth_token value', :expires => 'auth_token expires' })
              do_post({ :remember_me => 1 })
            end
          end
          
          describe 'and the login request did not come from an internal page' do
            it 'should redirect to the user\'s home page' do
              do_post
              response.should redirect_to(user_url(@user.id))
            end
          end
          
          describe 'and the login request came from an internal page' do
            before :each do
              session[:return_to] = '/some/internal/page'
            end
            
            it 'should redirect to page that caused the login' do
              do_post
              response.should redirect_to('/some/internal/page')
            end
          end
        end
      
        describe 'but the account is disabled' do
          before :each do
            @user.stub!(:enabled).and_return(false)
          end
      
          it 'should render the new template' do
            do_post
            response.should render_template('new')
          end
        end
      end
      
      describe 'when the user has not activated the account' do
        before :each do
          @user.stub!(:activated_at).and_return(nil)
        end
      
        it 'should render the new template' do
          do_post
          response.should render_template('new')
        end
      end
    end
    
    describe 'with invalid username and/or invalid password' do
      before :each do
        User.stub!(:authenticate).and_return(nil)
      end
      
      it 'should render the new template' do
        do_post
        response.should render_template('new')
      end
    end
    
    describe 'when already logged in' do
      before :each do
        simulate_logged_in
      end
      
      it 'should not attempt to log in again and redirect instead' do
        controller.should_not_receive(:create)
        do_post
        response.should be_redirect
      end
    end
  end
  
  describe 'handling DELETE /session' do
    def do_delete
      delete :destroy
    end
    
    describe do
      before :each do
        @user = mock_model(User, :forget_me => true)
        session[:user_id] = @user.id
        controller.stub!(:current_user).and_return(@user)
        controller.stub!(:logged_in?).and_return(true)
        @cookies = mock('cookies', :delete => true)
        controller.stub!(:cookies).and_return(@cookies)
      end
      
      it 'should delete the user from the session' do
        do_delete
        session[:user_id].should be_nil
      end
      
      it 'should delete any authentication token from the cookies' do
        @cookies.should_receive(:delete).with(:auth_token)
        do_delete
      end
      
      it 'should redirect to the login page' do
        do_delete
        response.should redirect_to(login_url)
      end
    end
    
    describe 'when not logged in' do
      before :each do
        simulate_not_logged_in
      end
      
      it 'should not attempt to log out and redirect instead' do
        controller.should_not_receive(:destroy)
        do_delete
        response.should be_redirect
      end
    end
  end
end


require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  describe 'handling GET /users' do
    before :each do
      User.stub!(:find).with(:all).and_return('all users')
    end
    
    def do_get
      get :index
    end
    
    describe 'when user is logged in' do
      before :each do
        @user = mock_model(User, :has_role? => false)
        simulate_logged_in(@user)
      end
      
      describe 'with administrator privileges' do
        before :each do
          @user.stub!(:has_role?).with('administrator').and_return(true)
        end
        
        it 'should assign all the users to the view' do
          do_get
          assigns[:users].should == 'all users'
        end
        
        it 'should render the index template' do
          do_get
          response.should render_template('index')
        end
        
        it 'should be successful' do
          do_get
          response.should be_success
        end
      end
      
      describe 'without administrator privileges' do
        it 'should not attempt to retrieve user information and redirect instead' do
          controller.should_not_receive(:index)
          do_get
          response.should be_redirect
        end
      end
    end
    
    describe 'when user is not logged in' do
      before :each do
        simulate_not_logged_in
      end
      
      it 'should not attempt to retrieve user information and redirect instead' do
        controller.should_not_receive(:index)
        do_get
        response.should be_redirect
      end
    end
  end
  
  describe 'handling GET /users/:id' do
    before :each do
      @user = mock_model(User)
    end
    
    def do_get(id = @user.id)
      get :show, :id => id
    end
    
    describe 'when user is logged in' do
      before :each do
        simulate_logged_in(@user)
      end
      
      it 'should assign the user to the view' do
        do_get
        assigns[:user].should == @user
      end
      
      it 'should render the show template' do
        do_get
        response.should render_template('show')
      end
        
      it 'should be successful' do
        do_get
        response.should be_success
      end
      
      describe 'but is trying to view another user\'s page' do
        it 'should behave is if they were trying to view there own instead' do
          do_get(@user.id + 1)
          assigns[:user].should == @user
        end
      end
    end
    
    describe 'when user is not logged in' do
      before :each do
        simulate_not_logged_in
      end
      
      it 'should not attempt to retrieve user information and redirect instead' do
        controller.should_not_receive(:show)
        do_get
        response.should be_redirect
      end
    end
  end
  
  describe 'handling GET /users/new' do
    before :each do
      @user = mock_model(User)
      User.stub!(:new).and_return(@user)
    end
    
    def do_get
      get :new
    end
    
    it 'should assign a new user to the view' do
      User.should_receive(:new).and_return(@user)
      do_get
      assigns[:user].should == @user
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
        simulate_logged_in(@user)
      end
      
      it 'should not create a new user and redirect instead' do
        controller.should_not_receive(:new)
        do_get
        response.should be_redirect
      end
    end
  end
  
  describe 'handling POST /users' do
    before :each do
      @user = mock_model(User, :save! => true)
      User.stub!(:new).and_return(@user)
    end
    
    def do_post(user = {})
      post :create, :user => user
    end
    
    it 'should create a new user from the supplied params' do
      User.should_receive(:new).with('params').and_return(@user)
      do_post('params')
    end
    
    it 'should save the new user' do
      @user.should_receive(:save!)
      do_post
    end
    
    it 'should redirect to login page' do
      do_post
      response.should redirect_to(login_url)
    end
    
    describe 'when save fails' do
      before :each do
        @user.stub!(:save!).and_raise(ActiveRecord::RecordInvalid.new(mock_model(User, :errors => mock('errors', :full_messages => []))))
      end
      
      it 'should render the new template' do
        do_post
        response.should render_template('new')
      end
    end
    
    describe 'when already logged in' do
      before :each do
        simulate_logged_in(@user)
      end
      
      it 'should not create a new user and redirect instead' do
        controller.should_not_receive(:create)
        do_post
        response.should be_redirect
      end
    end
  end
  
  describe 'handling GET /users/:id/edit' do
    before :each do
      @user = mock_model(User)
    end
    
    def do_get(id = @user.id)
      get :edit, :id => id
    end
    
    describe 'when user is logged in' do
      before :each do
        simulate_logged_in(@user)
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
      
      describe 'but is trying to edit a different user' do
        it 'should behave is if they were trying to edit themselves' do
          do_get(@user.id + 1)
          assigns[:user].should == @user
        end
      end
    end
    
    describe 'when user is not logged in' do
      before :each do
        simulate_not_logged_in
      end
      
      it 'should not attempt to retrieve user information and redirect instead' do
        controller.should_not_receive(:edit)
        do_get
        response.should be_redirect
      end
    end
  end
  
  describe 'handling PUT /users/:id' do
    before :each do
      @user = mock_model(User, :update_attributes => true)
      User.stub!(:find).with(@user).and_return(@user)
    end
    
    def do_put(id = @user.id)
      put :update, :id => id, :user => 'params'
    end
    
    describe 'when user is logged in' do
      before :each do
        simulate_logged_in(@user)
      end
      
      it 'should find the user being updated' do
        User.should_receive(:find).with(@user.id).and_return(@user)
        do_put
      end
      
      it 'should update the user' do
        @user.should_receive(:update_attributes).with('params')
        do_put
      end
      
      it 'should redircet to the user\'s page' do
        do_put
        response.should redirect_to(user_url(@user))
      end
      
      describe 'when update fails' do
        before :each do
          @user.stub!(:update_attributes).and_return(false)
        end
        
        it 'should render the edit template' do
          do_put
          response.should render_template('edit')
        end
      end
      
      describe 'but is trying to update a different user' do
        it 'should behave is if they were trying to update themselves' do
          do_put(@user.id + 1)
          assigns[:user].should == @user
        end
      end
    end
    
    describe 'when user is not logged in' do
      before :each do
        simulate_not_logged_in
      end
      
      it 'should not attempt to update user information and redirect instead' do
        controller.should_not_receive(:edit)
        do_put
        response.should be_redirect
      end
    end
  end
  
  describe 'handling DELETE /users/:id' do
    before :each do
      @user = mock_model(User, :update_attribute => true)
      User.stub!(:find).with(@user.id.to_s).and_return(@user)
    end
    
    def do_delete(id = @user.id)
      delete :destroy, :id => id
    end
    
    describe 'when user is logged in' do
      before :each do
        @user2 = mock_model(User, :has_role? => false, :update_attribute => true)
        User.stub!(:find).with(@user2.id.to_s).and_return(@user2)
        simulate_logged_in(@user2)
      end
      
      describe 'with administrator privileges' do
        before :each do
          @user2.stub!(:has_role?).with('administrator').and_return(true)
        end
        
        it 'should find the user being disabled' do
          User.should_receive(:find).with(@user.id.to_s).and_return(@user)
          do_delete
        end
        
        it 'should disable the user' do
          @user.should_receive(:update_attribute).with(:enabled, false).and_return(true)
          do_delete
        end
        
        describe 'but update fails' do
          @user.stub!(:update_attribute).and_return(false)
          
          it 'should redirect to /users' do
            do_delete
            response.should redirect_to(users_url)
          end
        end
        
        describe 'but is attempting to disable themselves' do
          it 'should not attempt to disable the user and redirect instead' do
            @user2.should_not_receive(:update_attribute).with(:enabled, :false)
            do_delete(@user2.id)
            response.should be_redirect
          end
        end
      end
      
      describe 'without administrator privileges' do
        it 'should not attempt to disable the user and redirect instead' do
          controller.should_not_receive(:destroy)
          do_delete
          response.should be_redirect
        end
      end
    end
    
    describe 'when user is not logged in' do
      before :each do
        simulate_not_logged_in
      end
      
      it 'should not attempt to disable the user and redirect instead' do
        controller.should_not_receive(:destroy)
        do_delete
        response.should be_redirect
      end
    end
  end
  
  describe 'handling PUT /users/:id/enable' do
    before :each do
      @user = mock_model(User, :update_attribute => true)
      User.stub!(:find).with(@user.id.to_s).and_return(@user)
    end
    
    def do_put
      put :enable, :id => @user.id
    end
    
    describe 'when user is logged in' do
      before :each do
        @user2 = mock_model(User, :has_role? => false)
        simulate_logged_in(@user2)
      end
      
      describe 'with administrator privileges' do
        before :each do
          @user2.stub!(:has_role?).with('administrator').and_return(true)
        end
        
        it 'should find the user being enabled' do
          User.should_receive(:find).with(@user.id.to_s).and_return(@user)
          do_put
        end
        
        it 'should enable the user' do
          @user.should_receive(:update_attribute).with(:enabled, true).and_return(true)
          do_put
        end
        
        describe 'but update fails' do
          @user.stub!(:update_attribute).and_return(false)
          
          it 'should redirect to /users' do
            do_put
            response.should redirect_to(users_url)
          end
        end
      end
      
      describe 'without administrator privileges' do
        it 'should not attempt to enable the user and redirect instead' do
          controller.should_not_receive(:enable)
          do_put
          response.should be_redirect
        end
      end
    end
    
    describe 'when user is not logged in' do
      before :each do
        simulate_not_logged_in
      end
      
      it 'should not attempt to enable the user and redirect instead' do
        controller.should_not_receive(:enable)
        do_put
        response.should be_redirect
      end
    end
  end
end
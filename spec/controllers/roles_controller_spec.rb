

require File.dirname(__FILE__) + '/../spec_helper'

describe 'an administrator only action', :shared => true do
  before :each do
    @user = mock_model(User, :has_role? => false)
    User.stub!(:find).with(@user.id.to_s).and_return(@user)
    @role = mock_model(Role, :rolename => true)
    Role.stub!(:find).with(@role.id.to_s).and_return(@role)
    Role.stub!(:find).with(:all).and_return([@role])
  end
  
  describe 'when logged in but without administrator privileges' do
    before :each do
      simulate_logged_in(mock_model(User, :has_role? => false))
    end
    
    it 'should not attempt the action and redirect instead' do
      controller.should_not_receive(@action_being_tested_sym)
      do_
      response.should be_redirect
    end
  end
  
  describe 'when not logged in' do
    before :each do
      simulate_not_logged_in
    end
    
    it 'should not attempt the action and redirect instead' do
      controller.should_not_receive(@action_being_tested_sym)
      do_
      response.should be_redirect
    end
  end
end

describe RolesController do
  describe 'handling GET /users/:user_id/roles' do
    it_should_behave_like 'an administrator only action'
    
    before :each do
      @action_being_tested_sym = :index
      simulate_logged_in(mock_model(User, :has_role? => true))
    end
    
    def do_
      get :index, :user_id => @user.id
    end
    
    it 'should assign the user to the view' do
      do_
      assigns[:user].should == @user
    end
    
    it 'should assign all the roles to the view' do
      do_
      assigns[:all_roles].should == [@role]
    end
    
    it 'should render the index template' do
      do_
      response.should render_template('index')
    end
      
    it 'should be successful' do
      do_
      response.should be_success
    end
  end
  
  describe 'handling PUT /users/:user_id/roles/:id' do
    it_should_behave_like 'an administrator only action'
    
    before :each do
      @action_being_tested_sym = :update
      @user.stub!(:roles).and_return([])
      simulate_logged_in(mock_model(User, :has_role? => true))
    end
    
    def do_
      put :update, :user_id => @user.id, :id => @role.id
    end
    
    it 'should find the user' do
      User.should_receive(:find).with(@user.id.to_s).and_return(@user)
      do_
    end
    
    it 'should find the role' do
      Role.should_receive(:find).with(@role.id.to_s).and_return(@role)
      do_
    end
    
    it 'should add the role to the user\'s roles' do
      @user.roles.should_receive(:<<).with(@role)
      do_
    end
    
    it 'should redirect to the user\'s roles page' do
      do_
      response.should redirect_to(user_roles_url(@user.id))
    end
  end
  
  describe 'handling DELETE /users/:user_id/roles/:id' do
    it_should_behave_like 'an administrator only action'
    
    before :each do
      @action_being_tested_sym = :destroy
      @user.stub!(:roles).and_return([@role])
      @user.stub!(:has_role?).and_return(true)
      simulate_logged_in(mock_model(User, :has_role? => true))
    end
    
    def do_
      delete :destroy, :user_id => @user.id, :id => @role.id
    end
    
    it 'should find the user' do
      User.should_receive(:find).with(@user.id.to_s).and_return(@user)
      do_
    end
    
    it 'should find the role' do
      Role.should_receive(:find).with(@role.id.to_s).and_return(@role)
      do_
    end
    
    it 'should remove the role from the user\'s roles' do
      @user.roles.should_receive(:delete).with(@role)
      do_
    end
    
    it 'should redirect to the user\'s roles page' do
      do_
      response.should redirect_to(user_roles_url(@user.id))
    end
  end
end
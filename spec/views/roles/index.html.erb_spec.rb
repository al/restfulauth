

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /roles/index.html.erb' do
  before(:each) do
    assigns[:all_roles] = ['role 1', 'role 2']
    assigns[:user] = mock_model(User, :login => 'login', :roles => ['role 1'])
    template.stub!(:render)
  end

  it 'should render the role partial for each role assigned to the user' do
    template.should_receive(:render).with(:partial => 'role', :collection => ['role 1'])
    render '/roles/index.html.erb'
  end

  it 'should render the role partial for each role not assigned to the user' do
    template.should_receive(:render).with(:partial => 'role', :collection => ['role 2'])
    render '/roles/index.html.erb'
  end
end
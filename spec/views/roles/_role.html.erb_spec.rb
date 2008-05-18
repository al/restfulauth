

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /roles/_role.html.erb' do
  before(:each) do
    @role = mock_model(Role, :rolename => 'role name')
    assigns[:user] = mock_model(User)
    template.stub!(:role).and_return(@role)
    template.stub!(:render)
  end

  it 'when user has the role should render form to remove role' do
    assigns[:user].stub!(:has_role?).and_return(true)
    render '/roles/_role.html.erb'
    response.should have_tag('form[action=?][method=post]', user_role_path(:id => @role.id, :user_id => assigns[:user].id)) do
      with_tag('input[name=_method][value=delete]')
      with_tag('input[type=submit][value=?]', 'remove role')
    end
  end

  it 'when user does not have the role should render form to add role' do
    assigns[:user].stub!(:has_role?).and_return(false)
    render '/roles/_role.html.erb'
    response.should have_tag('form[action=?][method=post]', user_role_path(:id => @role.id, :user_id => assigns[:user].id)) do
      with_tag('input[name=_method][value=put]')
      with_tag('input[type=submit][value=?]', 'assign role')
    end
  end
end


require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /users/_user.html.erb' do
  before(:each) do
    @user = mock_model(User, :login => 'login', :email => 'email', :enabled => true)
    template.stub!(:user).and_return(@user)
    template.stub!(:render)
  end

  it 'should render the user\'s login' do
    render '/users/_user.html.erb'
    response.should have_text(/login/) do
    end
  end

  it 'should render the user\'s email' do
    render '/users/_user.html.erb'
    response.should have_text(/email/) do
    end
  end
  
  it 'should render link to edit user\'s roles' do
    render '/users/_user.html.erb'
    response.should have_tag('a[href=?]', user_roles_path(@user)) do
    end
  end

  it 'should render the user\'s status' do
    render '/users/_user.html.erb'
    response.should have_text(/yes/) do
    end
    response.should have_tag('form[action=?][method=post]', user_path(@user.id)) do
      with_tag('input[name=_method][value=delete]')
      with_tag('input[type=submit][value=?]', 'disable')
    end
  end

  it 'should render the user\'s status' do
    @user.stub!(:enabled).and_return(false)
    render '/users/_user.html.erb'
    response.should have_text(/no/) do
    end
    response.should have_tag('form[action=?][method=post]', user_path(@user.id)) do
      with_tag('input[name=_method][value=put]')
      with_tag('input[type=submit][value=?]', 'enable')
    end
  end
  
  it 'should not render the enable/disable forms if the user is viewing themselves' do
    template.stub!(:current_user).and_return(@user)
    render '/users/_user.html.erb'
    response.should_not have_tag('form[action=?][method=post]', user_path(@user.id)) do
    end
  end
end
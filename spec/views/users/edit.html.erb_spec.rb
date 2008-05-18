

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /users/edit.html.erb' do
  before(:each) do
    assigns[:user] = mock_model(User, :email => 'email')
    template.stub!(:render)
  end

  it 'should render the edit form' do
    render '/users/edit.html.erb'
    response.should have_tag('form[action=?][method=post]', user_path(assigns[:user])) do
      with_tag('input[name=_method][value=put]')
      with_tag('input[type=text][name=?]', 'user[email]')
      with_tag('input[type=submit][value=?]', 'Save')
    end
  end

  it 'should render the show profile link' do
    render '/users/edit.html.erb'
    response.should have_tag('a[href=?]', user_path(assigns[:user])) do
    end
  end

  it 'should render the change password link' do
    render '/users/edit.html.erb'
    response.should have_tag('a[href=?]', change_password_path) do
    end
  end
end
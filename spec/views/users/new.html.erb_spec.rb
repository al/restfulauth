

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /users/new.html.erb' do
  it 'should render the new form' do
    render '/users/new.html.erb'
    response.should have_tag('form[action=?][method=post]', users_path) do
      with_tag('input[type=text][name=?]', 'user[login]')
      with_tag('input[type=text][name=?]', 'user[email]')
      with_tag('input[type=password][name=?]', 'user[password]')
      with_tag('input[type=password][name=?]', 'user[password_confirmation]')
      with_tag('input[type=submit][value=?]', 'Sign up')
    end
  end
end


require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /accounts/edit.html.erb' do
  before(:each) do
    assigns[:old_password] = 'old password'
    session[:user_id] = 1
    template.stub!(:render)
  end

  it 'should render the edit form' do
    render '/accounts/edit.html.erb'
    response.should have_tag('form[action=?][method=post]', user_account_path(session[:user_id])) do
      with_tag('input[name=_method][value=put]')
      with_tag('input[type=password][name=?]', 'old_password')
      with_tag('input[type=password][name=?]', 'password')
      with_tag('input[type=password][name=?]', 'password_confirmation')
      with_tag('input[type=submit][value=?]', 'Change password')
    end
  end
end
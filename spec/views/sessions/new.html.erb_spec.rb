

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /sessions/new.html.erb' do
  before(:each) do
    template.stub!(:render)
  end

  it 'should render the new form' do
    render '/sessions/new.html.erb'
    response.should have_tag('form[action=?][method=post]', session_path) do
      with_tag('input[type=text][name=?]', 'login')
      with_tag('input[type=password][name=?]', 'password')
      with_tag('input[type=checkbox][name=?]', 'remember_me')
      with_tag('input[type=submit][value=?]', 'Log in')
    end
  end
  
  it 'should render the sign up link' do
    render '/sessions/new.html.erb'
    response.should have_tag('a[href=?]', new_user_path) do
    end
  end
end
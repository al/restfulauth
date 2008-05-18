

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /passwords/new.html.erb' do
  before(:each) do
    template.stub!(:render)
  end

  it 'should render the new form' do
    render '/passwords/new.html.erb'
    response.should have_tag('form[action=?][method=post]', password_path) do
      with_tag('input[type=text][name=?]', 'email')
      with_tag('input[type=submit][value=?]', 'Reset password')
    end
  end
end
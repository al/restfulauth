

require File.dirname(__FILE__) + '/../../spec_helper'

describe 'rendering /passwords/edit.html.erb' do
  before(:each) do
    params[:id] = 1
    template.stub!(:render)
  end

  it 'should render the edit form' do
    render '/passwords/edit.html.erb'
    response.should have_tag('form[action=?][method=post]', password_path(:id => 1)) do
      with_tag('input[name=_method][value=put]')
      with_tag('input[type=password][name=?]', 'password')
      with_tag('input[type=password][name=?]', 'password_confirmation')
      with_tag('input[type=submit][value=?]', 'Change password')
    end
  end
end


steps_for(:see) do
  Then '$actor should see $page page' do |actor, page|
    user = get_user(actor)
    path = case page
      when /his|her|its/ then
        case page.gsub(/^[^ ]* /, '')
          when 'edit roles' then user_roles_path(user.id)
          when 'account settings' then edit_user_path(user.id)
          when 'home' then user_path(user.id)
        end
      when 'the home' then root_path
      when 'the user administration' then users_path
      when 'his edit roles' then users_path
      when 'the login' then response.should render_template('new') && return; login_path
      when 'the change password' then user_account_path(user.id)
      when 'the reset password' then response.should render_template('new') && return; reset_password_path
      when 'the sign up' then response.should render_template('new') && return; new_user_path
    end
    
    request.request_uri.should == path 
  end
  
  Then '$actor should see a \'$link\' link' do |actor, link|
    response.should have_tag('a[href]', link)
  end
  
  Then '$actor should not see a \'$link\' link' do |actor, link|
    response.should_not have_tag('a[href]', link)
  end
  
  Then '$actor should see a \'$button\' button' do |actor, button|
    response.should have_tag("input[type=submit][value=#{button}]")
  end
  
  Then '$actor should not see a \'$button\' button' do |actor, button|
    response.should_not have_tag("input[type=submit][value=#{button}]")
  end
  
  Then '$actor should see the error \'$error\'' do |actor, error|
    response.should have_tag('div.error') do
      have_text(/#{error}/)
    end
  end
  
  Then '$actor should not see the error \'$error\'' do |actor, error|
    response.should_not have_tag('div.error') do
      have_text(/#{error}/)
    end
  end
end
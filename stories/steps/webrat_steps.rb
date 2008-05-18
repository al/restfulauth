

steps_for(:webrat) do
  When '$actor navigates to $url' do |actor, url|
    url = case url
      when /his|her|its/ then
        user = get_user(actor)
        case url.gsub(/^[^ ]* /, '')
          when 'home page' then user_path(user.id)
          when 'password reset page' then reset_password_path(user.password_reset_code)
        end
      when 'any page' then '/' # A poor substitute for testing the layout ...
      when 'an invalid password reset page' then reset_password_path(0)
      else url
    end
    visits url
  end
  
  When '$actor clicks the \'$button\' button' do |actor, button|
    clicks_button button
  end
  
  When '$actor clicks the \'$link\' link' do |actor, link|
    clicks_link link
  end
  
  When '$actor fills in \'$field\' with \'$value\'' do |actor, field, value|
    fills_in field, :with => value
  end
  
  When '$actor checks \'$checkbox\'' do |actor, checkbox|
    checks checkbox
  end
end
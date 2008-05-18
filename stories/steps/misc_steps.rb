

steps_for(:misc) do
  When '$actor starts a new session' do |actor|
    session[:user_id] = nil # Think this is adequate ... ?
  end
end
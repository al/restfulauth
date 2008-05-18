

def do_signup(actor)
  post users_path, :user => { :login => actor, :email => "#{actor}@domain.tld", :password => 'password', :password_confirmation => 'password' }
end

def do_activate(activation_code)
  get user_account_path(0), :id => activation_code
end

def do_login(actor)
  post session_path, :login => actor, :password => 'password'
end

steps_for(:account) do
  Given '$actor is logged in' do |actor|
    do_signup(actor); @last_actor = User.find_by_login(actor)
    do_activate(@last_actor.activation_code)
    do_login(actor)
    
    instance_variable_set("@#{actor}", @last_actor)
  end
  
  Given '$actor is not logged in' do |actor|
    do_signup(actor); @last_actor = User.find_by_login(actor)
    do_activate(@last_actor.activation_code)
    
    instance_variable_set("@#{actor}", @last_actor)
  end
  
  Given '$actor does not have an account' do |actor|
    User.delete_all(:login => actor)
    @last_actor = User.new(:login => actor)
  end
  
  Given '$actor has \'$privilege\' privileges' do |actor, privilege|
    role = Role.find_or_create_by_rolename(:rolename => privilege)
    Permission.find_or_create_by_role_id_and_user_id(:role_id => role.id, :user_id => get_user(actor).id)
  end
  
  Given '$actor does not have \'$privelege\' privileges' do |actor, privilege|
    Role.find_or_create_by_rolename(:rolename => privilege)
  end
  
  Then '$actor should be assigned \'$role\' privileges' do |actor, role|
    get_user(actor).should have_role(role)
  end

  Then '$actor new account should be created' do |actor|
    User.find_by_login(get_user(actor).login).should_not be_nil
  end
  
  Then '$actor account should be disabled' do |actor|
    get_user(actor).enabled.should be_false
  end
  
  Then '$actor password should be \'$password\'' do |actor, password|
    get_user(actor).should be_authenticated(password)
  end
  
  Then '$actor password should not be \'$password\'' do |actor, password|
    get_user(actor).should_not be_authenticated(password)
  end
  
  Then '$actor email should be \'$email\'' do |actor, email|
    get_user(actor).email.should == email
  end
end
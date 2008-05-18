

module AuthenticatedSystem
  protected
  
  def logged_in?
    current_user != false
  end
 
  def current_user
    @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie || false)
  end
 
  def current_user=(new_user)
    session[:user_id] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
    @current_user = new_user || false
  end
 
  def authorized?
    logged_in?
  end
 
  def login_required
    authorized? || access_denied
  end
    
  def not_logged_in_required
    !logged_in? || permission_denied
  end
    
  def check_role(role)
    if !logged_in?
      permission_denied
    elsif !@current_user.has_role?(role)
      store_referer
      access_denied
    end
  end
 
  def check_administrator_role
    check_role('administrator')
  end    
 
  def access_denied
    respond_to do |format|
      format.html do
        store_location
        flash[:error] = 'You must be logged in to access this feature.'
        redirect_to login_path
      end
      format.xml do
        request_http_basic_authentication 'Web Password'
      end
    end
  end
  
  def permission_denied      
    respond_to do |format|
      format.html do
        domain_name = 'http://localhost:3001'
        http_referer = session[:refer_to]
        if http_referer.nil?
          store_referer
          http_referer = (session[:refer_to] || domain_name)
        end
        flash[:error] = 'You don\'t have permission to complete that action.'
        if http_referer[0..(domain_name.length - 1)] != domain_name  
          session[:refer_to] = nil
          redirect_to root_path
        else
          redirect_to_referer_or_default(root_path)
        end
      end
      format.xml do
        headers['Status'] = 'Unauthorized'
        headers['WWW-Authenticate'] = %(Basic realm='Web Password')
        render :text => 'You don\'t have permission to complete this action.', :status => '401 Unauthorized'
      end
    end
  end
 
  def store_location
    session[:return_to] = request.request_uri
  end
 
  def store_referer
    session[:refer_to] = request.env['HTTP_REFERER']
  end
 
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
 
  def redirect_to_referer_or_default(default)
    redirect_to(session[:refer_to] || default)
    session[:refer_to] = nil
  end
 
  def self.included(base)
    base.send :helper_method, :current_user, :logged_in?
  end
 
  def login_from_session
    self.current_user = User.find(session[:user_id]) if session[:user_id]
  end
 
  def login_from_basic_auth
    authenticate_with_http_basic do |username, password|
      self.current_user = User.authenticate(username, password)
    end
  end
 
  def login_from_cookie
    user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      user.remember_me
      cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
      self.current_user = user
    end
  end
end
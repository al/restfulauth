

class PasswordsController < ApplicationController
  before_filter :not_logged_in_required, :only => [:new, :create]
  
  def new
  end
 
  def create
    if @user = User.find_for_forget(params[:email])
      if @user.forgot_password
        flash[:notice] = 'A password reset link has been sent to your email address.'
        redirect_to login_path
      else
        flash[:error] = 'An error occurred.'
        render :action => 'new'
      end
    else
      flash[:notice] = 'Could not find a user with that email address.'
      render :action => 'new'
    end  
  end
  
  def edit
    if params[:id].nil?
      render :action => 'new'
      return
    end
    @user = User.find_by_password_reset_code(params[:id]) if params[:id]
    if @user.nil?
      logger.error 'Invalid Reset Code entered.'
      flash[:notice] = 'Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)'
      redirect_to new_user_path
    end
  end
  
  def update
    if params[:id].nil?
      render :action => 'new'
      return
    end
    if params[:password].blank?
      flash[:notice] = 'Password field cannot be blank.'
      render :action => 'edit', :id => params[:id]
      return
    end
    @user = User.find_by_password_reset_code(params[:id]) if params[:id]
    if @user.nil?
      logger.error 'Invalid Reset Code entered'
      flash[:notice] = 'Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?)'
      redirect_to new_user_path
    else
      if params[:password] == params[:password_confirmation]
        @user.password_confirmation = params[:password_confirmation]
        @user.password = params[:password]
        @user.reset_password
        flash[:notice] = @user.save ? 'Password reset.' : 'Password not reset.'
      else
        flash[:notice] = 'Password mismatch.'
        render :action => 'edit', :id => params[:id]
        return
      end  
      redirect_to login_path
    end
  end
end
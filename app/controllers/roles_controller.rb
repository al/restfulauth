

class RolesController < ApplicationController
  before_filter :check_administrator_role
 
  def index
    @user = User.find(params[:user_id])
    @all_roles = Role.find(:all)
  end
 
  def update
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    @user.roles << @role unless @user.has_role?(@role.rolename)
    redirect_to user_roles_path(params[:user_id])
  end
  
  def destroy
    @user = User.find(params[:user_id])
    @role = Role.find(params[:id])
    @user.roles.delete(@role) if @user.has_role?(@role.rolename)
    redirect_to user_roles_path(params[:user_id])
  end
end